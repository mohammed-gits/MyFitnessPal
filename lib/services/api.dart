import 'dart:convert';
import 'package:http/http.dart' as http;

class Api {
  static const String baseUrl = "http://myfitnesspalapp.atwebpages.com/api";

  static Future<dynamic> getJson(String path) async {
    final uri = Uri.parse("$baseUrl$path");
    final res = await http.get(uri);
    if (res.statusCode != 200) {
      throw Exception("GET $path failed: ${res.statusCode}");
    }
    return jsonDecode(res.body);
  }

  static Future<dynamic> postJson(String path, Map<String, dynamic> body) async {
    final uri = Uri.parse("$baseUrl$path");
    final res = await http.post(
      uri,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(body),
    );
    if (res.statusCode != 200) {
      throw Exception("POST $path failed: ${res.statusCode} ${res.body}");
    }
    return jsonDecode(res.body);
  }
}
