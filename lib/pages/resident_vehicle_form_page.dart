import 'package:flutter/material.dart';
import '../models/resident_vehicle_model.dart';
import '../database/resident_vehicle_dao.dart';

class ResidentVehicleFormPage extends StatefulWidget {
  final int residentId;
  final ResidentVehicle? vehicle; // If null, we are adding. If not null, we are editing.

  const ResidentVehicleFormPage({
    super.key,
    required this.residentId,
    this.vehicle,
  });

  @override
  State<ResidentVehicleFormPage> createState() => _ResidentVehicleFormPageState();
}

class _ResidentVehicleFormPageState extends State<ResidentVehicleFormPage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _numberController;
  late TextEditingController _modelController;
  String? _selectedType;
  String? _selectedColor;

  final List<String> _vehicleTypes = ['Car', 'Bike', 'Scooter', 'Pickup', 'Truck', 'Other'];

  // Defined list of colors with display names and actual Flutter colors
  final List<Map<String, dynamic>> _colorOptions = [
    {'name': 'White', 'color': Colors.white},
    {'name': 'Off White', 'color': const Color(0xFFFAF9F6)},
    {'name': 'Silver', 'color': Colors.grey[400]},
    {'name': 'Grey', 'color': Colors.grey},
    {'name': 'Black', 'color': Colors.black},
    {'name': 'Red', 'color': Colors.red},
    {'name': 'Blue', 'color': Colors.blue},
    {'name': 'Dark Blue', 'color': const Color(0xFF00008B)},
    {'name': 'Green', 'color': Colors.green},
    {'name': 'Yellow', 'color': Colors.yellow},
    {'name': 'Orange', 'color': Colors.orange},
    {'name': 'Brown', 'color': Colors.brown},
    {'name': 'Gold', 'color': const Color(0xFFFFD700)},
    {'name': 'Other', 'color': Colors.transparent},
  ];

  @override
  void initState() {
    super.initState();
    _numberController = TextEditingController(text: widget.vehicle?.vehicleNumber);
    _modelController = TextEditingController(text: widget.vehicle?.vehicleModel);

    _selectedType = widget.vehicle?.vehicleType ?? 'Car';

    // Set initial color if editing, otherwise default to White
    _selectedColor = widget.vehicle?.vehicleColor ?? 'White';
  }

  Future<void> _saveVehicle() async {
    if (_formKey.currentState!.validate()) {
      final dao = ResidentVehicleDao();
      final now = DateTime.now().toIso8601String();

      final vehicle = ResidentVehicle(
        id: widget.vehicle?.id, // Keep ID if editing
        residentId: widget.residentId,
        vehicleNumber: _numberController.text.trim().toUpperCase(),
        vehicleType: _selectedType,
        vehicleColor: _selectedColor,
        vehicleModel: _modelController.text.trim(),
        createdAt: widget.vehicle?.createdAt ?? now,
        updatedAt: now,
      );

      if (widget.vehicle == null) {
        await dao.insertVehicle(vehicle);
      } else {
        await dao.updateVehicle(vehicle);
      }

      if (!mounted) return;
      Navigator.pop(context, true);
    }
  }

  // ... (Confirm Delete logic remains the same)
  Future<void> _confirmDelete() async {
    final bool? confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Vehicle?"),
        content: const Text("Are you sure you want to remove this vehicle?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("CANCEL")),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("DELETE", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true && widget.vehicle?.id != null) {
      await ResidentVehicleDao().deleteVehicle(widget.vehicle!.id!);
      if (!mounted) return;
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isEditing = widget.vehicle != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? "Edit Vehicle" : "Add New Vehicle"),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          if (isEditing)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: _confirmDelete,
            )
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Vehicle Number (Required)
              TextFormField(
                controller: _numberController,
                decoration: const InputDecoration(
                  labelText: "Vehicle Number (e.g. MH12AB1234)*",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.numbers),
                ),
                textCapitalization: TextCapitalization.characters,
                validator: (val) => (val == null || val.isEmpty) ? "Required" : null,
              ),
              const SizedBox(height: 20),

              // Type Dropdown
              DropdownButtonFormField<String>(
                value: _selectedType,
                decoration: const InputDecoration(
                  labelText: "Vehicle Type",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.category),
                ),
                items: _vehicleTypes.map((type) => DropdownMenuItem(value: type, child: Text(type))).toList(),
                onChanged: (val) => setState(() => _selectedType = val),
              ),
              const SizedBox(height: 20),

              // --- COLOR DROPDOWN WITH VISUALS ---
              DropdownButtonFormField<String>(
                value: _selectedColor,
                decoration: const InputDecoration(
                  labelText: "Vehicle Color",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.color_lens),
                ),
                items: _colorOptions.map((opt) {
                  return DropdownMenuItem<String>(
                    value: opt['name'],
                    child: Row(
                      children: [
                        Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            color: opt['color'],
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.grey.shade400),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(opt['name']),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (val) => setState(() => _selectedColor = val),
              ),
              const SizedBox(height: 20),

              TextFormField(
                controller: _modelController,
                decoration: const InputDecoration(
                  labelText: "Model (e.g. Swift, Activa)",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.directions_car),
                ),
              ),
              const SizedBox(height: 40),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white),
                  onPressed: _saveVehicle,
                  child: Text(isEditing ? "UPDATE VEHICLE" : "SAVE VEHICLE"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
