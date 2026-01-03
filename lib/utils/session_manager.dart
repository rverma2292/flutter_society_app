import 'package:shared_preferences/shared_preferences.dart';

class SessionManager {
  static Future<Map<String, dynamic>> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'id': prefs.getInt('userId'),
      'name': prefs.getString('userName'),
      'role': prefs.getString('userRole'),
    };
  }
}
