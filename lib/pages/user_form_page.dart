import 'package:flutter/material.dart';
import '../database/user_dao.dart';
import '../models/user_model.dart';

class UserFormPage extends StatefulWidget {
  final UserModel? user;
  const UserFormPage({super.key, this.user});

  @override
  State<UserFormPage> createState() => _UserFormPageState();
}

class _UserFormPageState extends State<UserFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true; // To hide the password
  String _selectedRole = 'guard';

  @override
  void initState() {
    super.initState();
    if (widget.user != null) {
      _nameController.text = widget.user!.fullName;
      _usernameController.text = widget.user!.username;
      _passwordController.text = widget.user!.password;
      _selectedRole = widget.user!.role;
    }
  }

  void _saveUser() async {
    if (_formKey.currentState!.validate()) {
      final user = UserModel(
        id: widget.user?.id,
        fullName: _nameController.text,
        username: _usernameController.text,
        password: _passwordController.text,
        role: _selectedRole,
        createdAt: widget.user?.createdAt ?? DateTime.now().toIso8601String(),
        updatedAt: DateTime.now().toIso8601String(),
      );

      // DAO ka method use karke save/update karein
      await UserDao().saveOrUpdateUser(user);

      if (!mounted) return;

      // Success Message dikhayein
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.user == null
              ? "User added successfully!"
              : "User updated successfully!"),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context);
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.user == null ? "Add Guard" : "Edit Guard")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(controller: _nameController, decoration: const InputDecoration(labelText: "Full Name"), validator: (v) => v!.isEmpty ? "Required" : null),
              TextFormField(controller: _usernameController, decoration: const InputDecoration(labelText: "Username"), validator: (v) => v!.isEmpty ? "Required" : null),
              TextFormField(
                controller: _passwordController,
                obscureText: _obscurePassword, // Toggle variable use karein
                decoration: InputDecoration(
                  labelText: "Password",
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword; // Value toggle karein
                      });
                    },
                  ),
                ),
                validator: (v) => v!.isEmpty ? "Required" : null,
              ),
              DropdownButtonFormField<String>(
                value: _selectedRole,
                items: ['admin', 'guard'].map((r) => DropdownMenuItem(value: r, child: Text(r.toUpperCase()))).toList(),
                onChanged: (v) => setState(() => _selectedRole = v!),
                decoration: const InputDecoration(labelText: "Role"),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _saveUser,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.deepOrange, minimumSize: const Size(double.infinity, 50)),
                child: const Text("SAVE USER", style: TextStyle(color: Colors.white)),
              )
            ],
          ),
        ),
      ),
    );
  }
}
