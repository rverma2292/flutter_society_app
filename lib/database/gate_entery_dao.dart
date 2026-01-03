import 'package:sqflite/sqflite.dart';
import '../models/gate_entry_model.dart';
import 'database_helper.dart';
import '../utils/session_manager.dart';

class GateEntryDao {
  // DatabaseHelper Instance
  final dbHelper = DatabaseHelper.instance;

  // 1. Insert
  Future<int> insertGateEntryV1(GateEntry entry) async {
    final db = await dbHelper.database;
    return await db.insert('gate_entries', entry.toMap());
  }

  // 2. Fetch All (Optimized with Error Handling)
  Future<List<GateEntry>> getAllEntries() async {
    try {
      // use of dbHelper.database instead of db
      final db = await dbHelper.database;

      // Querying with Descending Order (Latest First)
      final List<Map<String, dynamic>> maps = await db.query(
          'gate_entries',
          orderBy: 'id DESC'
      );

      // if no data found, return empty list
      if (maps.isEmpty) return [];

      // Efficiently mapping data using .map() instead of List.generate
      return maps.map((map) => GateEntry.fromMap(map)).toList();

    } catch (e) {
      // App will not crash if any error occurs
      print("Database Error: $e");
      return [];
    }
  }

  // 3. Update Exit Time
  Future<int> updateExitTimeV1(int id, String exitTime) async {
    final db = await dbHelper.database;
    return await db.update(
      'gate_entries',
      {
        'exit_time': exitTime,
        'updated_at': DateTime.now().toIso8601String()
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> updateExitTime(int id, String exitTime, int userId, String personName) async {
    final db = await dbHelper.database;
    final String now = DateTime.now().toIso8601String();

    // 1. Exit time update karein
    int result = await db.update(
      'gate_entries',
      {
        'exit_time': exitTime,
        'updated_at': now
      },
      where: 'id = ?',
      whereArgs: [id],
    );

    // 2. Activity Log insert karein (Taki pata chale kisne exit mark kiya)
    if (result > 0) {
      await db.insert('activity_logs', {
        'user_id': userId,
        'resident_id': id, // Entry ID as reference
        'action': "VISITOR_EXIT: $personName marked out",
        'timestamp': now,
      });
    }

    return result;
  }


  // Insert: Will return New ID
  Future<int> insertGateEntry(Map<String, dynamic> row) async {
    final db = await dbHelper.database;
    return await db.insert('gate_entries', row);
  }

// Update: Based on ID
  Future<int> updateGateEntry(Map<String, dynamic> row) async {
    final db = await dbHelper.database;
    return await db.update(
      'gate_entries',
      row,
      where: 'id = ?',
      whereArgs: [row['id']],
    );
  }

}
