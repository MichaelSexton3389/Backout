import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("User Profile"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // ✅ Navigate back to HomeScreen
          },
        ),
      ),
      body: Center(
        child:
            Text("This is the Profile Page!", style: TextStyle(fontSize: 20)),
      ),
    );
  }
}
