import 'package:flutter/material.dart';
import 'package:BackOut/providers/user_providers.dart';
import 'package:BackOut/services/auth_services.dart';
import 'package:provider/provider.dart';
import 'package:BackOut/screens/ProfileScreen.dart';
import 'package:BackOut/widgets/activity_card.dart';
import 'package:BackOut/screens/inbox_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentActivityIndex = 0;

  final List<Map<String, String>> activities = [
    {
      "title": "Hiking at Chautauqua",
      "date": "Saturday, Nov 3",
      "time": "8 AM",
      "location": "Chautauqua Trail Start",
      "imageUrl":
          "https://live.staticflickr.com/3500/3845264221_1435f80f18_c.jpg",
      "description": "Perfect day to explore the Flatirons!"
    },
    {
      "title": "Sunset Yoga",
      "date": "Sunday, Nov 4",
      "time": "6 PM",
      "location": "Boulder Creek Park",
      "imageUrl":
          "https://live.staticflickr.com/7381/12369616423_2a5d035436_c.jpg",
      "description": "Relax and unwind with an evening yoga session."
    },
    {
      "title": "Rock Climbing",
      "date": "Monday, Nov 5",
      "time": "10 AM",
      "location": "Eldorado Canyon",
      "imageUrl":
          "https://live.staticflickr.com/1568/25281518844_3ea51e32ef_c.jpg",
      "description": "Challenge yourself with rock climbing."
    },
  ];

  void _nextActivity() {
    setState(() {
      _currentActivityIndex = (_currentActivityIndex + 1) % activities.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).user;

    return Scaffold(
      appBar: AppBar(
        title: const Text("BackOut"),
        actions: [
        IconButton(
          icon: const Icon(Icons.chat_bubble_outline, size: 30),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => InboxScreen(currentUser: user.name),
              ),
            );
          },
        ),
          IconButton(
            icon: const Icon(Icons.account_circle, size: 30),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const ProfileScreen()),
              );
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            
            UserAccountsDrawerHeader(
              accountName: Text(user.name),
              accountEmail: Text(user.email),
              // currentAccountPicture: CircleAvatar(
                // backgroundImage: NetworkImage(user.profileImageUrl),
              // ),
              decoration: BoxDecoration(
                color: Colors.black,
            ),
            ),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text("Sign Out"),
              onTap: () async {
              // await AuthService().signOut();
              // Navigator.of(context).pop();
            },
            ),
          ],
        ),
      ),
      body: Center(
        child: GestureDetector(
          onVerticalDragEnd: (details) {
            if (details.primaryVelocity! < 2) {
              _nextActivity(); // Swipe up to change activity
            }
          },
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 500),
            transitionBuilder: (Widget child, Animation<double> animation) {
              return FadeTransition(
                opacity: animation,
                child: child,
              );
            },
            child: ActivityCard(
              key: ValueKey(activities[_currentActivityIndex]["title"]),
              title: activities[_currentActivityIndex]["title"]!,
              date: activities[_currentActivityIndex]["date"]!,
              time: activities[_currentActivityIndex]["time"]!,
              location: activities[_currentActivityIndex]["location"]!,
              imageUrl: activities[_currentActivityIndex]["imageUrl"]!,
              description: activities[_currentActivityIndex]["description"]!,
            ),
          ),
        ),
      ),
    );
  }
}
