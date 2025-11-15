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
      version: 1,
      onCreate: _createTables,
    );
  }

  Future<void> _createTables(Database db, int version) async {
    await db.execute('''
      CREATE TABLE profile (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        age INTEGER,
        gender TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE habits (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT,
        description TEXT,
        hour INTEGER,
        minute INTEGER
      )
    ''');

    await db.execute('''
      CREATE TABLE reminders (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT,
        hour INTEGER,
        minute INTEGER,
        notifyId INTEGER
      )
    ''');
  }

  // ---------------- PROFILE ----------------

  Future<Map<String, dynamic>?> getProfile() async {
    final db = await database;
    final data = await db.query('profile');
    return data.isNotEmpty ? data.first : null;
  }

  Future<void> upsertProfile(Map<String, dynamic> map) async {
    final db = await database;
    final exists = await db.query('profile');

    if (exists.isEmpty) {
      await db.insert('profile', map);
    } else {
      await db.update('profile', map);
    }
  }

  // ---------------- HABITS ----------------

  Future<List<Map<String, dynamic>>> getAllHabits() async {
    final db = await database;
    return await db.query('habits');
  }

  Future<int> insertHabit(Map<String, dynamic> map) async {
    final db = await database;
    return await db.insert('habits', map);
  }

  Future<int> updateHabit(Map<String, dynamic> map) async {
    final db = await database;
    return await db.update(
      'habits',
      map,
      where: 'id = ?',
      whereArgs: [map['id']],
    );
  }

  Future<int> deleteHabit(int id) async {
    final db = await database;
    return await db.delete('habits', where: 'id = ?', whereArgs: [id]);
  }

  // ---------------- REMINDERS ----------------

  Future<List<Map<String, dynamic>>> getAllReminders() async {
    final db = await database;
    return await db.query('reminders');
  }

  Future<int> insertReminder(Map<String, dynamic> map) async {
    final db = await database;
    return await db.insert('reminders', map);
  }

  Future<int> deleteReminder(int id) async {
    final db = await database;
    return await db.delete('reminders', where: 'id = ?', whereArgs: [id]);
  }
}
