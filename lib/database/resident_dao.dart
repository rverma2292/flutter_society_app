import '../database/database_helper.dart';
import '../models/resident.dart';
import 'package:sqflite/sqflite.dart';

class ResidentDao {
  // Get All Residents
  Future<List<Resident>> getAllResidents() async {
    final db = await DatabaseHelper.instance.database;
    final List<Map<String, dynamic>> maps = await db.query('residents');
    return List.generate(maps.length, (i) => Resident.fromMap(maps[i]));
  }

  // Get Paginated Resident
  Future<List<Map<String, dynamic>>> getResidentsPaginated({
    required int limit,
    required int offset,
    String query = ""
  }) async {
    final db = await DatabaseHelper.instance.database;
    return await db.query(
        'residents',
        where: 'name LIKE ? OR house_num LIKE ?',
        whereArgs: ['%$query%', '%$query%'],
        limit: limit,
        offset: offset,
        orderBy: 'name ASC'
    );
  }

  // Insert Resident
  Future<void> insertResidentVX(Map<String, dynamic> data) async {
    final db = await DatabaseHelper.instance.database;
    await db.insert(
        'residents',
        data,
        conflictAlgorithm: ConflictAlgorithm.replace
    );
  }

  // Insert Resident
  Future<int> insertResident(Map<String, dynamic> row) async {
    final db = await DatabaseHelper.instance.database;
    return await db.insert('residents', row);
  }

  // Get Resident Page
  Future<List<Map<String, dynamic>>> getResidentsPage(int limit, int offset, {String query = ""}) async {
    final db = await DatabaseHelper.instance.database;

    if (query.isEmpty) {
      // Original simple pagination
      return await db.query(
        'residents',
        limit: limit,
        offset: offset,
        orderBy: 'id DESC',
      );
    } else {
      // Search with pagination
      return await db.query(
        'residents',
        where: 'name LIKE ? OR house_num LIKE ? OR mobile LIKE ?',
        whereArgs: ['%$query%', '%$query%', '%$query%'],
        limit: limit,
        offset: offset,
        orderBy: 'id DESC',
      );
    }
  }

  // Update Resident
  Future<void> updateResident(Map<String, dynamic> data) async {
    final db = await DatabaseHelper.instance.database;
    await db.update(
      'residents',
      data,
      where: 'id = ?',
      whereArgs: [data['id']],
    );
  }

  // Delete Resident
  Future<void> deleteResident(String id) async {
    final db = await DatabaseHelper.instance.database;
    await db.delete('residents', where: 'id = ?', whereArgs: [id]);
  }

