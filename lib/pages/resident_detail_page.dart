import 'dart:io';
import 'package:flutter/material.dart';

class ResidentDetailsPage extends StatelessWidget {
  final Map<String, dynamic> resident;

  const ResidentDetailsPage({super.key, required this.resident});

  // Helper method to show full screen image
  void _viewFullImage(BuildContext context) {
    if (resident['image_path'] == null) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            iconTheme: const IconThemeData(color: Colors.white),
          ),
          body: Center(
            child: InteractiveViewer(
              child: Image.file(
                File(resident['image_path']),
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Access Granted"),
        backgroundColor: Colors.green, // Green theme for success
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // 1. Large Profile Image for Verification
            Center(
              child: GestureDetector(
                onTap: () => _viewFullImage(context),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.green, width: 3),
                  ),
                  child: CircleAvatar(
                    radius: 80,
                    backgroundColor: Colors.grey[200],
                    backgroundImage: (resident['image_path'] != null)
                        ? FileImage(File(resident['image_path']))
                        : null,
                    child: (resident['image_path'] == null)
                        ? const Icon(Icons.person, size: 80, color: Colors.grey)
                        : null,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // 2. Main Name Header
            Text(
              resident['name'].toString().toUpperCase(),
              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            Text(
              "Resident ID: ${resident['uuid'].toString().substring(0, 8)}...",
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),

            const Divider(height: 40),

            // 3. Information Cards
            _infoRow(Icons.home, "House Number", resident['house_num']),
            _infoRow(Icons.people, "Resident Type", resident['resident_type'].toString().toUpperCase()),
            _infoRow(Icons.phone, "Mobile Number", resident['mobile'] ?? "Not Provided"),

            const SizedBox(height: 40),

            // 4. Action Button
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.qr_code_scanner),
                label: const Text("SCAN NEXT RESIDENT",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Colors.green.withOpacity(0.1),
            child: Icon(icon, color: Colors.green),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
              Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            ],
          ),
        ],
      ),
    );
  }
}
