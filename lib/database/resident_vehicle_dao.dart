import '../models/resident_vehicle_model.dart'; // Ensure this matches your model file name
import 'database_helper.dart';
import 'package:sqflite/sqflite.dart';

class ResidentVehicleDao {
  final dbHelper = DatabaseHelper.instance;
  final String tableName = 'residents_vehicles';

  // Insert a new vehicle
  Future<int> insertVehicle(ResidentVehicle vehicle) async {
    final db = await dbHelper.database;
    return await db.insert(tableName, vehicle.toMap());
  }

  // Get all vehicles for a specific resident
  Future<List<ResidentVehicle>> getVehiclesByResidentId(int residentId) async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      where: 'resident_id = ?',
      whereArgs: [residentId],
    );

    return List.generate(maps.length, (i) => ResidentVehicle.fromMap(maps[i]));
  }

  // Get a single vehicle by its ID
  Future<ResidentVehicle?> getVehicleById(int id) async {
    final db = await dbHelper.database;
    final maps = await db.query(
      tableName,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return ResidentVehicle.fromMap(maps.first);
    }
    return null;
  }

  // Update vehicle information
  Future<int> updateVehicle(ResidentVehicle vehicle) async {
    final db = await dbHelper.database;

    // Create map and update the updated_at timestamp
    Map<String, dynamic> row = vehicle.toMap();
    row['updated_at'] = DateTime.now().toIso8601String();

    return await db.update(
      tableName,
      row,
      where: 'id = ?',
      whereArgs: [vehicle.id],
    );
  }

  // Delete a vehicle
  Future<int> deleteVehicle(int id) async {
    final db = await dbHelper.database;
    return await db.delete(
      tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Search vehicle by number (useful for security gate lookups)
  Future<ResidentVehicle?> findByVehicleNumber(String vehicleNumber) async {
    final db = await dbHelper.database;
    final maps = await db.query(
      tableName,
      where: 'vehicle_number = ?',
      whereArgs: [vehicleNumber],
    );

    if (maps.isNotEmpty) {
      return ResidentVehicle.fromMap(maps.first);
    }
    return null;
  }

  Future<void> importVehicles(List<Map<String, dynamic>> vehicleData) async {
    final db = await dbHelper.database;
    Batch batch = db.batch();

    for (var vehicle in vehicleData) {
      batch.insert(
        tableName,
        vehicle,
        // Optional: use replace if you want to overwrite existing vehicle numbers
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    await batch.commit(noResult: true);
  }
}
