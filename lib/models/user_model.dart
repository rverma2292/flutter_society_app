

class UserModel {
  final int? id;
  final String username;
  final String password;
  final String fullName;
  final String role; // 'admin' or 'guard'
  final String createdAt;
  final String updatedAt;

  UserModel({
    this.id,
    required this.username,
    required this.password,
    required this.fullName,
    required this.role,
    required this.createdAt,
    required this.updatedAt,
  });

  // Database (Map) se Model banane ke liye
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'],
      username: map['username'],
      password: map['password'],
      fullName: map['full_name'],
      role: map['role'],
      createdAt: map['created_at'],
      updatedAt: map['updated_at'],
    );
  }

  // Model se Database (Map) banane ke liye
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'password': password,
      'full_name': fullName,
      'role': role,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}
