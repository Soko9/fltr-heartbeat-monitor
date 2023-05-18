import 'package:heart_beat_monitor/utils/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PreferenceService {
  static Future<bool> clearPreferences() async {
    final pref = await SharedPreferences.getInstance();
    return await pref.clear();
  }

  static Future<bool?> getBoolPref() async {
    try {
      final pref = await SharedPreferences.getInstance();
      return pref.getBool(kPrefBoolKey);
    } catch (_) {
      return null;
    }
  }

  static void setBoolPref() async {
    final pref = await SharedPreferences.getInstance();
    await pref.setBool(kPrefBoolKey, false);
  }

  static Future<int?> getIDPref() async {
    try {
      final pref = await SharedPreferences.getInstance();
      return pref.getInt(kPrefIDKey);
    } catch (_) {
      return null;
    }
  }

  static void setIDPref(int id) async {
    final pref = await SharedPreferences.getInstance();
    await pref.setInt(kPrefIDKey, id);
  }

  static Future<String?> getThemePref() async {
    try {
      final pref = await SharedPreferences.getInstance();
      return pref.getString(kPrefThemeKey);
    } catch (_) {
      return null;
    }
  }

  static Future<void> setThemePref(String theme) async {
    final pref = await SharedPreferences.getInstance();
    await pref.setString(kPrefThemeKey, theme);
  }

  static Future<String?> getSchemePref() async {
    try {
      final pref = await SharedPreferences.getInstance();
      return pref.getString(kPrefSchemeKey);
    } catch (_) {
      return null;
    }
  }

  static Future<void> setSchemePref(String scheme) async {
    final pref = await SharedPreferences.getInstance();
    await pref.setString(kPrefSchemeKey, scheme);
  }
}
