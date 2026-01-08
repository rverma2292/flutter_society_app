import 'dart:io';
import 'package:flutter/material.dart';
import '../models/resident_vehicle_model.dart';
import '../database/resident_vehicle_dao.dart';
import 'resident_vehicle_form_page.dart';
import '../utils/session_manager.dart';

class ResidentDetailsPage extends StatefulWidget {
  final Map<String, dynamic> resident;

  const ResidentDetailsPage({super.key, required this.resident});

  @override
  State<ResidentDetailsPage> createState() => _ResidentDetailsPageState();
}

class _ResidentDetailsPageState extends State<ResidentDetailsPage> {
  // Key to force FutureBuilder to refresh when we call setState
  Key _futureBuilderKey = UniqueKey();
  String? _currentUserRole;

  @override
  void initState() {
    super.initState();
    _checkUserRole(); // Role check function call karein
  }

  Future<void> _checkUserRole() async {
    final user = await SessionManager.getCurrentUser();
    setState(() {
      _currentUserRole = user['role']; // 'admin' ya 'guard'
    });
  }

  void _refreshData() {
    setState(() {
      _futureBuilderKey = UniqueKey();
    });
  }

  void _viewFullImage(BuildContext context) {
    if (widget.resident['image_path'] == null) return;

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
                File(widget.resident['image_path']),
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
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // 1. Large Profile Image
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
                    backgroundImage: (widget.resident['image_path'] != null)
                        ? FileImage(File(widget.resident['image_path']))
                        : null,
                    child: (widget.resident['image_path'] == null)
                        ? const Icon(Icons.person, size: 80, color: Colors.grey)
                        : null,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // 2. Name Header
            Text(
              widget.resident['name'].toString().toUpperCase(),
              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            Text(
              "Resident ID: ${widget.resident['uuid']?.toString().substring(0, 8) ?? 'N/A'}...",
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),

            const Divider(height: 40),

            // 3. Information Rows
            _infoRow(Icons.home, "House Number", widget.resident['house_num']),
            _infoRow(Icons.people, "Resident Type", widget.resident['resident_type'].toString().toUpperCase()),
            _infoRow(Icons.phone, "Mobile Number", widget.resident['mobile'] ?? "Not Provided"),

            // --- VEHICLE SECTION ---
            const Divider(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "VEHICLE DETAILS",
                  style: TextStyle(fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.green),
                ),
                // SIRF ADMIN KO DIKHEGA
                if (_currentUserRole == 'admin')
                  TextButton.icon(
                    onPressed: () async {
                      final refresh = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              ResidentVehicleFormPage(
                                  residentId: widget.resident['id']),
                        ),
                      );
                      if (refresh == true) _refreshData();
                    },
                    icon: const Icon(Icons.add, size: 18, color: Colors.green),
                    label: const Text(
                        "ADD", style: TextStyle(color: Colors.green)),
                  ),
              ],
            ),

            const SizedBox(height: 10),

            FutureBuilder<List<ResidentVehicle>>(
              key: _futureBuilderKey, // Refresh triggered when key changes
              future: ResidentVehicleDao().getVehiclesByResidentId(widget.resident['id']),
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
                  children: vehicles.map((v) => _vehicleItem(context, v)).toList(),
                );
              },
            ),

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

  Widget _vehicleItem(BuildContext context, ResidentVehicle vehicle) {
    IconData vehicleIcon;
    String type = (vehicle.vehicleType ?? "").toLowerCase();

    if (type.contains("bike") || type.contains("scooter") || type.contains("two")) {
      vehicleIcon = Icons.motorcycle;
    } else if (type.contains("pickup") || type.contains("truck") || type.contains("van")) {
      vehicleIcon = Icons.local_shipping;
    } else {
      vehicleIcon = Icons.directions_car;
    }

    Color displayColor;
    String colorName = (vehicle.vehicleColor ?? "transparent").toLowerCase();

    final Map<String, Color> colorMap = {
      'white': Colors.white,
      'off white': const Color(0xFFFAF9F6),
      'silver': Colors.grey[400]!,
      'grey': Colors.grey,
      'black': Colors.black,
      'red': Colors.red,
      'blue': Colors.blue,
      'dark blue': const Color(0xFF00008B),
      'green': Colors.green,
      'yellow': Colors.yellow,
      'orange': Colors.orange,
      'brown': Colors.brown,
      'gold': const Color(0xFFFFD700),
    };

    displayColor =
        colorMap[colorName.toLowerCase()] ?? Colors.transparent;


    return GestureDetector(
      onTap: () async {
        // --- ADMIN CHECK ADDED HERE ---
        if (_currentUserRole != 'admin') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Only Admin can edit vehicles"),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }
        final refresh = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ResidentVehicleFormPage(
              residentId: widget.resident['id'],
              vehicle: vehicle,
            ),
          ),
        );
        if (refresh == true) _refreshData();
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Row(
          children: [
            Icon(vehicleIcon, color: Colors.green, size: 28),
            const SizedBox(width: 12),
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
            if (vehicle.vehicleColor != null && vehicle.vehicleColor!.isNotEmpty)
              Column(
                children: [
                  Container(
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(
                      color: displayColor,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: Colors.grey[400]!, width: 0.5),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(vehicle.vehicleColor!, style: const TextStyle(fontSize: 9, color: Colors.grey)),
                ],
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
