// lib/screens/profile_screen.dart
import 'package:flutter/material.dart';
import '../database/db_helper.dart';
import 'home_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _name = TextEditingController();
  final _age = TextEditingController();
  final _weight = TextEditingController();
  final _goals = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final data = await DBHelper().getProfile();
    if (data != null) {
      setState(() {
        _name.text = data['name'] ?? '';
        _age.text = data['age']?.toString() ?? '';
        _weight.text = data['weight']?.toString() ?? '';
        _goals.text = data['goals'] ?? '';
      });
    }
  }

  Future<void> _save() async {
    final map = {
      'name': _name.text.trim(),
      'age': int.tryParse(_age.text),
      'weight': double.tryParse(_weight.text),
      'goals': _goals.text.trim(),
    };
    await DBHelper().upsertProfile(map);
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Your Profile')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          TextField(controller: _name, decoration: const InputDecoration(labelText: 'Name')),
          TextField(controller: _age, decoration: const InputDecoration(labelText: 'Age'), keyboardType: TextInputType.number),
          TextField(controller: _weight, decoration: const InputDecoration(labelText: 'Weight (kg)'), keyboardType: TextInputType.number),
          TextField(controller: _goals, decoration: const InputDecoration(labelText: 'Goals')),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: _save, child: const Text('Save & Continue')),
        ]),
      ),
    );
  }
}
