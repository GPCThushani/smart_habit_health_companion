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
    _db = await _initDB('wellness.db');
    return _db!;
  }

  Future<Database> _initDB(String filename) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filename);
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int ver) async {
    await db.execute('''
      CREATE TABLE habits(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        notes TEXT,
        isCompleted INTEGER NOT NULL DEFAULT 0,
        reminderHour INTEGER,
        reminderMinute INTEGER,
        createdAt TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE profile(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        age INTEGER,
        weight REAL,
        goals TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE reminders(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        hour INTEGER NOT NULL,
        minute INTEGER NOT NULL,
        notifyId INTEGER
      )
    ''');
  }

  // HABIT CRUD
  Future<int> insertHabit(Map<String, dynamic> row) async {
    final db = await database;
    return await db.insert('habits', row);
  }

  Future<List<Map<String, dynamic>>> getAllHabits() async {
    final db = await database;
    return await db.query('habits', orderBy: 'id DESC');
  }

  Future<int> updateHabit(Map<String, dynamic> row) async {
    final db = await database;
    return await db.update('habits', row, where: 'id = ?', whereArgs: [row['id']]);
  }

  Future<int> deleteHabit(int id) async {
    final db = await database;
    return await db.delete('habits', where: 'id = ?', whereArgs: [id]);
  }

  // PROFILE
  Future<int> upsertProfile(Map<String, dynamic> row) async {
    final db = await database;
    final list = await db.query('profile');
    if (list.isEmpty) {
      return await db.insert('profile', row);
    } else {
      return await db.update('profile', row, where: 'id = ?', whereArgs: [list.first['id']]);
    }
  }

  Future<Map<String, dynamic>?> getProfile() async {
    final db = await database;
    final list = await db.query('profile', limit: 1);
    if (list.isEmpty) return null;
    return list.first;
  }

  // REMINDERS
  Future<int> insertReminder(Map<String, dynamic> row) async {
    final db = await database;
    return await db.insert('reminders', row);
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
