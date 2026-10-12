import 'package:flutter/material.dart';

class TasbihScreen extends StatefulWidget {
  const TasbihScreen({super.key});

  @override
  State<TasbihScreen> createState() => _TasbihScreenState();
}

class _TasbihScreenState extends State<TasbihScreen> {
  int _counter = 0;
  int _totalCount = 0;
  int _target = 33;
  int _selectedPhraseIndex = 0;

  final List<String> _phrases = [
    "سُبْحَانَ اللَّهِ",
    "الْحَمْدُ لِلَّهِ",
    "اللَّهُ أَكْبَرُ",
    "لَا إِلَٰهَ إِلَّا اللَّهُ",
    "أَسْتَغْفِرُ اللَّهَ وَأَتُوبُ إِلَيْهِ",
    "سُبْحَانَ اللَّهِ وَبِحَمْدِهِ ، سُبْحَانَ اللَّهِ الْعَظِيمِ",
    "اللَّهُمَّ صَلِّ وَسَلِّمْ عَلَى نَبِيِّنَا مُحَمَّدٍ",
  ];

  void _increment() {
    setState(() {
      _counter++;
      _totalCount++;
      if (_counter >= _target) {
        _counter = 0;
      }
    });
  }

  void _reset() {
    setState(() {
      _counter = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final phrase = _phrases[_selectedPhraseIndex];

    return Scaffold(
      backgroundColor: const Color(0xFF0B132B),
      appBar: AppBar(
        backgroundColor: const Color(0xFF064E3B),
        title: const Text("المسبحة الإلكترونية الذكية", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            tooltip: "تصفير العداد",
            onPressed: _reset,
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          SizedBox(
            height: 48,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemCount: _phrases.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final isSelected = _selectedPhraseIndex == index;
                return ChoiceChip(
                  label: Text(_phrases[index]),
                  selected: isSelected,
                  selectedColor: const Color(0xFF10B981),
                  backgroundColor: const Color(0xFF1E293B),
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : const Color(0xFF94A3B8),
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                  onSelected: (_) {
                    setState(() {
                      _selectedPhraseIndex = index;
                      _counter = 0;
                    });
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFD4AF37), width: 1.5),
              ),
              child: Text(
                phrase,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFFFDE68A),
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  height: 1.6,
                ),
              ),
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: _increment,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const RadialGradient(
                  colors: [Color(0xFF059669), Color(0xFF064E3B), Color(0xFF022C22)],
                  stops: [0.3, 0.7, 1.0],
                ),
                border: Border.all(color: const Color(0xFFD4AF37), width: 4),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF10B981).withValues(alpha: 0.4),
                    blurRadius: 30,
                    spreadRadius: 8,
                  ),
                ],
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "$_counter",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 64,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'monospace',
                      ),
                    ),
                    Text(
                      "من $_target",
                      style: const TextStyle(color: Color(0xFFD1FAE5), fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: const BoxDecoration(
              color: Color(0xFF1E293B),
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("المجموع الكلي اليوم", style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
                    Text("$_totalCount تسبيحة", style: const TextStyle(color: Color(0xFF34D399), fontWeight: FontWeight.bold, fontSize: 16)),
                  ],
                ),
                Row(
                  children: [33, 100, 1000].map((t) {
                    final isSel = _target == t;
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: FilterChip(
                        label: Text("$t"),
                        selected: isSel,
                        selectedColor: const Color(0xFF10B981),
                        backgroundColor: const Color(0xFF0F172A),
                        labelStyle: TextStyle(color: isSel ? Colors.white : const Color(0xFF94A3B8)),
                        onSelected: (_) {
                          setState(() {
                            _target = t;
                            _counter = 0;
                          });
                        },
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
