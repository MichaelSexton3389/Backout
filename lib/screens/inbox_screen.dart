import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:BackOut/services/user_service.dart';
import 'dart:convert';
import 'chat_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'firebase_chat_screen.dart';

class InboxScreen extends StatefulWidget {
  final String currentUser; // Logged-in user

  InboxScreen({required this.currentUser});

  @override
  _InboxScreenState createState() => _InboxScreenState();
}

class _InboxScreenState extends State<InboxScreen> {
  List<Map<String, dynamic>> users = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchUsers();
  }

  Future<void> fetchUsers() async {
    try {
      final response = await http.get(Uri.parse('http://localhost:3000/api/user/users'));
      if (response.statusCode == 200) {
        List<dynamic> usersJson = json.decode(response.body);
        setState(() {
          users = usersJson
              .map((user) => {'name': user['name'], 'id': user['_id'], 'profile_picture': user['profile_picture']})
              .toList();
          _isLoading = false;
        });
      } else {
        throw Exception("Failed to load users");
      }
    } catch (e) {
      print("Error fetching users: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Inbox")),
      body: _isLoading
          ? Center(child: CircularProgressIndicator()) // Show loading
          : ListView.builder(
              itemCount: users.length,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.black,
                    backgroundImage: users[index]['profile_picture'] != null && users[index]['profile_picture'].isNotEmpty
                        ? NetworkImage(users[index]['profile_picture'])
                        : null, // Use network image if available
                    child: users[index]['profile_picture'] == null || users[index]['profile_picture'].isEmpty
                        ? Text(
                            users[index]['name'][0].toUpperCase(),
                            style: TextStyle(color: Colors.white)) // Show initial if no image
                        : null,
                  ),
                  title: Text(users[index]['name']!),
                  onTap: () async {
                    // Anonymous sign in to Firebase
                    await FirebaseAuth.instance.signInAnonymously();

                    // Create a dummy Firebase user (you can map Mongo ID to Firebase later)
                    final firebaseUser = types.User(
                      id: users[index]['id'], // Use MongoDB ID as Firebase UID
                      firstName: users[index]['name'],
                      imageUrl: users[index]['profile_picture'],
                    );

                    // Navigate to new Firebase chat screen
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FirebaseChatScreen(
                          peerUser: firebaseUser,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}