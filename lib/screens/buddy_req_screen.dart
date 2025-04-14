import 'package:flutter/material.dart';
import 'package:BackOut/providers/user_providers.dart';
import 'package:BackOut/services/user_service.dart';
import 'package:BackOut/widgets/user_cards.dart';
import 'package:BackOut/screens/ProfileScreen.dart';
import 'package:BackOut/models/user.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';

class BuddyRequestScreen extends StatefulWidget {
  const BuddyRequestScreen({super.key});

  @override
  State<BuddyRequestScreen> createState() => _BuddyRequestScreenState();
}

class _BuddyRequestScreenState extends State<BuddyRequestScreen> {
  List<Map<String, dynamic>> users = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadUsers();
  }

  Future<User> fetchUserById(String userId) async {
  final response = await http.get(Uri.parse('http://localhost:3000/api/user/$userId'));

  if (response.statusCode == 200) {
    final Map<String, dynamic> data = json.decode(response.body);
    return User.fromJson(data['user']); // Note: assumes API response is { user: { ... } }
  } else {
    throw Exception('Failed to load user');
  }
}

  Future<void> loadUsers() async {
    try {
      users = await fetchUsers();
    } catch (e) {
      print("Error fetching users: $e");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Find Buddies'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : GridView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: users.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.72,
              ),
              itemBuilder: (context, index) {
                final user = users[index];
                return BuddyCard(
                  name: user['name'],
                  imageUrl: (user['profile_picture'] != null && user['profile_picture'].toString().isNotEmpty)
  ? user['profile_picture']
  : 'https://images.pexels.com/photos/96938/pexels-photo-96938.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=2',
                  buttonText: 'Add Pal',
                  onInvite: () {
                    print('Invited ${user['name']}');
                  },
                  onTap: () async {
  try {
    // Check for user id in either '_id' or 'id' and fallback if needed
    final userId = user['_id'] ?? user['id'];
    if (userId == null || userId.toString().isEmpty) {
      throw Exception('User ID not found');
    }
    final profileUser = await fetchUserById(userId);
    final currentUser = Provider.of<UserProvider>(context, listen: false).user;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProfileScreen(
          currentUser: currentUser,
          profileUser: profileUser,
        ),
      ),
    );
  } catch (e) {
    print('Error loading user: $e');
  }
},
                );
              },
            ),
    );
  }
}
