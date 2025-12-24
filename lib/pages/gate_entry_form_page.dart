import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../database/gate_entery_dao.dart';
import '../models/gate_entry_model.dart';
import 'package:intl/intl.dart';

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
                  onPressed: () async { // async add karein
                    if (_formKey.currentState!.validate()) {

                      // 4. GateEntry Object banayein
                      final entry = GateEntry(
                        personName: _nameController.text,
                        mobile: _mobileController.text,
                        personType: _personType,
                        purpose: _purposeController.text,
                        houseNum: _houseNumController.text,
                        vehicleNo: _vehicleNoController.text,
                        remarks: _remarksController.text,
                        // Time save logic
                        entryTime: widget.entryType == "Incoming"
                            ? DateFormat('dd-MM-yyyy hh:mm a').format(DateTime.now())
                            : "",

                        exitTime: widget.entryType == "Outgoing"
                            ? DateFormat('dd-MM-yyyy hh:mm a').format(DateTime.now())
                            : "",
                      );

                      // 5. DAO ke through Save karein
                      await _gateEntryDao.insertGateEntry(entry);

                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("${widget.entryType} Entry Saved!")),
                        );
                        Navigator.pop(context);
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
