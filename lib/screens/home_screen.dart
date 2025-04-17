import 'package:flutter/material.dart';
import 'package:BackOut/providers/user_providers.dart';
import 'package:BackOut/services/auth_services.dart';
import 'package:provider/provider.dart';
import 'package:BackOut/screens/ProfileScreen.dart';
import 'package:BackOut/widgets/activity_card.dart';
import 'package:BackOut/widgets/modal_background.dart';
import 'package:BackOut/screens/inbox_screen.dart';
import 'package:BackOut/widgets/glassmorphic_container.dart';
import 'package:BackOut/widgets/activity_pals_invite.dart';
import 'package:BackOut/widgets/create_activty_form.dart';
import 'package:BackOut/screens/buddy_req_screen.dart';
import 'package:BackOut/screens/calendar_screen.dart';
import 'package:BackOut/widgets/navbar.dart';
import 'package:BackOut/screens/pals.dart';
import 'package:BackOut/screens/upcoming.dart';
import 'package:BackOut/screens/leaderboard.dart'; // Add this import
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:BackOut/utils/constants.dart';
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentActivityIndex = 0;
  List<dynamic> activities = [];
  bool isLoading = true;

  void _nextActivity() {
    setState(() {
      _currentActivityIndex = (_currentActivityIndex + 1) % activities.length;
    });
  }

  Future<void> fetchActivities() async {
    final user = Provider.of<UserProvider>(context, listen: false).user;
    final url = Uri.parse('${Constants.uri}/api/user/${user.id}/upcoming-activity-details');
    try {
      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer ${user.token}'},
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        setState(() {
          activities = data['activities'];
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (_) {
      setState(() => isLoading = false);
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => fetchActivities());
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).user;

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF6A1B1A), // Deep red top left
            Color(0xFF0D3B4C), // Dark bluish bottom right
          ],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    PageRouteBuilder(
                      pageBuilder: (_, __, ___) => PalsScreen(),
                      transitionsBuilder: (_, animation, __, child) {
                        return SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(-1, 0),
                            end: Offset.zero,
                          ).animate(animation),
                          child: child,
                        );
                      },
                    ),
                  );
                },
                child: Text(
                  "Memories",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: Colors.grey,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              const Text( 
                "BackOut",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 30,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 16),
              GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    PageRouteBuilder(
                      pageBuilder: (_, __, ___) => UpcomingScreen(),
                      transitionsBuilder: (_, animation, __, child) {
                        return SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(1, 0),
                            end: Offset.zero,
                          ).animate(animation),
                          child: child,
                        );
                      },
                    ),
                  );
                },
                child: Text(
                  "Discover",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: Colors.grey,
                  ),
                ),
              ),
            ],
          ),
          centerTitle: true,
        ),
        body: Stack(
          children: [
            SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16.0, vertical: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onVerticalDragEnd: (details) {
                        if (details.primaryVelocity! < 2) {
                          _nextActivity();
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
                        child: isLoading
                            ? SizedBox(
                                height: 300,
                                child: Center(child: CircularProgressIndicator()),
                              )
                            : activities.isEmpty
                                ? SizedBox(
                                    height: 300,
                                    child: Center(child: Text('No upcoming activities')),
                                  )
                                : ActivityCard(
                                    key: ValueKey(activities[_currentActivityIndex]['_id']),
                                    title: activities[_currentActivityIndex]['title'] ?? '',
                                    date: DateFormat.yMMMd().add_jm().format(
                                      DateTime.parse(
                                        activities[_currentActivityIndex]['date'] as String
                                      ),
                                    ),
                                    time: '',
                                    location: activities[_currentActivityIndex]['location'] ?? '',
                                    imageUrl: activities[_currentActivityIndex]['bg_img'] ?? '',
                                    description: activities[_currentActivityIndex]['description'] ?? '',
                                  ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            width: 150,
                            height: 300,
                            decoration: const BoxDecoration(
                              image: DecorationImage(
                                image: AssetImage('assets/post img.png'),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Right side: Column for Find Buddies & Streak stacked vertically
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Find Buddies widget
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const BuddyRequestScreen(),
                                  ),
                                );
                              },
                              child: Stack(
                                children: [
                                  Positioned.fill(
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(16),
                                      child: Container(
                                        decoration: const BoxDecoration(
                                          image: DecorationImage(
                                            image: NetworkImage(
                                                "https://images.pexels.com/photos/5795688/pexels-photo-5795688.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=2"),
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(16),
                                    child: Container(
                                      width: 150,
                                      height: 150,
                                      color: Colors.black.withOpacity(0.4),
                                      alignment: Alignment.bottomCenter,
                                      padding:
                                          const EdgeInsets.only(bottom: 12),
                                      child: ShaderMask(
                                        shaderCallback: (bounds) =>
                                            const LinearGradient(
                                          colors: [Colors.white, Colors.white],
                                        ).createShader(Rect.fromLTWH(0, 0,
                                                bounds.width, bounds.height)),
                                        child: const Text(
                                          "Find Buddies",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.white,
                                            shadows: [
                                              Shadow(
                                                offset: Offset(0, 1),
                                                blurRadius: 2,
                                                color: Colors.black45,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                            // Streak widget with navigation to LeaderboardScreen
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => LeaderboardScreen(),
                                  ),
                                );
                              },
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: Container(
                                  width: 150,
                                  height: 150,
                                  color: Colors.white,
                                  child: Stack(
                                    children: [
                                      // Fire emoji near top-left
                                      Positioned(
                                        top: 5,
                                        left: 10,
                                        child: Text(
                                          "🔥",
                                          style: TextStyle(fontSize: 54),
                                        ),
                                      ),
                                      // Center the streak number & subtext
                                      Center(
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              "3",
                                              style: TextStyle(
                                                fontSize: 56,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            const Text(
                                              "#2 amongst buddies",
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500,
                                                color: Colors.black87,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
            FloatingNavBar(
              currentIndex: 0,
              profileImageUrl: user.profilePicture,
              onTap: (index) {
                if (index == 0) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const HomeScreen()),
                  );
                } else if (index == 1) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => CalendarScreen()),
                  );
                } else if (index == 2) {
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
                } else if (index == 3) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => InboxScreen(currentUser: user.name),
                    ),
                  );
                } else if (index == 4) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProfileScreen(
                        currentUser: user,
                        profileUser: user,
                      ),
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}