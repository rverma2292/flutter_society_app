import 'package:flutter/material.dart';
import '../database/gate_entery_dao.dart';
import '../models/gate_entry_model.dart';
import 'package:intl/intl.dart';
import '../utils/session_manager.dart';
import '../database/activity_log_dao.dart';
import '../models/activity_log_model.dart';

class GateEntryFormPage extends StatefulWidget {
  final String entryType; // "Incoming" or "Outgoing"

  const GateEntryFormPage({super.key, required this.entryType});

  @override
  State<GateEntryFormPage> createState() => _GateEntryFormPageState();
}

class _GateEntryFormPageState extends State<GateEntryFormPage> {
  final _formKey = GlobalKey<FormState>();

  // 3. DAO ka instance banayein
  final GateEntryDao _gateEntryDao = GateEntryDao();

  // Controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _purposeController = TextEditingController();
  final TextEditingController _houseNumController = TextEditingController();
  final TextEditingController _vehicleNoController = TextEditingController();
  final TextEditingController _remarksController = TextEditingController();

  String _personType = 'Visitor';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("${widget.entryType} Registration")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Register ${widget.entryType} Person",
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),

              // Dropdown aur baaki TextFormFields wahi rahenge...
              DropdownButtonFormField<String>(
                value: _personType,
                decoration: const InputDecoration(labelText: "Person Type", border: OutlineInputBorder()),
                items: ["Visitor", "Delivery", "Cab", "Service", "Other"]
                    .map((type) => DropdownMenuItem(value: type, child: Text(type)))
                    .toList(),
                onChanged: (val) => setState(() => _personType = val!),
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: "Person Name", border: OutlineInputBorder()),
                validator: (v) => v!.isEmpty ? "Enter name" : null,
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: _mobileController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(labelText: "Mobile Number", border: OutlineInputBorder()),
                validator: (v) => v!.length < 10 ? "Enter valid mobile" : null,
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: _houseNumController,
                decoration: const InputDecoration(labelText: "House Number", border: OutlineInputBorder()),
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: _purposeController,
                decoration: const InputDecoration(labelText: "Purpose", border: OutlineInputBorder()),
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: _vehicleNoController,
                decoration: const InputDecoration(labelText: "Vehicle Number (Optional)", border: OutlineInputBorder()),
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: _remarksController,
                maxLines: 2,
                decoration: const InputDecoration(labelText: "Remarks", border: OutlineInputBorder()),
              ),
              const SizedBox(height: 30),

              // --- BUTTON KI LOGIC ---
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: widget.entryType == "Incoming" ? Colors.teal : Colors.deepOrange,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () async {
                    if (!_formKey.currentState!.validate()) return;

                    try {
                      // 1. Get User from Session
                      final user = await SessionManager.getCurrentUser();
                      final int? userId = user['id'];
                      final String? userName = user['name'];

                      if (userId == null) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Session expired. Please login again."), backgroundColor: Colors.red),
                          );
                        }
                        return;
                      }

                      final String now = DateFormat('dd-MM-yyyy hh:mm a').format(DateTime.now());

                      // 2. GateEntry Object (With Audit Fields)
                      final entry = GateEntry(
                        personName: _nameController.text.trim(),
                        mobile: _mobileController.text.trim(),
                        personType: _personType,
                        purpose: _purposeController.text.trim(),
                        houseNum: _houseNumController.text.trim(),
                        vehicleNo: _vehicleNoController.text.trim(),
                        remarks: _remarksController.text.trim(),
                        entryTime: widget.entryType == "Incoming" ? now : "",
                        exitTime: widget.entryType == "Outgoing" ? now : "",
                        recordedBy: userName,
                        recordedById: userId,
                      );

                      // 3. Database Save (Returns new ID)
                      // Note: DAO ka insert method Future<int> hona chahiye
                      final int newId = await _gateEntryDao.insertGateEntry(entry.toMap());

                      // 4. Activity Log Insert
                      await ActivityLogDao().insertLog(ActivityLogModel(
                        userId: userId,
                        referenceId: newId, // Generic ID (Entry ID)
                        action: "GATE_${widget.entryType.toUpperCase()}: ${entry.personName}",
                        timestamp: DateTime.now().toIso8601String(),
                      ));

                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("${widget.entryType} Entry Saved!"),
                            backgroundColor: widget.entryType == "Incoming" ? Colors.teal : Colors.deepOrange, // Dynamic color
                            behavior: SnackBarBehavior.floating, // Option: SnackBar ko thoda upar dikhane ke liye
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), // Option: Corners round karne ke liye
                          ),
                        );
                        Navigator.pop(context, true);
                      }
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
                        );
                      }
                    }
                  },
                  child: Text("Save ${widget.entryType} Details",
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