  // Get Total Residents Count
  Future<int> getTotalResidentsCount() async {
    final db = await DatabaseHelper.instance.database;
    final result = await db.rawQuery('SELECT COUNT(*) FROM residents');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  // Seet Default/Dummy Residents
  Future<void> seedResidents() async {
    final db = await DatabaseHelper.instance.database;

    final List<Map<String, dynamic>> seedData = [
      {"name": "Rahul Ranjan", "house_num": "101", "resident_type": "owner", "mobile": "9876543210", "created_at": DateTime.now().toIso8601String(), "updated_at": DateTime.now().toIso8601String()},
      {"name": "Priya Singh", "house_num": "102", "resident_type": "owner", "mobile": "9876543211", "created_at": DateTime.now().toIso8601String(), "updated_at": DateTime.now().toIso8601String()},
      {"name": "Amit Kumar", "house_num": "103", "resident_type": "owner", "mobile": "9876543212", "created_at": DateTime.now().toIso8601String(), "updated_at": DateTime.now().toIso8601String()},
      {"name": "Sneha Sharma", "house_num": "104", "resident_type": "owner", "mobile": "9876543213", "created_at": DateTime.now().toIso8601String(), "updated_at": DateTime.now().toIso8601String()},
      {"name": "Vikas Patel", "house_num": "105", "resident_type": "tenant", "mobile": "9876543214", "created_at": DateTime.now().toIso8601String(), "updated_at": DateTime.now().toIso8601String()},
      {"name": "Neha Verma", "house_num": "106", "resident_type": "tenant", "mobile": "9876543215", "created_at": DateTime.now().toIso8601String(), "updated_at": DateTime.now().toIso8601String()},
      {"name": "Rohit Singh", "house_num": "107", "resident_type": "tenant", "mobile": "9876543216", "created_at": DateTime.now().toIso8601String(), "updated_at": DateTime.now().toIso8601String()},
      {"name": "Anjali Gupta", "house_num": "108", "resident_type": "tenant", "mobile": "9876543217", "created_at": DateTime.now().toIso8601String(), "updated_at": DateTime.now().toIso8601String()},
      {"name": "Sanjay Mehta", "house_num": "109", "resident_type": "owner", "mobile": "9876543218", "created_at": DateTime.now().toIso8601String(), "updated_at": DateTime.now().toIso8601String()},
      {"name": "Pooja Jain", "house_num": "110", "resident_type": "owner", "mobile": "9876543219", "created_at": DateTime.now().toIso8601String(), "updated_at": DateTime.now().toIso8601String()},
      {"name": "Karan Sharma", "house_num": "111", "resident_type": "owner", "mobile": "9876543220", "created_at": DateTime.now().toIso8601String(), "updated_at": DateTime.now().toIso8601String()},
      {"name": "Tanya Roy", "house_num": "112", "resident_type": "owner", "mobile": "9876543221", "created_at": DateTime.now().toIso8601String(), "updated_at": DateTime.now().toIso8601String()},
      {"name": "Manish Agarwal", "house_num": "113", "resident_type": "tenant", "mobile": "9876543222", "created_at": DateTime.now().toIso8601String(), "updated_at": DateTime.now().toIso8601String()},
      {"name": "Ritika Sinha", "house_num": "114", "resident_type": "tenant", "mobile": "9876543223", "created_at": DateTime.now().toIso8601String(), "updated_at": DateTime.now().toIso8601String()},
      {"name": "Ajay Singh", "house_num": "115", "resident_type": "tenant", "mobile": "9876543224", "created_at": DateTime.now().toIso8601String(), "updated_at": DateTime.now().toIso8601String()},
      {"name": "Shreya Nair", "house_num": "116", "resident_type": "tenant", "mobile": "9876543225", "created_at": DateTime.now().toIso8601String(), "updated_at": DateTime.now().toIso8601String()},
      {"name": "Vivek Joshi", "house_num": "117", "resident_type": "owner", "mobile": "9876543226", "created_at": DateTime.now().toIso8601String(), "updated_at": DateTime.now().toIso8601String()},
      {"name": "Anita Desai", "house_num": "118", "resident_type": "owner", "mobile": "9876543227", "created_at": DateTime.now().toIso8601String(), "updated_at": DateTime.now().toIso8601String()},
      {"name": "Ramesh Kumar", "house_num": "119", "resident_type": "owner", "mobile": "9876543228", "created_at": DateTime.now().toIso8601String(), "updated_at": DateTime.now().toIso8601String()},
      {"name": "Priyanka Malhotra", "house_num": "120", "resident_type": "owner", "mobile": "9876543229", "created_at": DateTime.now().toIso8601String(), "updated_at": DateTime.now().toIso8601String()},
    ];

    for (var r in seedData) {
      await db.insert('residents', r);
    }
  }

  // Import Residents
  Future<void> importResidents(List<Map<String, dynamic>> residents) async {
    final db = await DatabaseHelper.instance.database;
    Batch batch = db.batch();
    for (var resident in residents) {
      batch.insert(
        'residents',
        resident,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    await batch.commit(noResult: true);
  }

  // Get All Resident V1
  Future<List<Map<String, dynamic>>> getAllResidentsV1() async {
    final db = await DatabaseHelper.instance.database;
    return await db.query('residents');
  }

  // Get Resident Page V1
  Future<List<Map<String, dynamic>>> getResidentsPageV1(int limit, int offset) async {
    final db = await DatabaseHelper.instance.database;
    return await db.query(
      'residents',
      orderBy: 'id DESC',
      limit: limit,
      offset: offset,
    );
  }

  // Get Resident Page V2
  Future<List<Map<String, dynamic>>> getResidentsPageV2(int limit, int offset) async {
    final db = await DatabaseHelper.instance.database;

    print("QUERY: limit=$limit offset=$offset");

    final result = await db.rawQuery(
        'SELECT id, uuid, name, house_num, resident_type, mobile, image_path, created_at, updated_at FROM residents ORDER BY id DESC LIMIT $limit OFFSET $offset'
    );

    print("RESULT COUNT = ${result.length}");
    print(result);

    return result;
  }
}