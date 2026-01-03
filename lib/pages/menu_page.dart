import 'package:flutter/material.dart';
import '../database/resident_dao.dart';
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
import 'vehicle_list_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_page.dart';
import 'user_list_page.dart'; // Nayi file jo humne banayi

class MenuPage extends StatefulWidget { // StatefulWidget kiya
  const MenuPage({super.key});

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  String userRole = 'guard'; // Default role
  String userName = '';

  @override
  void initState() {
    super.initState();
    _loadUserInfo(); // App load hote hi role aur naam nikalega
  }

  Future<void> _loadUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    String? storedRole = prefs.getString('userRole');
    String? storedName = prefs.getString('userName');

    print("DEBUG: sharedPreferences Role -> '$storedRole'");
    print("DEBUG: sharedPreferences Name -> '$storedName'");

    setState(() {
      userRole = storedRole ?? 'guard'; // storedRole use karein
      userName = storedName ?? 'User';  // storedName use karein
    });
  }


  Future<void> _handleLogout(BuildContext context) async {
    bool confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Logout"),
        content: const Text("Are you sure you want to logout?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text("Logout"),
          ),
        ],
      ),
    ) ?? false;

    if (confirm) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      if (!mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
            (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Welcome, $userName"), // Dynamic Title
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () => _handleLogout(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Admin only Guard Management
            if (userRole.trim() == 'admin') ...[
              MenuButton(
                title: "Manage Guards (Admin Only)",
                icon: Icons.people,
                color: Colors.blue,
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const UserListPage()));
                },
              ),
              const SizedBox(height: 10),
              MenuButton(
                title: "Outgoing Entry",
                color: Colors.deepOrange,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const GateEntryFormPage(entryType: "Outgoing")),
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
            ],

            MenuButton(
              title: "Incoming Entry",
              color: Colors.teal,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const GateEntryFormPage(entryType: "Incoming")),
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
            const Divider(height: 32),
            MenuButton(
              title: "Resident List",
              color: Colors.deepOrange,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ResidentsPage()),
              ),
            ),
            MenuButton(
              title: "Vehicle List",
              color: Colors.blue,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const VehicleListPage()),
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

            // Seed and Imports: Sirf Admin ke liye
            if (userRole == 'admin') ...[
              const SizedBox(height: 16),
              MenuButton(
                title: "Seed Residents",
                color: Colors.purple,
                onTap: () async {
                  await ResidentDao().seedResidents();
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Residents seeded successfully!")),
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
                      // Wahi method use kiya jo aapki file mein tha
                      await ResidentDao().importResidents(residentsData);

                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("${residentsData.length} Residents imported!")),
                      );
                    }
                  } catch (e) {
                    if (!mounted) return;
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
                    // Wahi static method use kiya jo aapki file mein tha
                    await VehicleImportService.pickAndImportCsv();
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Vehicles imported successfully!"), backgroundColor: Colors.green),
                    );
                  } catch (e) {
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
                    );
                  }
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class MenuButton extends StatelessWidget {
  final String title;
  final VoidCallback onTap;
  final Color color;
  final IconData? icon;

  const MenuButton({super.key, required this.title, required this.onTap, required this.color, this.icon});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ElevatedButton.icon(
        icon: icon != null ? Icon(icon, color: Colors.white) : const SizedBox(),
        label: Text(title, textAlign: TextAlign.center),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          minimumSize: const Size(double.infinity, 50),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        onPressed: onTap,
      ),
    );
  }
}
