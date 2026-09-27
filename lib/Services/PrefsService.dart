import 'package:shared_preferences/shared_preferences.dart';

class PrefsService {
  PrefsService._();
  static final PrefsService instance = PrefsService._();

  static const _kUserId = 'user_id';

  Future<void> saveUserId(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kUserId, userId);
  }

  Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_kUserId);
  }

  Future<void> clearUserId() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kUserId);
  }
}