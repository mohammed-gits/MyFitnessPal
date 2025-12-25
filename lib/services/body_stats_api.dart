import 'api.dart';

class BodyStatsApi {
  static Future<List<Map<String, dynamic>>> fetchEntries() async {
    final data = await Api.getJson("/body_stats/list.php");
    final list = (data["entries"] as List?) ?? [];
    return list.map((e) => Map<String, dynamic>.from(e)).toList();
  }

  static Future<void> createEntry({double? weight, double? waist}) async {
    await Api.postJson("/body_stats/create.php", {
      "weight": weight,
      "waist": waist,
    });
  }

  static Future<void> deleteEntry(int id) async {
    await Api.postJson("/body_stats/delete.php", {"id": id});
  }
}
