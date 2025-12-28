import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import 'residents_page.dart';
import 'show_qr_page.dart';
import 'scan_qr_page.dart';
import 'gate_entry_form_page.dart';
import 'gate_entry_list_page.dart';
import 'dart:io';
import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:csv/csv.dart';
import '../services/vehicle_import_service.dart';


class MenuPage extends StatelessWidget {
  const MenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Society App")),
      body: SingleChildScrollView( // Scrollable
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Incoming Button
            MenuButton(
              title: "Incoming Entry",
              color: Colors.teal,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const GateEntryFormPage(entryType: "Incoming")),
              ),
            ),
            // Outgoing Button
            MenuButton(
              title: "Outgoing Entry",
              color: Colors.deepOrange,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const GateEntryFormPage(entryType: "Outgoing")),
              ),
            ),
            MenuButton(
              title: "View Gate Register",
              color: Colors.blueGrey,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const GateEntryListPage()),
              ),
            ),
            const Divider(height: 32), // Visual separation
            MenuButton(
              title: "Resident List",
              color: Colors.blue,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ResidentsPage()),
              ),
            ),
            MenuButton(
              title: "Show QR",
              color: Colors.green,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ShowQRPage()),
              ),
            ),
            MenuButton(
              title: "Scan QR",
              color: Colors.orange,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ScanQRPage()),
              ),
            ),
            const SizedBox(height: 16),
            MenuButton(
              title: "Seed Residents",
              color: Colors.purple,
              onTap: () async {
                await DatabaseHelper.instance.seedResidents();
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Residents seeded successfully!"),
                  ),
                );
              },
            ),
            MenuButton(
              title: "Import Residents (CSV)",
              color: Colors.indigo,
              onTap: () async {
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

                    // Hum yahan direct List of Maps bana rahe hain
                    List<Map<String, dynamic>> residentsData = [];
                    String now = DateTime.now().toIso8601String();

                    for (int i = 1; i < fields.length; i++) {
                      final row = fields[i];
                      if (row.length < 4) continue;

                      residentsData.add({
                        "name": row[0].toString(),
                        "house_num": row[1].toString(),
                        "resident_type": row[2].toString(),
                        "mobile": row[3].toString(),
                        "created_at": now,
                        "updated_at": now,
                      });
                    }

                    // DatabaseHelper ko Map ki list pass karein
                    await DatabaseHelper.instance.importResidents(residentsData);

                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("${residentsData.length} Residents imported!")),
                    );
                  }
                } catch (e) {
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
                  );
                }
              },
            ),
            MenuButton(
              title: "Import Vehicles (CSV)",
              color: Colors.brown,
              onTap: () async {
                try {
                  // Calling the service we just created
                  await VehicleImportService.pickAndImportCsv();

                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Vehicles imported successfully!"),
                      backgroundColor: Colors.green,
                    ),
                  );
                } catch (e) {
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Error: $e"),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

// Reusable colorful button
class MenuButton extends StatelessWidget {
  final String title;
  final VoidCallback onTap;
  final Color color;

 const MenuButton({super.key, required this.title, required this.onTap, required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(vertical: 16),
          minimumSize: Size(double.infinity, 50),
          textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: onTap,
        child: Text(title, textAlign: TextAlign.center),
      ),
    );
  }
}
