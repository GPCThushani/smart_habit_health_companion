// lib/screens/habits_screen.dart
import 'package:flutter/material.dart';
import '../database/db_helper.dart';
import '../models/habit.dart';
import '../notifications/notify_helper.dart';

class HabitsScreen extends StatefulWidget {
  const HabitsScreen({super.key});
  @override
  State<HabitsScreen> createState() => _HabitsScreenState();
}

class _HabitsScreenState extends State<HabitsScreen> {
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

  Future<void> _toggle(Habit h) async {
    final updated = Habit(
      id: h.id,
      title: h.title,
      notes: h.notes,
      isCompleted: !h.isCompleted,
      reminderHour: h.reminderHour,
      reminderMinute: h.reminderMinute,
      createdAt: h.createdAt,
    );
    await DBHelper().updateHabit(updated.toMap());
    await _load();
  }

  Future<void> _delete(Habit h) async {
    if (h.id != null) {
      await DBHelper().deleteHabit(h.id!);
      if (h.id != null) await NotifyHelper.cancel(h.id!);
      await _load();
    }
  }

  Future<void> _openAddEdit([Habit? edit]) async {
    final titleCtrl = TextEditingController(text: edit?.title ?? '');
    final notesCtrl = TextEditingController(text: edit?.notes ?? '');
    TimeOfDay? time = EditTimeOfDay(edit?.reminderHour, edit?.reminderMinute);

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(edit == null ? 'Add Habit' : 'Edit Habit'),
        content: SingleChildScrollView(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'Title')),
            TextField(controller: notesCtrl, decoration: const InputDecoration(labelText: 'Notes (optional)')),
            const SizedBox(height: 8),
            Row(children: [
              const Text('Reminder: '),
              TextButton(
                child: Text(time?.format(context) ?? 'Set Time'),
                onPressed: () async {
                  final picked = await showTimePicker(
                    context: context,
                    initialTime: time ?? TimeOfDay.now(),
                  );
                  if (picked != null) {
                    time = picked;
                    setState(() {}); // update label after picking
                  }
                },
              ),
              if (time != null)
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    time = null;
                    setState(() {});
                  },
                )
            ])
          ]),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              final title = titleCtrl.text.trim();
              if (title.isEmpty) return;

              final map = {
                'title': title,
                'notes': notesCtrl.text.trim(),
                'isCompleted': edit?.isCompleted == true ? 1 : 0,
                'reminderHour': time?.hour,
                'reminderMinute': time?.minute,
                'createdAt': DateTime.now().toIso8601String(),
              };

              if (edit == null) {
                final id = await DBHelper().insertHabit(map);
                if (time != null) {
                  // null-safety fix: use !
                  await NotifyHelper.scheduleDaily(id, title, time!.hour, time!.minute);
                }
              } else {
                map['id'] = edit.id;
                await DBHelper().updateHabit(map);
                if (time != null && edit.id != null) {
                  await NotifyHelper.cancel(edit.id!);
                  await NotifyHelper.scheduleDaily(edit.id!, title, time!.hour, time!.minute);
                }
              }

              await _load();
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  // helper to create TimeOfDay from integers
  TimeOfDay? EditTimeOfDay(int? h, int? m) => (h == null || m == null) ? null : TimeOfDay(hour: h, minute: m);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _habits.isEmpty
          ? const Center(child: Text('No habits yet. Tap + to add one.'))
          : ListView.builder(
              itemCount: _habits.length,
              itemBuilder: (c, i) {
                final h = _habits[i];
                return ListTile(
                  title: Text(h.title),
                  subtitle: h.reminderHour != null
                      ? Text('Reminder: ${h.reminderHour!.toString().padLeft(2, '0')}:${h.reminderMinute!.toString().padLeft(2, '0')}')
                      : null,
                  leading: IconButton(
                    icon: Icon(
                      h.isCompleted ? Icons.check_box : Icons.check_box_outline_blank,
                      color: h.isCompleted ? Colors.green : null,
                    ),
                    onPressed: () => _toggle(h),
                  ),
                  trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                    IconButton(icon: const Icon(Icons.edit), onPressed: () => _openAddEdit(h)),
                    IconButton(icon: const Icon(Icons.delete), onPressed: () => _delete(h)),
                  ]),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openAddEdit(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
