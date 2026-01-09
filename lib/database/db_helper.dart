// lib/database/db_helper.dart
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHelper {
  static final DBHelper _instance = DBHelper._internal();
  factory DBHelper() => _instance;
  DBHelper._internal();

  static Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDB();
    return _db!;
  }

  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'habit_app.db');

    return await openDatabase(
      path,
      version: 2,
      onCreate: _createTables,
      onUpgrade: (db, oldV, newV) async {
        await db.execute('DROP TABLE IF EXISTS profile');
        await db.execute('DROP TABLE IF EXISTS habits');
        await db.execute('DROP TABLE IF EXISTS reminders');
        await _createTables(db, newV);
      },
    );
  }

  Future<void> _createTables(Database db, int version) async {
    await db.execute('''
      CREATE TABLE profile (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        age INTEGER,
        weight REAL,
        goals TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE habits (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        notes TEXT,
        isCompleted INTEGER DEFAULT 0,
        reminderHour INTEGER,
        reminderMinute INTEGER,
        notifyId INTEGER,
        createdAt TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE reminders (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        hour INTEGER,
        minute INTEGER,
        notifyId INTEGER
      )
    ''');
  }

  // ---------------- Profile ----------------
  Future<Map<String, dynamic>?> getProfile() async {
    final db = await database;
    final rows = await db.query('profile', limit: 1);
    if (rows.isNotEmpty) return rows.first;
    return null;
  }

  Future<void> updateProfile(Map<String, dynamic> map) async {
    final db = await database;
    final rows = await db.query('profile', limit: 1);
    if (rows.isEmpty) {
      await db.insert('profile', map);
    } else {
      await db.update('profile', map,
          where: 'id = ?', whereArgs: [rows.first['id']]);
    }
  }

  // ---------------- Habits ----------------
  Future<int> insertHabit(Map<String, dynamic> map) async {
    final db = await database;
    if (map['isCompleted'] is bool) map['isCompleted'] = map['isCompleted'] ? 1 : 0;
    map['createdAt'] ??= DateTime.now().toIso8601String();
    return await db.insert('habits', map);
  }

  Future<int> updateHabit(Map<String, dynamic> map) async {
    final db = await database;
    final id = map['id'] as int?;
    if (id == null) return 0;
    if (map['isCompleted'] is bool) map['isCompleted'] = map['isCompleted'] ? 1 : 0;
    return await db.update('habits', map, where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Map<String, dynamic>>> getAllHabits() async {
    final db = await database;
    return await db.query('habits', orderBy: 'createdAt DESC');
  }

  Future<int> deleteHabit(int id) async {
    final db = await database;
    return await db.delete('habits', where: 'id = ?', whereArgs: [id]);
  }

  // ---------------- Reminders ----------------
  Future<int> insertReminder(Map<String, dynamic> map) async {
    final db = await database;
    return await db.insert('reminders', map);
  }

  Future<List<Map<String, dynamic>>> getAllReminders() async {
    final db = await database;
    return await db.query('reminders', orderBy: 'id DESC');
  }

  Future<int> deleteReminder(int id) async {
    final db = await database;
    return await db.delete('reminders', where: 'id = ?', whereArgs: [id]);
  }
}
