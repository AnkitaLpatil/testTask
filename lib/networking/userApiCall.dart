import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:my_flutter_app/constants.dart';

class UserService {
  static const String baseUrl = ConstantValues.Baseapi;
  static const Map<String, String> headers = {
    'app-id': '666a92cbe42133bf4cdb3081'
  };

  Future<Map<String, dynamic>> fetchUsers(
      {int limit = 10, required int pageno}) async {
    final int adjustedLimit = limit + (pageno * 10);
    final url = Uri.parse('$baseUrl?limit=$adjustedLimit&page=$pageno');
    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load users');
    }
  }
}
