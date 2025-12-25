import 'api.dart';

class SettingsApi {
  static Future<Map<String, dynamic>> getSettings() async {
    final data = await Api.getJson("/settings/get.php");
    return Map<String, dynamic>.from(data);
  }

  static Future<void> updateSettings({
    required String goal,
    required String activity,
    required bool reminder,
  }) async {
    await Api.postJson("/settings/update.php", {
      "goal": goal,
      "activity": activity,
      "reminder": reminder,
    });
  }
}
