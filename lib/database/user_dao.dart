import '../models/user_model.dart';
import 'database_helper.dart';

class UserDao {
  final dbHelper = DatabaseHelper.instance;

  // To Add new User (Guard/Admin)
  Future<int> createUser(UserModel user) async {
    final db = await dbHelper.database;
    return await db.insert('users', user.toMap());
  }

  // Default user seeding
  Future<void> insertDefaultAdmin() async {
    final db = await dbHelper.database;

    // To check if admin already exists
    final List<Map<String, dynamic>> existingAdmin = await db.query(
      'users',
      where: 'username = ?',
      whereArgs: ['admin'],
    );

    // If admin not exist
    if (existingAdmin.isEmpty) {
      await db.insert('users', {
        'username': 'admin',
        'password': 'password123', // Ise baad mein badal sakte hain
        'full_name': 'Society Admin',
        'role': 'admin',
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      });
      print("Default Admin Created!");
    }
  }

  // To Check Login
  Future<UserModel?> login(String username, String password) async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'username = ? AND password = ?',
      whereArgs: [username, password],
    );

    if (maps.isNotEmpty) {
      return UserModel.fromMap(maps.first);
    }
    return null;
  }

  // Get ALL Users
  Future<List<UserModel>> getAllUsers() async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('users');
    return List.generate(maps.length, (i) => UserModel.fromMap(maps[i]));
  }

  // User delete Method
  Future<int> deleteUser(int id) async {
    final db = await dbHelper.database;
    return await db.delete('users', where: 'id = ?', whereArgs: [id]);
  }

  // User Update Method
  Future<int> updateUser(UserModel user) async {
    final db = await dbHelper.database;
    return await db.update(
      'users',
      user.toMap(),
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }

  //To Save and Update User
  Future<int> saveOrUpdateUser(UserModel user) async {
    final db = await DatabaseHelper.instance.database;
    if (user.id == null) {
      return await db.insert('users', user.toMap());
    } else {
      return await db.update(
        'users',
        user.toMap(),
        where: 'id = ?',
        whereArgs: [user.id],
      );
    }
  }

  // Function to check Login User
  Future<Map<String, dynamic>?> loginUser(String username, String password) async {
    final db = await DatabaseHelper.instance.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'username = ? AND password = ?',
      whereArgs: [username, password],
    );

    if (maps.isNotEmpty) {
      return maps.first;
    }
    return null;
  }

}
