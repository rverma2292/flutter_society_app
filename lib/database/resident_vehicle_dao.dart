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

  // Get All Vehicles
  Future<List<ResidentVehicle>> getAllVehicles() async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('residents_vehicles', orderBy: 'created_at DESC');
    print("All Vehicles: $maps");
    return List.generate(maps.length, (i) {
      return ResidentVehicle.fromMap(maps[i]);
    });
  }

  // Get All Vehicles with Resident Names
  Future<List<Map<String, dynamic>>> getAllVehiclesWithResidentNames() async {
    final db = await dbHelper.database;
    // This SQL joins the vehicles table with the residents table
    return await db.rawQuery('''
    SELECT v.*, r.name as resident_name, r.house_num 
    FROM $tableName v
    JOIN residents r ON v.resident_id = r.id
    ORDER BY v.created_at DESC
  ''');
  }

  Future<List<Map<String, dynamic>>> getVehiclesPaginated({required int limit, required int offset}) async {
    final db = await dbHelper.database;
    return await db.rawQuery('''
    SELECT v.*, r.name as resident_name, r.house_num 
    FROM residents_vehicles v
    JOIN residents r ON v.resident_id = r.id
    ORDER BY v.created_at DESC
    LIMIT ? OFFSET ?
  ''', [limit, offset]);
  }

  // Get the total count of all vehicles
  Future<int> getTotalVehicleCount() async {
    final db = await dbHelper.database;
    final result = await db.rawQuery('SELECT COUNT(*) as total FROM $tableName');
    return Sqflite.firstIntValue(result) ?? 0;
  }


}
