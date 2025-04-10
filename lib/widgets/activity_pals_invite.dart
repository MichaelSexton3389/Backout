import 'package:flutter/material.dart';
import 'user_cards.dart'; // or buddy_card.dart
import 'package:BackOut/screens/home_screen.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:BackOut/providers/user_providers.dart';

class InvitePalsScreen extends StatelessWidget {
   final String title;
  final String location;
  final String description;
  final String bgImg;
  final String date;
  
  const InvitePalsScreen({
    Key? key,
    required this.title,
    required this.location,
    required this.description,
    required this.bgImg,
    required this.date,
  }) : super(key: key);

  // Function to fetch pals from the backend route
  Future<dynamic> fetchPals(BuildContext context) async {
    // TODO: Replace with the actual user ID, perhaps via constructor or auth service
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final String userId = userProvider.user.id;
    // TODO: Replace with your actual API URL
    final url = Uri.parse("http://localhost:3000/api/user/$userId/pals");
    final response = await http.get(url);
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to load pals: ${response.body}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          "Invite Buddies",
          style: TextStyle(
            color: Color.fromARGB(255, 185, 185, 185),
            fontFamily: 'Poppins',
            fontSize: 40,
          ),
        ),
      ),
      body: FutureBuilder(
        future: fetchPals(context),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else {
            final data = snapshot.data;
            // Check if a message is returned (e.g., no pals message)
            if (data is Map && data.containsKey('message')) {
              return Center(child: Text(data['message']));
            } else if (data is Map && data.containsKey('pals')) {
              final pals = data['pals'] as List<dynamic>;
              if (pals.isEmpty) {
                return const Center(child: Text("No buddies yet, add some"));
              }
              return GridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                childAspectRatio: 0.7,
                children: pals.map((pal) {
                  return BuddyCard(
                    name: pal['name'] ?? 'No Name',
                    imageUrl: pal['profile_picture'] ?? '',
                    onInvite: () {
                      // TODO: handle invite logic here
                    },
                  );
                }).toList(),
              );
            } else {
              return const Center(child: Text("Unexpected response"));
            }
          }
        },
      ),
      floatingActionButton: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color.fromARGB(255, 255, 255, 255),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(40),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
        onPressed: () async {
  final userProvider = Provider.of<UserProvider>(context, listen: false);
  final token = userProvider.user.token;
 
  final response = await http.post(
    Uri.parse("http://localhost:3000/api/activities"),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    },
    body: jsonEncode({
      'title': title,
      'location': location,
      'description': description,
      'bg_img': bgImg,
      'date': date,
      'participants':[],
    }),
  );

  if (response.statusCode == 201) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const HomeScreen()),
    );
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Failed to create activity: ${response.body}")),
    );
  }
},
        child: const Text('Create Activity', style: TextStyle(color: Colors.black)),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}