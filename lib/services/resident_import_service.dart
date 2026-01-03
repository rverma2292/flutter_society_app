import 'dart:convert';
import 'dart:io';
import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import '../models/resident.dart';
import '../database/resident_dao.dart';

class ResidentImportService {

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

        List<Resident> residentsToImport = [];
        String now = DateTime.now().toIso8601String();

        for (int i = 1; i < fields.length; i++) {
          final row = fields[i];
          if (row.length < 4) continue;

          residentsToImport.add(Resident(
            name: row[0].toString(),
            house_num: row[1].toString(),
            resident_type: row[2].toString(),
            mobile: row[3].toString(),
            created_at: now,
            updated_at: now,
          ));
        }

        // --- FIXED LINE ---
        await ResidentDao().importResidents(
          residentsToImport.map((r) => r.toMap()).toList(),
        );
        // ------------------

        print("Imported ${residentsToImport.length} residents successfully!");
      }
    } catch (e) {
      print("Error during import: $e");
      rethrow;
    }
  }
}
