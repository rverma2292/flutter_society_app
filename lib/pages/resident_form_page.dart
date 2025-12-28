import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/resident.dart';
import '../database/database_helper.dart';

class ResidentFormPage extends StatefulWidget {
  final Resident? resident; // If null, we are Adding. If not null, we are Editing.

  const ResidentFormPage({super.key, this.resident});

  @override
  State<ResidentFormPage> createState() => _ResidentFormPageState();
}

class _ResidentFormPageState extends State<ResidentFormPage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _flatController;
  late TextEditingController _mobileController;
  late String _selectedType;
  String? _selectedImagePath;

  @override
  void initState() {
    super.initState();
    final r = widget.resident;
    _nameController = TextEditingController(text: r?.name ?? '');
    _flatController = TextEditingController(text: r?.house_num ?? '');
    _mobileController = TextEditingController(text: r?.mobile ?? '');
    _selectedType = r?.resident_type.toLowerCase() == 'tenant' ? 'tenant' : 'owner';
    _selectedImagePath = r?.image_path;
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();

    // Show a dialog to choose between Camera or Gallery
    final ImageSource? source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library, color: Colors.blue),
                title: const Text('Pick from Gallery'),
                onTap: () => Navigator.pop(context, ImageSource.gallery),
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt, color: Colors.blue),
                title: const Text('Take a Photo'),
                onTap: () => Navigator.pop(context, ImageSource.camera),
              ),
            ],
          ),
        );
      },
    );

    if (source != null) {
      final XFile? image = await picker.pickImage(
        source: source,
        imageQuality: 80,
      );

      if (image != null) {
        setState(() {
          _selectedImagePath = image.path;
        });
      }
    }
  }


  Future<void> _saveResident() async {
    if (!_formKey.currentState!.validate()) return;

    final residentData = Resident(
      id: widget.resident?.id,
      uuid: widget.resident?.uuid,
      name: _nameController.text.trim(),
      house_num: _flatController.text.trim(),
      resident_type: _selectedType,
      mobile: _mobileController.text.trim(),
      image_path: _selectedImagePath,
    );

    if (widget.resident == null) {
      await DatabaseHelper.instance.insertResident(residentData.toMap());
    } else {
      await DatabaseHelper.instance.updateResident(residentData.toMap());
    }

    if (mounted) Navigator.pop(context, true); // Return 'true' to refresh list
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.resident != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? "Edit Resident" : "New Resident"),
        actions: [
          IconButton(onPressed: _saveResident, icon: const Icon(Icons.check))
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              // --- PROFILE IMAGE SECTION ---
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundColor: Colors.blue.withOpacity(0.1),
                      backgroundImage: _selectedImagePath != null
                          ? FileImage(File(_selectedImagePath!))
                          : null,
                      child: _selectedImagePath == null
                          ? const Icon(Icons.person, size: 60, color: Colors.blue)
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: FloatingActionButton.small(
                        onPressed: _pickImage,
                        child: const Icon(Icons.camera_alt),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // --- FORM FIELDS ---
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: "Full Name", prefixIcon: Icon(Icons.badge)),
                validator: (v) => v!.isEmpty ? "Enter name" : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _flatController,
                decoration: const InputDecoration(labelText: "House/Flat Number", prefixIcon: Icon(Icons.home)),
                validator: (v) => v!.isEmpty ? "Enter house number" : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedType,
                decoration: const InputDecoration(labelText: "Resident Type", prefixIcon: Icon(Icons.people)),
                items: const [
                  DropdownMenuItem(value: 'owner', child: Text("Owner")),
                  DropdownMenuItem(value: 'tenant', child: Text("Tenant")),
                ],
                onChanged: (v) => setState(() => _selectedType = v!),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _mobileController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(labelText: "Mobile Number", prefixIcon: Icon(Icons.phone)),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return "Mobile number is required";
                  }
                  if (v.trim().length < 10 || v.trim().length > 10) {
                    return "Mobile number must be 10 digits";
                  }
                  return null;
                },
              ),

              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _saveResident,
                  child: Text(isEdit ? "UPDATE RESIDENT" : "SAVE RESIDENT"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
