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
  int _selectedTabIndex = 0; // 0 for Pals, 1 for Discover

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

  final List<Map<String, String>> discoverActivities = [
    {
      "title": "Mountain Biking",
      "date": "Friday, Nov 10",
      "time": "9 AM",
      "location": "Valmont Bike Park",
      "imageUrl":
          "https://live.staticflickr.com/3749/9586943958_ecb99d7162_c.jpg",
      "description": "Explore mountain biking trails for all skill levels!"
    },
    {
      "title": "Photography Hike",
      "date": "Saturday, Nov 11",
      "time": "7 AM",
      "location": "NCAR Trail",
      "imageUrl":
          "https://live.staticflickr.com/7322/16398331988_4a3c47c652_c.jpg",
      "description": "Capture the beautiful sunrise over Boulder."
    },
    {
      "title": "Kayaking Adventure",
      "date": "Sunday, Nov 12",
      "time": "11 AM",
      "location": "Boulder Reservoir",
      "imageUrl":
          "https://live.staticflickr.com/4099/4923499275_91f50798c7_c.jpg",
      "description": "Paddle through the reservoir's calm waters."
    },
  ];

  void _nextActivity() {
    setState(() {
      if (_selectedTabIndex == 0) {
        _currentActivityIndex = (_currentActivityIndex + 1) % activities.length;
      } else {
        _currentActivityIndex = (_currentActivityIndex + 1) % discoverActivities.length;
      }
    });
  }

  void _switchTab(int index) {
    setState(() {
      _selectedTabIndex = index;
      _currentActivityIndex = 0; // Reset to first activity when switching tabs
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).user;
    final currentActivities = _selectedTabIndex == 0 ? activities : discoverActivities;

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
              decoration: BoxDecoration(
                color: Colors.black,
              ),
            ),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text("Sign Out"),
              onTap: () async {
                AuthService().signOut(context: context);
              },
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Tab Selector
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => _switchTab(0),
                    child: Column(
                      children: [
                        Text(
                          "Pals",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: _selectedTabIndex == 0 ? Colors.blue : Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          height: 3,
                          color: _selectedTabIndex == 0 ? Colors.blue : Colors.transparent,
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () => _switchTab(1),
                    child: Column(
                      children: [
                        Text(
                          "Discover",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: _selectedTabIndex == 1 ? Colors.blue : Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          height: 3,
                          color: _selectedTabIndex == 1 ? Colors.blue : Colors.transparent,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Activity Card
          Expanded(
            child: GestureDetector(
              onVerticalDragEnd: (details) {
                if (details.primaryVelocity! < 0) {
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
                  key: ValueKey(currentActivities[_currentActivityIndex]["title"]),
                  title: currentActivities[_currentActivityIndex]["title"]!,
                  date: currentActivities[_currentActivityIndex]["date"]!,
                  time: currentActivities[_currentActivityIndex]["time"]!,
                  location: currentActivities[_currentActivityIndex]["location"]!,
                  imageUrl: currentActivities[_currentActivityIndex]["imageUrl"]!,
                  description: currentActivities[_currentActivityIndex]["description"]!,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}