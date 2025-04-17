import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void showSnackBar(BuildContext context, String text) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(text),
    ),
  );
}

void httpErrorHandle({
  required http.Response response,
  required BuildContext context,
  required VoidCallback onSuccess,
}) {
  print('Status code: ${response.statusCode}');
  print('Response body: ${response.body}');

  try {
    switch (response.statusCode) {
      case 200:
        onSuccess();
        break;
      case 400:
        final body = jsonDecode(response.body);
        print('error 400');
        showSnackBar(context, body['msg'] ?? 'Unknown error');
        break;
      case 500:
        final body = jsonDecode(response.body);
        print('error 500');
        print(body);
        showSnackBar(context, body['error'] ?? 'Server error');
        break;
      default:
        showSnackBar(context, "Unexpected error: ${response.body}");
    }
  } catch (e) {
    print("Error decoding response: $e");
    showSnackBar(context, "Invalid server response: ${response.body}");
  }
}
