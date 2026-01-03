import 'package:flutter/material.dart';
import '../models/resident_vehicle_model.dart';
import '../database/resident_vehicle_dao.dart';
import '../database/resident_dao.dart'; // Import ResidentDao
import '../utils/session_manager.dart';
import '../database/activity_log_dao.dart';
import '../models/activity_log_model.dart';

class ResidentVehicleFormPage extends StatefulWidget {
  final int? residentId;
  final ResidentVehicle? vehicle;

  const ResidentVehicleFormPage({
    super.key,
    this.residentId,
    this.vehicle,
  });

  @override
  State<ResidentVehicleFormPage> createState() => _ResidentVehicleFormPageState();
}

class _ResidentVehicleFormPageState extends State<ResidentVehicleFormPage> {
  final _formKey = GlobalKey<FormState>();

  // State for Resident Selection
  int? _selectedResidentId;
  String? _selectedResidentName;

  late TextEditingController _numberController;
  late TextEditingController _modelController;
  String? _selectedType;
  String? _selectedColor;

  final List<String> _vehicleTypes = ['Car', 'Bike', 'Scooter', 'Pickup', 'Truck', 'Other'];

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
    // Initialize selection from widget parameters
    _selectedResidentId = widget.residentId ?? widget.vehicle?.residentId;

    _numberController = TextEditingController(text: widget.vehicle?.vehicleNumber);
    _modelController = TextEditingController(text: widget.vehicle?.vehicleModel);
    _selectedType = widget.vehicle?.vehicleType ?? 'Car';
    _selectedColor = widget.vehicle?.vehicleColor ?? 'White';
  }

  // --- Searchable Modal for 1L+ Records ---
  void _showResidentPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _ResidentSearchSheet(
        onSelected: (id, name, house) {
          setState(() {
            _selectedResidentId = id;
            _selectedResidentName = "$name ($house)";
          });
        },
      ),
    );
  }

  Future<void> _saveVehicle() async {
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
      final String now = DateTime.now().toIso8601String();
      final bool isNew = widget.vehicle == null;
        if (_selectedResidentId == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Please select a resident first")),
          );
          return;
        }

    if (_formKey.currentState!.validate()) {
      final dao = ResidentVehicleDao();
      final now = DateTime.now().toIso8601String();

      final vehicle = ResidentVehicle(
        id: widget.vehicle?.id,
        residentId: _selectedResidentId!,
        vehicleNumber: _numberController.text.trim().toUpperCase(),
        vehicleType: _selectedType,
        vehicleColor: _selectedColor,
        vehicleModel: _modelController.text.trim(),
        recordedBy: userName,
        recordedById: userId,
        createdAt: widget.vehicle?.createdAt ?? now,
        updatedAt: now,
      );

      try {
        if (isNew) {
          // 1. Insert and Get new Id
          final int newVehicleId = await ResidentVehicleDao().insertVehicle(vehicle.toMap());

          // 2. Activity Log: New Vehicle Inserted ( With Inserted ID )
          await ActivityLogDao().insertLog(ActivityLogModel(
            userId: userId,
            residentId: _selectedResidentId,
            action: "VEHICLE_ADDED: ${vehicle.vehicleNumber} (ID: $newVehicleId)",
            timestamp: now,
          ));
        } else {
          // 3. Update case
          await ResidentVehicleDao().updateVehicle(vehicle.toMap());

          // 4. Activity Log: Update hua
          await ActivityLogDao().insertLog(ActivityLogModel(
            userId: userId,
            residentId: _selectedResidentId,
            action: "VEHICLE_UPDATED: ${vehicle.vehicleNumber}",
            timestamp: now,
          ));
        }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(isNew ? "Vehicle registered successfully" : "Vehicle details updated")),
      );
      Navigator.pop(context, true); // Refresh list
    }
  } catch (e) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
      );
    }
  }
    }
  }

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
              // --- Optimized Searchable Selector ---
              if (widget.residentId == null && !isEditing) ...[
                InkWell(
                  onTap: _showResidentPicker,
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: "Assign to Resident*",
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.person_search),
                      suffixIcon: Icon(Icons.arrow_drop_down),
                    ),
                    child: Text(
                      _selectedResidentName ?? "Tap to search resident...",
                      style: TextStyle(
                        color: _selectedResidentName == null ? Colors.grey : Colors.black,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],

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

// Internal class to handle Search and Pagination for 1L+ Residents
class _ResidentSearchSheet extends StatefulWidget {
  final Function(int id, String name, String house) onSelected;
  const _ResidentSearchSheet({required this.onSelected});

  @override
  State<_ResidentSearchSheet> createState() => _ResidentSearchSheetState();
}

class _ResidentSearchSheetState extends State<_ResidentSearchSheet> {
  final List<Map<String, dynamic>> _residents = [];
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;
  bool _hasMore = true;
  int _offset = 0;
  final int _limit = 20;
  String _query = "";

  @override
  void initState() {
    super.initState();
    _loadData();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
        _loadData();
      }
    });
  }

  Future<void> _loadData({bool isSearch = false}) async {
    if (_isLoading) return;
    if (!isSearch && !_hasMore) return;

    setState(() => _isLoading = true);

    if (isSearch) {
      _offset = 0;
      _residents.clear();
      _hasMore = true;
    }

    // Using your newly added DAO method
    final results = await ResidentDao().getResidentsPaginated(
      limit: _limit,
      offset: _offset,
      query: _query,
    );

    setState(() {
      _isLoading = false;
      _residents.addAll(results);
      _offset += _limit;
      if (results.length < _limit) _hasMore = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.8,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: "Search Name or House...",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onChanged: (val) {
                _query = val;
                _loadData(isSearch: true);
              },
            ),
          ),
          Expanded(
            child: _residents.isEmpty && !_isLoading
                ? const Center(child: Text("No residents found"))
                : ListView.builder(
              controller: _scrollController,
              itemCount: _residents.length + (_hasMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _residents.length) {
                  return const Center(child: Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator()));
                }
                final res = _residents[index];
                return ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.person)),
                  title: Text(res['name'] ?? 'Unknown'),
                  subtitle: Text("House: ${res['house_num'] ?? 'N/A'}"),
                  onTap: () {
                    widget.onSelected(res['id'], res['name'], res['house_num']);
                    Navigator.pop(context);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
