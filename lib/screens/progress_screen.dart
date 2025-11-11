// lib/screens/progress_screen.dart
import 'package:flutter/material.dart';
import '../database/db_helper.dart';
import '../models/habit.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});
  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  List<Habit> _habits = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final rows = await DBHelper().getAllHabits();
    setState(() {
      _habits = rows.map((r) => Habit.fromMap(r)).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final total = _habits.length;
    final done = _habits.where((h) => h.isCompleted).length;
    final percent = total == 0 ? 0 : ((done / total) * 100).round();

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Text('Today\'s Progress', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 12),
                  Text('$done / $total habits completed', style: const TextStyle(fontSize: 18)),
                  const SizedBox(height: 12),
                  LinearProgressIndicator(value: total == 0 ? 0 : done / total),
                  const SizedBox(height: 12),
                  Text('$percent%'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Optionally add charts later with fl_chart
        ],
      ),
    );
  }
}
