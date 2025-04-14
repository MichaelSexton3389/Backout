import 'package:http/http.dart' as http;
import 'dart:convert';

Future<List<Map<String, dynamic>>> fetchUsers() async {
  final response = await http.get(Uri.parse('http://localhost:3000/api/user/users'));
  if (response.statusCode == 200) {
    List<dynamic> usersJson = json.decode(response.body);
    return usersJson.map((user) => {
      'name': user['name'],
      'id': user['_id'],
      'profile_picture': user['profile_picture']
    }).toList();
  } else {
    throw Exception("Failed to load users");
  }
}