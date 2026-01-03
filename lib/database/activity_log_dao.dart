import '../models/activity_log_model.dart';
import 'database_helper.dart';

class ActivityLogDao {
  // Database helper
  final dbHelper = DatabaseHelper.instance;

  // To get all logs
  Future<List<ActivityLogModel>> getAllLogs() async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT activity_logs.*, users.full_name as guard_name, residents.name as resident_name
      FROM activity_logs
      LEFT JOIN users ON activity_logs.user_id = users.id
      LEFT JOIN residents ON activity_logs.reference_id = residents.id
      ORDER BY activity_logs.id DESC
    ''');

    return List.generate(maps.length, (i) => ActivityLogModel.fromMap(maps[i]));
  }

  // To get logs by resident
  Future<List<ActivityLogModel>> getLogsByResident(int referenceId) async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'activity_logs',
      where: 'reference_id = ?',
      whereArgs: [referenceId],
      orderBy: 'id DESC',
    );
    return List.generate(maps.length, (i) => ActivityLogModel.fromMap(maps[i]));
  }

  // To insert Log
  Future<void> insertLog(ActivityLogModel log) async {
    final db = await dbHelper.database;
    await db.insert('activity_logs', log.toMap());
  }

}
