import 'package:flutter/material.dart';
import '../database/db_helper.dart';
import '../models/habit.dart'; // Make sure this matches your file name
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
      notifyId: h.notifyId,
      createdAt: h.createdAt,
    );
    await DBHelper().updateHabit(updated.toMap());
    await _load();
  }

  Future<void> _delete(Habit h) async {
    if (h.id != null) {
      await DBHelper().deleteHabit(h.id!);
      if (h.notifyId != null) await NotifyHelper.cancel(h.notifyId!);
      await _load();
    }
  }

  Future<void> _openAddEdit([Habit? edit]) async {
    final titleCtrl = TextEditingController(text: edit?.title ?? '');
    final notesCtrl = TextEditingController(text: edit?.notes ?? '');
    TimeOfDay? time = (edit?.reminderHour != null && edit?.reminderMinute != null)
        ? TimeOfDay(hour: edit!.reminderHour!, minute: edit.reminderMinute!)
        : null;

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
                    setState(() {});
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

              // Create unique ID for notification
              final notifyId = edit?.notifyId ?? DateTime.now().millisecondsSinceEpoch ~/ 1000;

              final map = {
                'title': title,
                'notes': notesCtrl.text.trim(),
                'isCompleted': (edit?.isCompleted ?? false) ? 1 : 0,
                'reminderHour': time?.hour,
                'reminderMinute': time?.minute,
                'notifyId': notifyId,
                'createdAt': (edit?.createdAt ?? DateTime.now()).toIso8601String(),
              };

              if (edit == null) {
                // Insert New
                await DBHelper().insertHabit(map);
                if (time != null) {
                  await NotifyHelper.scheduleDaily(notifyId, title, time!.hour, time!.minute);
                }
              } else {
                // Update Existing
                map['id'] = edit.id;
                await DBHelper().updateHabit(map);
                // Cancel old and schedule new
                if (edit.notifyId != null) await NotifyHelper.cancel(edit.notifyId!);
                if (time != null) {
                   await NotifyHelper.scheduleDaily(notifyId, title, time!.hour, time!.minute);
                }
              }

              await _load();
              if (mounted) Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _habits.isEmpty
          ? const Center(child: Text('No habits yet. Tap + to add one.'))
          : ListView.builder(
              itemCount: _habits.length,
              itemBuilder: (c, i) {
                final h = _habits[i];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: ListTile(
                    title: Text(h.title, style: TextStyle(
                      decoration: h.isCompleted ? TextDecoration.lineThrough : null,
                      color: h.isCompleted ? Colors.grey : Colors.black
                    )),
                    subtitle: h.reminderHour != null
                        ? Text('⏰ ${h.reminderHour!.toString().padLeft(2, '0')}:${h.reminderMinute!.toString().padLeft(2, '0')}')
                        : null,
                    leading: IconButton(
                      icon: Icon(
                        h.isCompleted ? Icons.check_circle : Icons.circle_outlined,
                        color: h.isCompleted ? Colors.green : Colors.grey,
                      ),
                      onPressed: () => _toggle(h),
                    ),
                    trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                      IconButton(icon: const Icon(Icons.edit, color: Colors.blue), onPressed: () => _openAddEdit(h)),
                      IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => _delete(h)),
                    ]),
                  ),
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