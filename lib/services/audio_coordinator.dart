import 'dart:async';
import 'package:flutter/widgets.dart';

/// Logical audio channels used by Mihrab, ordered by priority.
///
/// Priority (highest first):
///   1. [adhan]  – the call to prayer. ALWAYS interrupts everything else.
///   2. [verse] / [media] – Quran verse recitation, full Surah player, live radio.
///   3. [chime]  – short UI/feedback alert sounds (never interrupts Quran or Adhan).
enum AudioChannel { chime, media, verse, adhan }

/// Central audio focus manager (in-app "Audio Manager").
///
/// Every in-app sound source must call [requestFocus] before starting playback and
/// [abandonFocus] when it stops/completes. The coordinator guarantees that:
///  * Only one channel is audible at any time (no audio clash / overlap).
///  * A lower-priority channel can NEVER start while a higher-priority one is active
///    (e.g. the startup verse recitation cannot start while the Adhan is playing).
///  * A higher-priority channel immediately stops every lower-priority channel
///    (e.g. the Adhan instantly stops the verse recitation, the Surah player, and live radio).
///
/// It also tracks the app lifecycle so the prayer services can decide whether the
/// in-app Adhan player or the system alarm notification is responsible for the Adhan sound.
class AudioCoordinator with WidgetsBindingObserver {
  AudioCoordinator._();
  static final AudioCoordinator _instance = AudioCoordinator._();
  static bool _initialized = false;

  static AppLifecycleState _lifecycle = AppLifecycleState.resumed;

  /// Whether the app UI is currently visible in the foreground.
  static bool get isForeground => _lifecycle == AppLifecycleState.resumed;

  /// Currently active (focused) channels. Normally contains at most one entry.
  static final Set<AudioChannel> _active = <AudioChannel>{};

  /// Reactive notifier of the highest active channel (null when silent).
  static final ValueNotifier<AudioChannel?> activeChannelNotifier = ValueNotifier<AudioChannel?>(null);

  /// Stop callbacks registered by the singleton services (verse, adhan, chime).
  static final Map<AudioChannel, Future<void> Function()> _channelStoppers = {};

  /// Stop callbacks registered by screen-level players (Surah player, live radio...).
  static final Map<String, Future<void> Function()> _mediaStoppers = {};

  /// Serializes focus changes so two concurrent requests can never interleave.
  static Future<void> _lock = Future<void>.value();

  static int _priority(AudioChannel c) {
    switch (c) {
      case AudioChannel.adhan:
        return 3;
      case AudioChannel.verse:
      case AudioChannel.media:
        return 2;
      case AudioChannel.chime:
        return 1;
    }
  }

  /// Must be called once after `WidgetsFlutterBinding.ensureInitialized()`.
  static void init() {
    if (_initialized) return;
    _initialized = true;
    try {
      _lifecycle = WidgetsBinding.instance.lifecycleState ?? AppLifecycleState.resumed;
      WidgetsBinding.instance.addObserver(_instance);
    } catch (e) {
      debugPrint("AudioCoordinator init note: $e");
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _lifecycle = state;
  }

  /// Registers the stop callback of a singleton audio service.
  static void registerChannelStopper(AudioChannel channel, Future<void> Function() stopper) {
    _channelStoppers[channel] = stopper;
  }

  /// Registers a screen-level media player so the Adhan can interrupt it.
  static void registerMediaStopper(String owner, Future<void> Function() stopper) {
    _mediaStoppers[owner] = stopper;
  }

  static void unregisterMediaStopper(String owner) {
    _mediaStoppers.remove(owner);
  }

  static bool isActive(AudioChannel channel) => _active.contains(channel);

  static bool get isAdhanActive => _active.contains(AudioChannel.adhan);

  /// True while the Adhan or any Quran audio is audible (used to silence other alerts).
  static bool get isBusy =>
      _active.contains(AudioChannel.adhan) ||
      _active.contains(AudioChannel.verse) ||
      _active.contains(AudioChannel.media);

  static AudioChannel? _highestActive() {
    AudioChannel? best;
    for (final c in _active) {
      if (best == null || _priority(c) > _priority(best)) best = c;
    }
    return best;
  }

  static void _publish() {
    activeChannelNotifier.value = _highestActive();
  }

  /// Requests exclusive audio focus for [channel].
  ///
  /// Returns `false` (and plays nothing) when a higher-priority channel is active,
  /// unless [interruptHigher] is true (used ONLY for explicit user actions such as
  /// pressing the "استماع للتلاوة" button).
  ///
  /// On success, every other channel and screen-level player is stopped BEFORE this
  /// method returns, so the caller can start playback without any overlap.
  static Future<bool> requestFocus(
    AudioChannel channel, {
    bool interruptHigher = false,
    String? mediaOwner,
  }) {
    final completer = Completer<bool>();
    _lock = _lock.then((_) async {
      try {
        final current = _highestActive();
        if (current != null &&
            current != channel &&
            _priority(current) > _priority(channel) &&
            !interruptHigher) {
          debugPrint("AudioCoordinator: focus for $channel denied ($current has higher priority)");
          completer.complete(false);
          return;
        }

        // Claim focus first so no lower-priority source can slip in while we stop the others.
        _active.add(channel);
        _publish();

        // Stop every other singleton channel of lower/equal priority (higher ones only when
        // the caller is an explicit user action with [interruptHigher]).
        for (final entry in _channelStoppers.entries.toList()) {
          if (entry.key == channel) continue;
          if (_priority(entry.key) > _priority(channel) && !interruptHigher) continue;
          try {
            await entry.value();
          } catch (e) {
            debugPrint("AudioCoordinator stop ${entry.key} note: $e");
          }
          _active.remove(entry.key);
        }

        // Stop every screen-level media player except the requester itself
        // (media has lower priority than the Adhan, so the Adhan always stops it).
        if (_priority(channel) >= _priority(AudioChannel.media) || interruptHigher) {
          for (final entry in _mediaStoppers.entries.toList()) {
            if (entry.key == mediaOwner) continue;
            try {
              await entry.value();
            } catch (e) {
              debugPrint("AudioCoordinator stop media '${entry.key}' note: $e");
            }
          }
          if (channel != AudioChannel.media) {
            _active.remove(AudioChannel.media);
          }
        }

        final keepAdhan = _active.contains(AudioChannel.adhan) &&
            channel != AudioChannel.adhan &&
            !interruptHigher;
        _active
          ..clear()
          ..add(channel);
        if (keepAdhan) _active.add(AudioChannel.adhan);
        _publish();
        completer.complete(true);
      } catch (e) {
        debugPrint("AudioCoordinator requestFocus error: $e");
        if (!completer.isCompleted) completer.complete(false);
      }
    });
    return completer.future;
  }

  /// Releases focus held by [channel] (call on stop, pause, completion, or failure).
  static void abandonFocus(AudioChannel channel) {
    if (_active.remove(channel)) {
      _publish();
    }
  }

  /// Stops every non-Adhan sound immediately (used when the system alarm notification
  /// is responsible for the Adhan sound, e.g. when the app is in the background).
  static Future<void> silenceAllExceptAdhan() async {
    for (final entry in _channelStoppers.entries.toList()) {
      if (entry.key == AudioChannel.adhan) continue;
      try {
        await entry.value();
      } catch (_) {}
      _active.remove(entry.key);
    }
    for (final stopper in _mediaStoppers.values.toList()) {
      try {
        await stopper();
      } catch (_) {}
    }
    _active.remove(AudioChannel.media);
    _publish();
  }
}
