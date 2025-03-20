import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'chat_screen.dart';

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
      final response = await http.get(Uri.parse('https://my-backend-service-952120514384.us-central1.run.app/api/user/users'));
      if (response.statusCode == 200) {
        List<dynamic> usersJson = json.decode(response.body);
        setState(() {
          users = usersJson
              .map((user) => {'name': user['name'], 'id': user['_id']})
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
                    backgroundColor: Colors.blueGrey,
                    child: Text(users[index]['name']![0].toUpperCase()), // User's initial
                  ),
                  title: Text(users[index]['name']!),
                  onTap: () {
                    // Navigate to ChatScreen with selected user as User 2
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatScreen(
                          currentUser: widget.currentUser,
                          receiverUser: users[index]['name']!, // Set as User 2
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