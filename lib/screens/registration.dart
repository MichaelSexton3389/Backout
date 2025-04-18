import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:BackOut/screens/login_screen.dart';
import 'package:BackOut/services/auth_services.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({Key? key}) : super(key: key);

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  // Default placeholder until fetched
  String displayName = 'You';
  
  final TextEditingController bioController = TextEditingController();
  final List<String> activities = [
    'swimming.png', 'biking.png', 'lifting.png', 'running.png',
    'skiing.png', 'snowboarding.png', 'hiking.png', 'hockey.png',
    'soccer.png', 'kayaking.png', 'basketball.png', 'three_circle_fill.png',
  ];
  final List<String> activityNames = [
    'swimming', 'biking', 'lifting', 'running',
    'skiing', 'snowboarding', 'hiking', 'hockey',
    'soccer', 'kayaking', 'basketball', 'three_circle_fill',
  ];
  final Set<int> selected = {};

  @override
  void initState() {
    super.initState();
    _fetchUserName();
  }

  Future<void> _fetchUserName() async {
    try {
      final uri = Uri.parse('http://constants.uri/api/user/users');
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final List<dynamic> users = jsonDecode(response.body);
        if (users.isNotEmpty && users[0]['name'] != null) {
          setState(() {
            displayName = users[0]['name'];
          });
        }
      } else {
        debugPrint('Failed to load user name: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching user name: $e');
    }
  }
  Future<bool> _saveBioToServer() async {
  // Replace with your real user ID or pull it from your auth state
  final userId = 'CURRENT_USER_ID';
  final uri = Uri.parse('http://constants.uri/api/user/users/$userId');
  
  final response = await http.put(
    uri,
    headers: {
      'Content-Type': 'application/json',
      // include auth header if needed, e.g. 'Authorization': 'Bearer $token'
    },
      body: jsonEncode({
        'bio': bioController.text.trim(),
      }),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      debugPrint(
        'Failed to save bio: ${response.statusCode} ${response.body}'
      );
      return false;
    }
  }

  void toggleSelection(int index) {
    setState(() {
      if (selected.contains(index)) {
        selected.remove(index);
      } else {
        selected.add(index);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFc31432),
              Color(0xFF240b36),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 16),
                const Text(
                  'Registration',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: CircleAvatar(
                    radius: 50,
                    backgroundImage:
                        AssetImage('assets/profile_placeholder.png'),
                  ),
                ),
                const SizedBox(height: 12),
                // Display fetched name
                Text(
                  'About $displayName',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: bioController,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: 'Short description about you',
                    filled: true,
                    fillColor: Colors.grey[200],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'What interests you?',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: GridView.count(
                    crossAxisCount: 4,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    children: List.generate(activities.length, (i) {
                      final isSelected = selected.contains(i);
                      return GestureDetector(
                        onTap: () => toggleSelection(i),
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isSelected ? Colors.lightBlue : Colors.white,
                          ),
                          padding: const EdgeInsets.all(8),
                          child: Image.asset((
                            'assets/${activities[i]}'
                          ),
                        ),
                        )
                      );
                    }),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.search),
                      label: const Text('More Activities!'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.lightBlue,
                        shape: const StadiumBorder(),
                        padding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 20),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        _saveBioToServer();
                        Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                      );},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.lightBlue,
                        shape: const StadiumBorder(),
                        padding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 20),
                      ),
                      child: const Text('Ready to get Backout?'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
