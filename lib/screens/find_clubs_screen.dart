import 'package:flutter/material.dart';
import 'package:BackOut/screens/ClubScreen.dart';

class FindClubsScreen extends StatefulWidget {
  @override
  _FindClubsScreenState createState() => _FindClubsScreenState();
}

class _FindClubsScreenState extends State<FindClubsScreen> {
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  
  // Sample club data with shorter descriptions
  final List<Map<String, dynamic>> allClubs = [
    {
      'name': 'Boulder Freeride',
      'description': 'Skiing and snowboarding enthusiasts.',
      'members': 300,
      'image': 'https://live.staticflickr.com/3500/3845264221_1435f80f18_c.jpg',
      'tags': ['skiing', 'snowboarding', 'winter'],
    },
    {
      'name': 'Hiking Club',
      'description': 'Weekly hikes around Boulder.',
      'members': 150,
      'image': 'https://live.staticflickr.com/7381/12369616423_2a5d035436_c.jpg',
      'tags': ['hiking', 'trails', 'mountains'],
    },
    {
      'name': 'Mountain Biking Crew',
      'description': 'Shredding single tracks and downhill trails.',
      'members': 125,
      'image': 'https://live.staticflickr.com/1568/25281518844_3ea51e32ef_c.jpg',
      'tags': ['biking', 'trails', 'mountains'],
    },
    {
      'name': 'Bouldering Buffs',
      'description': 'Indoor and outdoor climbing year-round.',
      'members': 180,
      'image': 'https://images.pexels.com/photos/2404055/pexels-photo-2404055.jpeg',
      'tags': ['climbing', 'bouldering', 'fitness'],
    },
    {
      'name': 'Trail Runners',
      'description': 'Morning and sunset trail runs.',
      'members': 95,
      'image': 'https://images.pexels.com/photos/1387037/pexels-photo-1387037.jpeg',
      'tags': ['running', 'trails', 'fitness'],
    },
    {
      'name': 'Kayak Club',
      'description': 'Exploring Colorado waters together.',
      'members': 75,
      'image': 'https://images.pexels.com/photos/1497585/pexels-photo-1497585.jpeg',
      'tags': ['kayaking', 'water', 'paddling'],
    },
    {
      'name': 'Photography Hikers',
      'description': 'Capture nature while hiking.',
      'members': 110,
      'image': 'https://images.pexels.com/photos/1777086/pexels-photo-1777086.jpeg',
      'tags': ['photography', 'hiking', 'nature'],
    },
    {
      'name': 'Camping Crew',
      'description': 'Weekend camping adventures.',
      'members': 220,
      'image': 'https://images.pexels.com/photos/2516423/pexels-photo-2516423.jpeg',
      'tags': ['camping', 'outdoors', 'backpacking'],
    },
    {
      'name': 'Fly Fishing Friends',
      'description': 'Peaceful days on Colorado rivers.',
      'members': 60,
      'image': 'https://images.pexels.com/photos/190247/pexels-photo-190247.jpeg',
      'tags': ['fishing', 'rivers', 'outdoors'],
    },
  ];
  
  List<Map<String, dynamic>> get filteredClubs {
    if (_searchQuery.isEmpty) {
      return allClubs;
    }
    
    return allClubs.where((club) {
      return club['name'].toString().toLowerCase().contains(_searchQuery.toLowerCase()) ||
             club['description'].toString().toLowerCase().contains(_searchQuery.toLowerCase()) ||
             club['tags'].any((tag) => tag.toString().toLowerCase().contains(_searchQuery.toLowerCase()));
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
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
          title: Text("Discover Clubs"),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Column(
          children: [
            // Search bar
            Padding(
              padding: EdgeInsets.all(16),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: TextField(
                  controller: _searchController,
                  style: TextStyle(color: Colors.white),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: "Search clubs...",
                    hintStyle: TextStyle(color: Colors.white60),
                    prefixIcon: Icon(Icons.search, color: Colors.white60),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 15),
                  ),
                ),
              ),
            ),
            
            // Clubs grid - 2 across
            Expanded(
              child: filteredClubs.isEmpty
                  ? Center(
                      child: Text(
                        "No clubs found",
                        style: TextStyle(color: Colors.white70, fontSize: 18),
                      ),
                    )
                  : GridView.builder(
                      padding: EdgeInsets.all(16),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.75,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                      ),
                      itemCount: filteredClubs.length,
                      itemBuilder: (context, index) {
                        final club = filteredClubs[index];
                        return _buildClubCard(club, context);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildClubCard(Map<String, dynamic> club, BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ClubScreen(
              clubData: {
                'name': club['name'],
                'memberCount': club['members'],
                'description': club['description'],
                'image': club['image'],
                'upcoming': [
                  {
                    'title': 'Weekend Activity',
                    'location': '9am',
                    'distance': '5mi',
                  },
                  {
                    'title': 'Sunset Meeting',
                    'location': '5pm',
                    'distance': '2mi',
                  },
                ],
                'nextMeeting': {
                  'day': 'Tuesday',
                  'date': 'Dec 5',
                  'items': ['Weekly Meeting', 'Gear Exchange'],
                },
              },
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.3),
          borderRadius: BorderRadius.circular(24),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Club image with name overlay
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Image
                  Image.network(
                    club['image'],
                    fit: BoxFit.cover,
                  ),
                  
                  // Gradient overlay
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                        ],
                        stops: [0.6, 1.0],
                      ),
                    ),
                  ),
                  
                  // Club name
                  Positioned(
                    top: 12,
                    left: 12,
                    right: 12,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        club['name'],
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  
                  // Bottom info section
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Short description
                          Text(
                            club['description'],
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          
                          SizedBox(height: 8),
                          
                          // Members count and join button
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "${club['members']} members",
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.white24,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  "Join",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}