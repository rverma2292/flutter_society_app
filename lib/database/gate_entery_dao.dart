import 'package:sqflite/sqflite.dart';
import '../models/gate_entry_model.dart';
import 'database_helper.dart';

class GateEntryDao {
  // DatabaseHelper ka instance use karenge
  final dbHelper = DatabaseHelper.instance;

  // 1. Insert
  Future<int> insertGateEntry(GateEntry entry) async {
    final db = await dbHelper.database;
    return await db.insert('gate_entries', entry.toMap());
  }

  // 2. Fetch All (Optimized with Error Handling)
  Future<List<GateEntry>> getAllEntries() async {
    try {
      // Aapke code ke variable 'dbHelper' ka hi use kiya hai
      final db = await dbHelper.database;

      // Querying with Descending Order (Latest First)
      final List<Map<String, dynamic>> maps = await db.query(
          'gate_entries',
          orderBy: 'id DESC'
      );

      // Agar data nahi hai to khali list return karega
      if (maps.isEmpty) return [];

      // Efficiently mapping data using .map() instead of List.generate
      return maps.map((map) => GateEntry.fromMap(map)).toList();

    } catch (e) {
      // Kisi bhi error ki surat mein app crash nahi hogi
      print("Database Error: $e");
      return [];
    }
  }


  // 3. Update Exit Time
  Future<int> updateExitTime(int id, String exitTime) async {
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
}
