import 'package:flutter/material.dart';
import '../hive_service.dart';
import '../models/habit_hive.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});
  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  List<HabitHive> _habits = [];

  @override
  void initState() {
    super.initState();
    _loadHabits();
  }

  void _loadHabits() {
    final items = HiveService.getAllHabits().cast<HabitHive>();
    setState(() => _habits = items);
  }

  @override
  Widget build(BuildContext context) {
    final total = _habits.length;
    final done = _habits.where((h) => h.isCompleted).length;
    final percent = total == 0 ? 0 : ((done / total) * 100).round();

    return RefreshIndicator(
      onRefresh: () async => _loadHabits(),
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
        ],
      ),
    );
  }
}
