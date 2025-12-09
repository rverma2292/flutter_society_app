import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._internal();
  static Database? _database;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'residents.db');

    return await openDatabase(
      path,
      version: 2,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE residents (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT,
            flat TEXT,
            block TEXT,
            mobile TEXT,
            created_at TEXT,
            updated_at TEXT
          )
        ''');
      },
    );
  }

  Future<List<Map<String, dynamic>>> getAllResidents() async {
    final db = await database;
    return await db.query('residents');
  }

  Future<void> insertResident(Map<String, dynamic> data) async {
    final db = await database;
    await db.insert('residents', data,
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> updateResident(Map<String, dynamic> data) async {
    final db = await database;
    await db.update(
      'residents',
      data,
      where: 'id = ?',
      whereArgs: [data['id']],
    );
  }

  Future<void> deleteResident(String id) async {
    final db = await database;
    await db.delete('residents', where: 'id = ?', whereArgs: [id]);
  }
}
