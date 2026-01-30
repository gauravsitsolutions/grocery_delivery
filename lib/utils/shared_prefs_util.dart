import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefsUtil {
  static const String _keyToken = 'auth_token';
  static const String _keyUserName = 'user_name';
  static const String _keyAgentId = 'agent_id';
  static const String _keyUserId = 'user_id';
  static const String _keyDutyStatus = 'duty_status';

  static Future<void> saveUserSession({
    required String token,
    String? userName,
    String? agentId,
    String? userId,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyToken, token);
    if (userName != null) await prefs.setString(_keyUserName, userName);
    if (agentId != null) await prefs.setString(_keyAgentId, agentId);
    if (userId != null) await prefs.setString(_keyUserId, userId);
  }

  static Future<void> setToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyToken, token);
  }

  static Future<void> setUserName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUserName, name);
  }

  static Future<void> setAgentId(String id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyAgentId, id);
  }

  static Future<void> setUserId(String id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUserId, id);
  }

  static Future<void> setDutyStatus(String status) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyDutyStatus, status);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyToken);
  }

  static Future<String?> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUserName);
  }

  static Future<String?> getAgentId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyAgentId);
  }

  static Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUserId);
  }

  static Future<String?> getDutyStatus() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyDutyStatus);
  }

  static Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyToken);
    await prefs.remove(_keyUserName);
    await prefs.remove(_keyAgentId);
    await prefs.remove(_keyUserId);
  }
}
