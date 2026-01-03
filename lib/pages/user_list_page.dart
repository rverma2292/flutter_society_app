import 'package:flutter/material.dart';
import '../database/user_dao.dart';
import '../models/user_model.dart';
import 'user_form_page.dart';

class UserListPage extends StatefulWidget {
  const UserListPage({super.key});

  @override
  State<UserListPage> createState() => _UserListPageState();
}

class _UserListPageState extends State<UserListPage> {
  final UserDao _userDao = UserDao();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Manage Guards")),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.deepOrange,
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () => _navigateToForm(),
      ),
      body: FutureBuilder<List<UserModel>>(
        future: _userDao.getAllUsers(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No users found"));
          }

          final users = snapshot.data!;
          return ListView.builder(
            itemCount: users.length,
            // ListView.builder ke andar itemBuilder ko aise update karein:
            itemBuilder: (context, index) {
              final user = users[index];

              // Check karein kya ye admin hai?
              bool isAdmin = user.role.toLowerCase() == 'admin';

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: isAdmin ? Colors.blue.shade100 : null,
                    child: Icon(isAdmin ? Icons.admin_panel_settings : Icons.person),
                  ),
                  title: Text(user.fullName),
                  subtitle: Text("${user.username} (${user.role})"),

                  // Admin ke liye trailing buttons hide karne ka logic
                  trailing: isAdmin
                      ? const Icon(Icons.lock, color: Colors.grey) // Admin ke liye lock icon
                      : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => _navigateToForm(user: user),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteUser(user.id!),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _navigateToForm({UserModel? user}) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => UserFormPage(user: user)),
    );
    setState(() {}); // Refresh list
  }

  void _deleteUser(int id) async {
    bool confirm = await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Delete User?"),
        content: const Text("This action cannot be undone."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("Cancel")),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text("Delete", style: TextStyle(color: Colors.red))),
        ],
      ),
    ) ?? false;

    if (confirm) {
      await _userDao.deleteUser(id);
      setState(() {});
    }
  }
}
