import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Time format ke liye
import '../models/gate_entry_model.dart';
import '../database/gate_entery_dao.dart';

class GateEntryDetailsPage extends StatefulWidget {
  final GateEntry entry;
  const GateEntryDetailsPage({super.key, required this.entry});

  @override
  State<GateEntryDetailsPage> createState() => _GateEntryDetailsPageState();
}

class _GateEntryDetailsPageState extends State<GateEntryDetailsPage> {
  final GateEntryDao _gateEntryDao = GateEntryDao();
  String? _currentExitTime;

  @override
  void initState() {
    super.initState();
    // Shuruat me model ka exitTime set karein
    _currentExitTime = widget.entry.exitTime;
  }

  // Exit Time update karne ka function
  void _markExit() async {
    if (widget.entry.id == null) return;

    // Naya time generate karein (Readable format jaisa aapne pehle manga tha)
    String now = DateFormat('dd-MM-yyyy hh:mm a').format(DateTime.now());

    await _gateEntryDao.updateExitTime(widget.entry.id!, now);

    setState(() {
      _currentExitTime = now;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Exit marked successfully!")),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Condition: Button tabhi dikhega jab exit time nahi hoga
    bool showExitButton = (_currentExitTime == null || _currentExitTime!.isEmpty);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Entry Details"),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Edit feature coming soon!")),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildDetailCard("Visitor Info", [
              _detailRow(Icons.person, "Name", widget.entry.personName),
              _detailRow(Icons.phone, "Mobile", widget.entry.mobile),
              _detailRow(Icons.badge, "Type", widget.entry.personType),
            ]),
            const SizedBox(height: 16),
            _buildDetailCard("Location & Vehicle", [
              _detailRow(Icons.home, "House No", widget.entry.houseNum),
              _detailRow(Icons.directions_car, "Vehicle No", widget.entry.vehicleNo ?? "N/A"),
              _detailRow(Icons.question_answer, "Purpose", widget.entry.purpose),
            ]),
            const SizedBox(height: 16),
            _buildDetailCard("Timing", [
              _detailRow(Icons.login, "Entry Time", widget.entry.entryTime),
              _detailRow(Icons.logout, "Exit Time", (_currentExitTime != null && _currentExitTime!.isNotEmpty) ? _currentExitTime! : "Not Exited"),
            ]),

            const SizedBox(height: 30),

            // CONDITIONAL BUTTON: Sirf tab dikhega jab Exit nahi hua hai
            if (showExitButton)
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: _markExit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepOrange,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  icon: const Icon(Icons.output),
                  label: const Text("MARK AS EXIT", style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              )
            else
            // Button ki jagah ek Success Badge dikha sakte hain (Optional)
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.green),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle, color: Colors.green),
                    SizedBox(width: 8),
                    Text("Visitor has Exited", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  // --- Niche ke helper methods (_buildDetailCard aur _detailRow) wahi rahenge jo pehle the ---
  Widget _buildDetailCard(String title, List<Widget> children) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blueGrey)),
            const Divider(),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _detailRow(IconData icon, String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey),
          const SizedBox(width: 12),
          Text("$label:", style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(width: 8),
          Expanded(child: Text(value ?? "N/A", style: const TextStyle(color: Colors.black87))),
        ],
      ),
    );
  }
}