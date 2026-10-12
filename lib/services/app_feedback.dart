import 'package:flutter/services.dart';

/// AppFeedback provides tactile haptic feedback and gentle system sound alerts
/// when browsing app sections, doors, and settings.
class AppFeedback {
  /// Subtle pleasant tap feedback when tapping buttons, cards, or navigation tabs
  static void tap() {
    try {
      HapticFeedback.lightImpact();
      SystemSound.play(SystemSoundType.click);
    } catch (_) {}
  }

  /// Selection feedback when toggling switches, radio items, or sliders in settings
  static void select() {
    try {
      HapticFeedback.selectionClick();
      SystemSound.play(SystemSoundType.click);
    } catch (_) {}
  }

  /// Medium impact feedback when opening important sections or performing actions
  static void medium() {
    try {
      HapticFeedback.mediumImpact();
      SystemSound.play(SystemSoundType.click);
    } catch (_) {}
  }
}
