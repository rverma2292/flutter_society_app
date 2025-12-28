import 'dart:convert';
import 'dart:io';
import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import '../models/resident_vehicle_model.dart'; // Ensure this path is correct
import '../database/resident_vehicle_dao.dart';

class VehicleImportService {

  static Future<void> pickAndImportCsv() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
      );

      if (result != null && result.files.single.path != null) {
        File file = File(result.files.single.path!);

        final input = file.openRead();
        final fields = await input
            .transform(utf8.decoder)
            .transform(const CsvToListConverter())
            .toList();

        if (fields.isEmpty) return;

        List<ResidentVehicle> vehiclesToImport = [];
        String now = DateTime.now().toIso8601String();

        // Start from i = 1 to skip the CSV header row
        for (int i = 1; i < fields.length; i++) {
          final row = fields[i];

          // Minimum required: resident_id (row[0]) and vehicle_number (row[1])
          if (row.length < 2) continue;

          vehiclesToImport.add(ResidentVehicle(
            residentId: int.tryParse(row[0].toString()) ?? 0,
            vehicleNumber: row[1].toString(),
            // Other fields are optional: check length before accessing index
            vehicleType: row.length > 2 ? row[2].toString() : null,
            vehicleColor: row.length > 3 ? row[3].toString() : null,
            vehicleModel: row.length > 4 ? row[4].toString() : null,
            createdAt: now,
            updatedAt: now,
          ));
        }

        if (vehiclesToImport.isNotEmpty) {
          // Using the DAO instance to call the import method
          await ResidentVehicleDao().importVehicles(
            vehiclesToImport.map((v) => v.toMap()).toList(),
          );
          print("Imported ${vehiclesToImport.length} vehicles successfully!");
        }
      }
    } catch (e) {
      print("Error during vehicle import: $e");
      rethrow;
    }
  }
}
