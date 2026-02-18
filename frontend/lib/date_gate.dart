import 'package:shared_preferences/shared_preferences.dart';

class DateGate {
  // Keys: allow override per (country, topic)
  static String _overrideKey(String country, String topic) =>
      'gate_override_${country.toLowerCase()}_${topic.toLowerCase()}';

  // Set an override unlock date (you can reset/clear this anytime)
  static Future<void> setOverrideUnlockDate({
    required String country,
    required String topic,
    required DateTime unlockAt,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_overrideKey(country, topic), unlockAt.toIso8601String());
  }

  /*
  country = "CA", topic = "Math"
  country.toLowerCase() -> "ca"
  topic.toLowerCase() -> "math"
  key becomes:
  gate_override_ca_math
  */

  // Clear override (reset to normal gating rules)
  static Future<void> clearOverride({
    required String country,
    required String topic,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_overrideKey(country, topic));
  }

  static Future<DateTime?> getOverride({
    required String country,
    required String topic,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final s = prefs.getString(_overrideKey(country, topic));
    if (s == null) return null;
    return DateTime.tryParse(s);
  }
}