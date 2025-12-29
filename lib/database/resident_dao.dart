import '../database/database_helper.dart';
import '../models/resident.dart';

class ResidentDao {
  Future<List<Resident>> getAllResidents() async {
    final db = await DatabaseHelper.instance.database;
    final List<Map<String, dynamic>> maps = await db.query('residents');
    return List.generate(maps.length, (i) => Resident.fromMap(maps[i]));
  }

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

}
