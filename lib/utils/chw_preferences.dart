import 'package:shared_preferences/shared_preferences.dart';

class ChwPreferences {
  static const String _key = 'chw_identifier';

  // Returns true if a CHW identifier has already been saved
  static Future<bool> hasIdentifier() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString(_key);
    return value != null && value.isNotEmpty;
  }

  // Saves the CHW identifier
  static Future<void> saveIdentifier(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, name);
  }

  // Retrieves the saved CHW identifier, or null if none exists
  static Future<String?> getIdentifier() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_key);
  }
}
