import 'package:flutter/material.dart';
import 'package:BackOut/providers/user_providers.dart';
import 'package:BackOut/services/auth_services.dart';
import 'package:provider/provider.dart';
import 'package:BackOut/screens/ProfileScreen.dart';
import 'package:BackOut/widgets/activity_card.dart';
// import 'package:BackOut/widgets/create_acitivity_form.dart';
import 'package:BackOut/widgets/modal_background.dart';
import 'package:BackOut/screens/inbox_screen.dart';
import 'package:BackOut/widgets/glassmorphic_container.dart';
import 'package:BackOut/widgets/activity_pals_invite.dart';
import 'package:BackOut/widgets/create_activty_form.dart';
import 'package:BackOut/screens/buddy_req_screen.dart';

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
      _currentActivityIndex =
          (_currentActivityIndex + 1) % activities.length;
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
            icon: CircleAvatar(
              radius: 15,
              backgroundImage: user.profilePicture != null &&
                      user.profilePicture!.isNotEmpty
                  ? NetworkImage(user.profilePicture!)
                  : null,
              backgroundColor: Colors.grey.shade300,
              child: user.profilePicture == null || user.profilePicture!.isEmpty
                  ? const Icon(Icons.account_circle,
                      size: 30, color: Colors.white)
                  : null,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProfileScreen(
                    currentUser: user,
                    profileUser: user,
                  ),
                ),
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
              leading: const Icon(Icons.logout),
              title: const Text("Sign Out"),
              onTap: () async {
                AuthService().signOut(context: context);
              },
            ),
          ],
        ),
      ),
      body: Padding(
        padding:
            const EdgeInsets.symmetric(horizontal: 20.0, vertical: 30.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            GestureDetector(
              onVerticalDragEnd: (details) {
                if (details.primaryVelocity! < 2) {
                  _nextActivity(); // Swipe up to change activity
                }
              },
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 500),
                transitionBuilder:
                    (Widget child, Animation<double> animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: child,
                  );
                },
                child: ActivityCard(
                  key: ValueKey(
                      activities[_currentActivityIndex]["title"]),
                  title: activities[_currentActivityIndex]["title"]!,
                  date: activities[_currentActivityIndex]["date"]!,
                  time: activities[_currentActivityIndex]["time"]!,
                  location: activities[_currentActivityIndex]["location"]!,
                  imageUrl: activities[_currentActivityIndex]["imageUrl"]!,
                  description:
                      activities[_currentActivityIndex]["description"]!,
                ),
              ),
            ),
            // const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CreateActivityButton(
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      barrierColor: Colors.black12,
                      builder: (context) {
                        return FractionallySizedBox(
                          heightFactor: 0.85,
                          child: ModalBackground(
                            child: Material(
                              type: MaterialType.transparency,
                              child: CreateActivityFormUpdated(),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
                const SizedBox(width: 20),
                BuddyRequestButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const BuddyRequestScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class CreateActivityButton extends StatelessWidget {
  final VoidCallback onPressed;

  const CreateActivityButton({Key? key, required this.onPressed})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: GlassmorphicContainer(
        width: 150,
        height: 150,
        child: Center(
          child: ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              colors: [
                Color.fromARGB(255, 169, 55, 189),
                Color.fromARGB(255, 74, 17, 90),
              ],
            ).createShader(Rect.fromLTWH(0, 0, bounds.width, bounds.height)),
            child: const Text(
              "Ready to get Back Out?",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white, // Will be masked by shader
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class BuddyRequestButton extends StatelessWidget {
  final VoidCallback onPressed;

  const BuddyRequestButton({Key? key, required this.onPressed})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: GlassmorphicContainer(
        width: 150,
        height: 150,
        child: Center(
          child: ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              colors: [
                Color.fromARGB(255, 55, 189, 141),
                Color.fromARGB(255, 17, 90, 74),
              ],
            ).createShader(Rect.fromLTWH(0, 0, bounds.width, bounds.height)),
            child: const Text(
              "Find Buddies",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}