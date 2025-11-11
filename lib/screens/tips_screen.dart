// lib/screens/tips_screen.dart
import 'package:flutter/material.dart';

class TipsScreen extends StatelessWidget {
  const TipsScreen({super.key});
  final List<String> tips = const [
    'Drink a glass of water when you wake up.',
    'Take a 5-minute stretch break every hour.',
    'Try a 10-minute walk after lunch.',
    'Aim for at least 7–8 hours of sleep.',
    'Keep a consistent bedtime.',
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: tips.length,
      itemBuilder: (c, i) => Card(
        child: ListTile(title: Text('Tip ${i + 1}'), subtitle: Text(tips[i])),
      ),
    );
  }
}
