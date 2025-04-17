import 'dart:convert';
import 'package:BackOut/screens/home_screen.dart';
import 'package:BackOut/screens/login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:BackOut/providers/user_providers.dart';
import 'package:BackOut/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:BackOut/models/user.dart';
import 'package:BackOut/utils/utils.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class AuthService {
  Future<bool> signUpUser(
      {required BuildContext context,
      required String email,
      required String password,
      required String name}) async {
    try {
      User user =
          User(id: '', name: name, email: email, token: '', password: password);

      print('Sending request to: ${Constants.uri}/api/signup');
      print('Request body: ${jsonEncode(user.toMap())}');

      http.Response res = await http.post(
        Uri.parse('${Constants.uri}/api/signup'),
        body: jsonEncode(user.toMap()),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      print('Sending request to: ${Constants.uri}/api/signup');
      print('Request body: ${jsonEncode(user.toMap())}');

      httpErrorHandle(
          response: res,
          context: context,
          onSuccess: () {
            showSnackBar(
                context, 'Account created! Login with the same credentials');
          });

      print('Response status code: ${res.statusCode}');
      print('Response body: ${res.body}');
      return true;
    } catch (e) {
      print('Error: $e');
      showSnackBar(context, e.toString());
      return false;
    }
  }

  void signInUser({
    required BuildContext context,
    required String email,
    required String password,
  }) async {
    try {
      var userProvider = Provider.of<UserProvider>(context, listen: false);
      final navigator = Navigator.of(context);
      http.Response res = await http.post(
          Uri.parse('${Constants.uri}/api/signin'),
          body: jsonEncode({'email': email, 'password': password}),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8'
          });

      httpErrorHandle(
          response: res,
          context: context,
          onSuccess: () async {
            SharedPreferences prefs = await SharedPreferences.getInstance();
            userProvider.setUser(res.body);
            await prefs.setString(
                'x-auth-token', jsonDecode(res.body)['token']);
            navigator.pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => const HomeScreen()),
              (route) => false,
            );
          });
    } catch (e) {
      showSnackBar(context, e.toString());
    }
  }

  void signOut({required BuildContext context}) async {
  try {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final navigator = Navigator.of(context);

    
    await prefs.remove('x-auth-token');

    
    userProvider.setUser(jsonEncode({
      "id": "",
      "name": "",
      "email": "",
      "token": "",
      "password": ""
    }));

    
    http.Response res = await http.post(
      Uri.parse('${Constants.uri}/api/signout'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    if (res.statusCode == 200) {
      showSnackBar(context, "Successfully signed out.");
    } else {
      showSnackBar(context, "Error signing out: ${res.body}");
    }

    
    navigator.pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (route) => false,
    );
  } catch (e) {
    showSnackBar(context, "Error: $e");
  }
}

}
