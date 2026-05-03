import 'dart:convert';
import 'package:http/http.dart' as http;

class FirebaseService {
  static const String _base =
      'https://deepmicroplastics-default-rtdb.firebaseio.com';

  static Future<dynamic> get(String path) async {
    try {
      final res = await http
          .get(Uri.parse('$_base/$path.json'))
          .timeout(const Duration(seconds: 15));
      if (res.statusCode == 200 && res.body != 'null') {
        return json.decode(res.body);
      }
    } catch (_) {}
    return null;
  }

  static Future<bool> set(String path, Map<String, dynamic> data) async {
    try {
      final res = await http
          .put(
            Uri.parse('$_base/$path.json'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode(data),
          )
          .timeout(const Duration(seconds: 15));
      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> update(String path, Map<String, dynamic> data) async {
    try {
      final res = await http
          .patch(
            Uri.parse('$_base/$path.json'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode(data),
          )
          .timeout(const Duration(seconds: 15));
      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> delete(String path) async {
    try {
      final res = await http
          .delete(Uri.parse('$_base/$path.json'))
          .timeout(const Duration(seconds: 15));
      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}
