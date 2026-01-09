import 'package:flutter/material.dart';
import '../database/db_helper.dart';
import '../models/reminder.dart'; // Make sure this matches your file name
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
    
    // Simple Dialog to get title
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Add General Reminder'),
        content: TextField(
          controller: titleCtrl, 
          decoration: const InputDecoration(hintText: 'e.g. Drink Water')
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
               if (titleCtrl.text.isNotEmpty) {
                 Navigator.pop(context);
                 picked = await showTimePicker(context: context, initialTime: TimeOfDay.now());
               }
            }, 
            child: const Text('Next')
          ),
        ],
      ),
    );

    if (picked == null) return;
    
    final title = titleCtrl.text.trim();
    final notifyId = DateTime.now().millisecondsSinceEpoch ~/ 1000;

    // Save to Local DB
    await DBHelper().insertReminder({
      'title': title, 
      'hour': picked!.hour, 
      'minute': picked!.minute, 
      'notifyId': notifyId
    });

    // Schedule Notification
    await NotifyHelper.scheduleDaily(notifyId, title, picked!.hour, picked!.minute);
    
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
          ElevatedButton.icon(
            onPressed: _addReminder, 
            icon: const Icon(Icons.add_alarm), 
            label: const Text('Add New Reminder')
          ),
          const SizedBox(height: 20),
          const Text('Active Reminders:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: 10),
          
          ..._list.map((r) => Card(
            elevation: 2,
            child: ListTile(
              leading: const Icon(Icons.alarm, color: Colors.teal),
              title: Text(r.title),
              subtitle: Text('${r.hour.toString().padLeft(2, '0')}:${r.minute.toString().padLeft(2, '0')}'),
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red), 
                onPressed: () => _delete(r)
              ),
            ),
          )),

          if (_list.isEmpty)
            const Padding(
              padding: EdgeInsets.all(20.0),
              child: Text("No reminders set yet.", style: TextStyle(color: Colors.grey)),
            ),

          const Divider(height: 40),
          
          TextButton.icon(
            icon: const Icon(Icons.delete_forever, color: Colors.red),
            label: const Text('Clear All Data (Reset App)', style: TextStyle(color: Colors.red)),
            onPressed: () async {
              // Confirmation Dialog
              bool confirm = await showDialog(
                context: context, 
                builder: (c) => AlertDialog(
                  title: const Text('Reset App?'),
                  content: const Text('This will delete all habits and reminders.'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Cancel')),
                    TextButton(onPressed: () => Navigator.pop(c, true), child: const Text('Delete')),
                  ]
                )
              ) ?? false;

              if (confirm) {
                final db = await DBHelper().database;
                await db.delete('habits');
                await db.delete('reminders');
                await db.delete('profile');
                if (mounted) {
                   ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('All data cleared')));
                   _load();
                }
              }
            },
          ),
        ],
      ),
    );
  }
}