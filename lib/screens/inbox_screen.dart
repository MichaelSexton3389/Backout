import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:BackOut/screens/chat_screen.dart';
import 'package:BackOut/screens/ClubScreen.dart';
import 'package:BackOut/screens/find_clubs_screen.dart'; // New import
import 'package:BackOut/utils/constants.dart';

class InboxScreen extends StatefulWidget {
  final String currentUser; // Logged-in user

  InboxScreen({required this.currentUser});

  @override
  _InboxScreenState createState() => _InboxScreenState();
}

class _InboxScreenState extends State<InboxScreen> with SingleTickerProviderStateMixin {
  List<Map<String, dynamic>> users = [];
  bool _isLoading = true;
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    fetchUsers();
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> fetchUsers() async {
    try {
      final response = await http.get(
        Uri.parse('${Constants.uri}/api/user/users'),
      );
      if (response.statusCode == 200) {
        List<dynamic> usersJson = json.decode(response.body);
        setState(() {
          users = usersJson
              .map((user) => {'name': user['name'], 'id': user['_id'], 'profile_picture': user['profile_picture']})
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
    final clubs = [
      {'name': 'Boulder Freeride', 'id': '1', 'members': '300 Members', 'image': 'https://live.staticflickr.com/3500/3845264221_1435f80f18_c.jpg'},
      {'name': 'Hiking Club', 'id': '2', 'members': '150 Members', 'image': 'https://live.staticflickr.com/3500/3845264221_1435f80f18_c.jpg'},
    ];
    
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF6A1B1A), // Deep red
            Color(0xFF0D3B4C), // Dark bluish
          ],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text("Inbox", style: TextStyle(color: Colors.white)),
        ),
        body: Column(
          children: [
            // Custom styled toggle
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
              child: Container(
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25),
                  ),
                  labelColor: Colors.black,
                  unselectedLabelColor: Colors.white,
                  tabs: [
                    Tab(text: 'Clubs'),
                    Tab(text: 'Buddies'),
                  ],
                ),
              ),
            ),
            
            // Tab content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Clubs tab
                  _buildClubsTab(clubs, context),
                  
                  // Buddies tab
                  _isLoading
                    ? Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.white)))
                    : _buildBuddiesTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildClubsTab(List<Map<String, dynamic>> clubs, BuildContext context) {
    return Stack(
      children: [
        // Clubs list
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView.builder(
            itemCount: clubs.length,
            itemBuilder: (context, index) {
              final club = clubs[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => ClubScreen(clubData: {
                              'name': club['name'],
                              'memberCount': int.parse(club['members'].split(' ')[0]),
                              'description': 'Welcome to a community of outdoor enthusiasts!',
                              'image': club['image'],
                              'upcoming': [
                                {
                                  'title': 'Winter Park this weekend',
                                  'location': '9am',
                                  'distance': '75mi!!',
                                },
                                {
                                  'title': 'Betasso Preserve Sunset Shred & Chill',
                                  'location': '5pm',
                                  'distance': '7mi!!',
                                },
                              ],
                              'nextMeeting': {
                                'day': 'Wednesday',
                                'date': 'Dec 9',
                                'items': ['Weekly Meeting', 'Copper Trip'],
                              },
                            })),
                          );
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Club image
                            Container(
                              height: 150,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  image: NetworkImage(club['image']),
                                  fit: BoxFit.cover,
                                ),
                              ),
                              child: Stack(
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: [
                                          Colors.transparent,
                                          Colors.black.withOpacity(0.7),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 16,
                                    left: 16,
                                    child: Text(
                                      club['name'],
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            
                            // Club info
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    club['members'],
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.8),
                                      fontSize: 16,
                                    ),
                                  ),
                                  Text(
                                    'View',
                                    style: TextStyle(
                                      color: Colors.purple[100],
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
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
                ),
              );
            },
          ),
        ),
        
        // Find clubs button
        Positioned(
          bottom: 20,
          right: 20,
          child: FloatingActionButton.extended(
            backgroundColor: Colors.white.withOpacity(0.2),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => FindClubsScreen()),
              );
            },
            icon: Icon(Icons.search, color: Colors.white),
            label: Text(
              "Find Clubs",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildBuddiesTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView.builder(
        itemCount: users.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 10.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                leading: CircleAvatar(
                  backgroundColor: Colors.black.withOpacity(0.5),
                  backgroundImage: users[index]['profile_picture'] != null &&
                          users[index]['profile_picture'].isNotEmpty
                      ? NetworkImage(users[index]['profile_picture'])
                      : null,
                  child: users[index]['profile_picture'] == null ||
                          users[index]['profile_picture'].isEmpty
                      ? Icon(Icons.person, color: Colors.white)
                      : null,
                ),
                title: Text(
                  users[index]['name']!,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  'Tap to chat',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                  ),
                ),
                trailing: Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white.withOpacity(0.5),
                  size: 16,
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatScreen(
                        currentUser: widget.currentUser,
                        receiverUser: users[index]['name']!,
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}