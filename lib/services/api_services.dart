import 'package:http/http.dart' as http;

class ApiService {
  static Future<http.Response> getRequest(String url) async {
    try {
      final response = await http.get(Uri.parse(url));
      return response;
    } catch (e) {
      print('Network error: $e');
      throw Exception('Network error: $e');
    }
  }
}
