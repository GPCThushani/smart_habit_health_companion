// lib/screens/settings_screen.dart
import 'package:flutter/material.dart';
import '../database/db_helper.dart';
import '../models/reminder.dart';
import '../notifications/notify_helper.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  List<Reminder> _list = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final rows = await DBHelper().getAllReminders();
    setState(() => _list = rows.map((r) => Reminder.fromMap(r)).toList());
  }

  Future<void> _addReminder() async {
    final titleCtrl = TextEditingController();
    TimeOfDay? picked;
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Add global reminder (not per-habit)'),
        content: TextField(controller: titleCtrl, decoration: const InputDecoration(hintText: 'Title')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Next')),
        ],
      ),
    );
    if (ok != true) return;
    final title = titleCtrl.text.trim();
    if (title.isEmpty) return;
    picked = await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (picked == null) return;
    final id = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    await DBHelper().insertReminder({'title': title, 'hour': picked.hour, 'minute': picked.minute, 'notifyId': id});
    await NotifyHelper.scheduleDaily(id, title, picked.hour, picked.minute);
    await _load();
  }

  Future<void> _delete(Reminder r) async {
    if (r.id != null) {
      await DBHelper().deleteReminder(r.id!);
      if (r.notifyId != null) await NotifyHelper.cancel(r.notifyId!);
      await _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings & Reminders')),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          ElevatedButton.icon(onPressed: _addReminder, icon: const Icon(Icons.add_alarm), label: const Text('Add Reminder')),
          const SizedBox(height: 12),
          const Text('Your Reminders:', style: TextStyle(fontWeight: FontWeight.bold)),
          ..._list.map((r) => Card(
                child: ListTile(
                  title: Text(r.title),
                  subtitle: Text('${r.hour.toString().padLeft(2, '0')}:${r.minute.toString().padLeft(2, '0')}'),
                  trailing: IconButton(icon: const Icon(Icons.delete), onPressed: () => _delete(r)),
                ),
              )),
          const SizedBox(height: 16),
          ElevatedButton(
              onPressed: () async {
                // optional: clear all DB (dangerous)
                final db = await DBHelper().database;
                await db.delete('habits');
                await db.delete('reminders');
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('All data cleared')));
              },
              child: const Text('Clear All Data (dangerous)')),
        ],
      ),
    );
  }
}
