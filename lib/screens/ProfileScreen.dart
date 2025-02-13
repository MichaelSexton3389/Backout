import 'package:flutter/material.dart';
import 'package:BackOut/providers/user_providers.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});
  
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).user;
    String getInitials(String name) {
      List<String> nameParts = name.trim().split(" ");
      if (nameParts.isEmpty) return "";
      String initials = nameParts.map((part) => part[0].toUpperCase()).join();
      return initials.length > 2 ? initials.substring(0, 2) : initials; // Max 2 letters
    }
    return Scaffold(
      appBar: AppBar(
        
        title: Text("Profile"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // ✅ Navigate back to HomeScreen
          },
        ),
      ),
      body: Padding(
        padding:const EdgeInsets.symmetric(horizontal: 30, vertical:40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children:[
            CircleAvatar(
              radius: 40, // Size of the avatar
              backgroundColor: Colors.black, // Can be any color you like
              child: Text(
                getInitials(user.name), // Extracted initials
                style: const TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              user.name,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(user.email, style: const TextStyle(fontSize: 16, color: Colors.grey)),
          ]
        )
      )
    );
  }
}