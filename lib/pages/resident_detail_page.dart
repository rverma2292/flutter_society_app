import 'dart:io';
import 'package:flutter/material.dart';
import '../models/resident_vehicle_model.dart'; // New Import
import '../database/resident_vehicle_dao.dart'; // New Import

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

            // --- START OF VEHICLE SECTION ---
            const Divider(height: 40),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "VEHICLE DETAILS",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.green),
              ),
            ),
            const SizedBox(height: 10),

            FutureBuilder<List<ResidentVehicle>>(
              // Note: Ensure your resident Map has 'id'
              future: ResidentVehicleDao().getVehiclesByResidentId(resident['id']),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const LinearProgressIndicator(color: Colors.green);
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: Text("No vehicles registered", style: TextStyle(color: Colors.grey)),
                  );
                }

                final vehicles = snapshot.data!;
                return Column(
                  children: vehicles.map((v) => _vehicleItem(v)).toList(),
                );
              },
            ),
            // --- END OF VEHICLE SECTION ---

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

  // New Helper Widget for individual vehicle display
  Widget _vehicleItem(ResidentVehicle vehicle) {
    // 1. Logic to choose icon based on vehicle type
    IconData vehicleIcon;
    String type = (vehicle.vehicleType ?? "").toLowerCase();

    if (type.contains("bike") || type.contains("scooter") || type.contains("two")) {
      vehicleIcon = Icons.motorcycle;
    } else if (type.contains("pickup") || type.contains("truck") || type.contains("van")) {
      vehicleIcon = Icons.local_shipping;
    } else {
      vehicleIcon = Icons.directions_car;
    }

    // 2. Logic to parse color string to Flutter Color
    // Defaults to transparent if color is not recognized
    Color displayColor;
    try {
      String colorName = (vehicle.vehicleColor ?? "transparent").toLowerCase();
      switch (colorName) {
        case 'red': displayColor = Colors.red; break;
        case 'blue': displayColor = Colors.blue; break;
        case 'white': displayColor = Colors.white; break;
        case 'black': displayColor = Colors.black; break;
        case 'silver': displayColor = Colors.grey[400]!; break;
        case 'grey': displayColor = Colors.grey; break;
        case 'yellow': displayColor = Colors.yellow; break;
        case 'green': displayColor = Colors.green; break;
        default: displayColor = Colors.transparent;
      }
    } catch (e) {
      displayColor = Colors.transparent;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        children: [
          // Dynamic Icon
          Icon(vehicleIcon, color: Colors.green, size: 28),
          const SizedBox(width: 12),

          // Vehicle Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  vehicle.vehicleNumber.toUpperCase(),
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  "${vehicle.vehicleType ?? ''} ${vehicle.vehicleModel ?? ''}".trim(),
                  style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                ),
              ],
            ),
          ),

          // Color Indicator Box
          if (vehicle.vehicleColor != null)
            Column(
              children: [
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: displayColor,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: Colors.grey[400]!, width: 0.5),
                    boxShadow: [
                      if (displayColor != Colors.transparent)
                        BoxShadow(color: Colors.black12, blurRadius: 2, offset: Offset(0, 1))
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  vehicle.vehicleColor!,
                  style: const TextStyle(fontSize: 10, color: Colors.grey),
                ),
              ],
            ),
        ],
      ),
    );
  }


  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Colors.green.withValues(alpha: 0.1),
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
