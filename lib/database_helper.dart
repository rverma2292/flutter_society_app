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
      version: 3,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE residents (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT,
            house_num TEXT,
            resident_type TEXT,
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

  Future<List<Map<String, dynamic>>> getResidentsPageV1(int limit, int offset) async {
    final db = await database;
    return await db.query(
      'residents',
      orderBy: 'id DESC',
      limit: limit,
      offset: offset,
    );
  }

  Future<List<Map<String, dynamic>>> getResidentsPage(int limit, int offset) async {
    final db = await database;

    print("QUERY: limit=$limit offset=$offset");

    final result = await db.rawQuery(
        'SELECT id, name, house_num, resident_type, mobile, created_at, updated_at FROM residents ORDER BY id DESC LIMIT $limit OFFSET $offset'
    );

    print("RESULT COUNT = ${result.length}");
    print(result);

    return result;
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


  Future<void> seedResidents() async {
    final db = await database; // get your database instance

    final List<Map<String, dynamic>> seedData = [
      {"name": "Rahul Ranjan", "house_num": "101", "resident_type": "A", "mobile": "9876543210", "created_at": DateTime.now().toIso8601String(), "updated_at": DateTime.now().toIso8601String()},
      {"name": "Priya Singh", "house_num": "102", "resident_type": "A", "mobile": "9876543211", "created_at": DateTime.now().toIso8601String(), "updated_at": DateTime.now().toIso8601String()},
      {"name": "Amit Kumar", "house_num": "103", "resident_type": "A", "mobile": "9876543212", "created_at": DateTime.now().toIso8601String(), "updated_at": DateTime.now().toIso8601String()},
      {"name": "Sneha Sharma", "house_num": "104", "resident_type": "A", "mobile": "9876543213", "created_at": DateTime.now().toIso8601String(), "updated_at": DateTime.now().toIso8601String()},
      {"name": "Vikas Patel", "house_num": "105", "resident_type": "B", "mobile": "9876543214", "created_at": DateTime.now().toIso8601String(), "updated_at": DateTime.now().toIso8601String()},
      {"name": "Neha Verma", "house_num": "106", "resident_type": "B", "mobile": "9876543215", "created_at": DateTime.now().toIso8601String(), "updated_at": DateTime.now().toIso8601String()},
      {"name": "Rohit Singh", "house_num": "107", "resident_type": "B", "mobile": "9876543216", "created_at": DateTime.now().toIso8601String(), "updated_at": DateTime.now().toIso8601String()},
      {"name": "Anjali Gupta", "house_num": "108", "resident_type": "B", "mobile": "9876543217", "created_at": DateTime.now().toIso8601String(), "updated_at": DateTime.now().toIso8601String()},
      {"name": "Sanjay Mehta", "house_num": "109", "resident_type": "C", "mobile": "9876543218", "created_at": DateTime.now().toIso8601String(), "updated_at": DateTime.now().toIso8601String()},
      {"name": "Pooja Jain", "house_num": "110", "resident_type": "C", "mobile": "9876543219", "created_at": DateTime.now().toIso8601String(), "updated_at": DateTime.now().toIso8601String()},
      {"name": "Karan Sharma", "house_num": "111", "resident_type": "C", "mobile": "9876543220", "created_at": DateTime.now().toIso8601String(), "updated_at": DateTime.now().toIso8601String()},
      {"name": "Tanya Roy", "house_num": "112", "resident_type": "C", "mobile": "9876543221", "created_at": DateTime.now().toIso8601String(), "updated_at": DateTime.now().toIso8601String()},
      {"name": "Manish Agarwal", "house_num": "113", "resident_type": "D", "mobile": "9876543222", "created_at": DateTime.now().toIso8601String(), "updated_at": DateTime.now().toIso8601String()},
      {"name": "Ritika Sinha", "house_num": "114", "resident_type": "D", "mobile": "9876543223", "created_at": DateTime.now().toIso8601String(), "updated_at": DateTime.now().toIso8601String()},
      {"name": "Ajay Singh", "house_num": "115", "resident_type": "D", "mobile": "9876543224", "created_at": DateTime.now().toIso8601String(), "updated_at": DateTime.now().toIso8601String()},
      {"name": "Shreya Nair", "house_num": "116", "resident_type": "D", "mobile": "9876543225", "created_at": DateTime.now().toIso8601String(), "updated_at": DateTime.now().toIso8601String()},
      {"name": "Vivek Joshi", "house_num": "117", "resident_type": "E", "mobile": "9876543226", "created_at": DateTime.now().toIso8601String(), "updated_at": DateTime.now().toIso8601String()},
      {"name": "Anita Desai", "house_num": "118", "resident_type": "E", "mobile": "9876543227", "created_at": DateTime.now().toIso8601String(), "updated_at": DateTime.now().toIso8601String()},
      {"name": "Ramesh Kumar", "house_num": "119", "resident_type": "E", "mobile": "9876543228", "created_at": DateTime.now().toIso8601String(), "updated_at": DateTime.now().toIso8601String()},
      {"name": "Priyanka Malhotra", "house_num": "120", "resident_type": "E", "mobile": "9876543229", "created_at": DateTime.now().toIso8601String(), "updated_at": DateTime.now().toIso8601String()},
    ];

    for (var r in seedData) {
      await db.insert('residents', r);
    }
  }
}
