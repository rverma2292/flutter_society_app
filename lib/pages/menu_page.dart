import 'package:flutter/material.dart';

// import '../widgets/menu_button.dart';
import '../database/database_helper.dart';
import 'residents_page.dart';
import 'show_qr_page.dart';
import 'scan_qr_page.dart';
import 'gate_entry_form_page.dart';
import 'gate_entry_list_page.dart';

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
