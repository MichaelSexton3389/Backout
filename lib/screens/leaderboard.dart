import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:BackOut/providers/user_providers.dart';

class LeaderboardScreen extends StatefulWidget {
  @override
  _LeaderboardScreenState createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  // Outdoor activity badges
  final Map<String, IconData> activityBadges = {
    'hiking': Icons.terrain,
    'skiing': Icons.downhill_skiing,
    'biking': Icons.directions_bike,
    'swimming': Icons.pool,
    'camping': Icons.cabin,
    'climbing': Icons.landscape,
  };
  
  // Dummy leaderboard data - sorted by streak
  final List<Map<String, dynamic>> leaderboardUsers = [
    {'name': 'Tony Hawk', 'photo': null, 'badges': ['skiing', 'hiking'], 'streak': 20, 'isOnline': true},
    {'name': 'Jackie Chan', 'photo': null, 'badges': ['biking', 'skiing', 'hiking'], 'streak': 18, 'isOnline': false},
    {'name': 'Shawn White', 'photo': null, 'badges': ['skiing', 'hiking', 'climbing'], 'streak': 15, 'isOnline': true},
    {'name': 'Joe Smith', 'photo': null, 'badges': ['skiing', 'hiking'], 'streak': 12, 'isOnline': false},
    {'name': 'Jakey Jake', 'photo': null, 'badges': ['skiing', 'hiking'], 'streak': 10, 'isOnline': false},
    {'name': 'Adam Apple', 'photo': null, 'badges': ['biking', 'swimming'], 'streak': 8, 'isOnline': true},
    {'name': 'Tommie Turner', 'photo': null, 'badges': ['biking'], 'streak': 7, 'isOnline': false},
    {'name': 'John Pork', 'photo': null, 'badges': ['swimming', 'hiking'], 'streak': 5, 'isOnline': false},
    {'name': 'Harper Harrison', 'photo': null, 'badges': ['camping'], 'streak': 4, 'isOnline': true},
    {'name': 'Evan Reals', 'photo': null, 'badges': ['camping'], 'streak': 3, 'isOnline': false},
    {'name': 'Joseph Jackson', 'photo': null, 'badges': ['camping'], 'streak': 2, 'isOnline': true},
    {'name': 'Michael Miggins', 'photo': null, 'badges': [], 'streak': 1, 'isOnline': false},
    {'name': 'Danny Didit', 'photo': null, 'badges': [], 'streak': 0, 'isOnline': false},
    {'name': 'Andy Perez', 'photo': null, 'badges': [], 'streak': 0, 'isOnline': false},
    {'name': 'Danny Dunit', 'photo': null, 'badges': [], 'streak': 0, 'isOnline': false},
  ];
  
  List<Color> _podiumColors = [
    Color(0xFFFFD700), // Gold
    Color(0xFFC0C0C0), // Silver
    Color(0xFFCD7F32), // Bronze
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
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
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text("Activity Streaks"),
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Column(
          children: [
            // Top banner with crown image
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.2),
                    Colors.transparent,
                  ],
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.emoji_events,
                    color: Colors.amber,
                    size: 50,
                  ),
                  SizedBox(height: 10),
                  Text(
                    "STREAK LEADERBOARD",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    "Who's getting outdoors the most?",
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            
            // Top 3 podium
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Second place
                  _buildPodiumItem(1, leaderboardUsers[1]),
                  // First place (taller)
                  _buildPodiumItem(0, leaderboardUsers[0], isFirst: true),
                  // Third place
                  _buildPodiumItem(2, leaderboardUsers[2]),
                ],
              ),
            ),
            
            // Divider with text
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Row(
                children: [
                  Expanded(child: Divider(color: Colors.white30)),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      "LEADERBOARD",
                      style: TextStyle(
                        color: Colors.white60,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Expanded(child: Divider(color: Colors.white30)),
                ],
              ),
            ),
            
            // List of users excluding top 3
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                itemCount: leaderboardUsers.length - 3, // Skip top 3
                itemBuilder: (context, index) {
                  final user = leaderboardUsers[index + 3]; // Skip top 3
                  return _buildLeaderboardTile(index + 4, user); // Start from position 4
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildPodiumItem(int position, Map<String, dynamic> user, {bool isFirst = false}) {
    double height = isFirst ? 120.0 : 100.0;
    
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // User avatar with badge
        Stack(
          children: [
            CircleAvatar(
              radius: isFirst ? 40 : 30,
              backgroundColor: Colors.white24,
              backgroundImage: user['photo'] != null ? NetworkImage(user['photo']) : null,
              child: user['photo'] == null
                  ? Icon(Icons.person, color: Colors.white, size: isFirst ? 30 : 24)
                  : null,
            ),
            if (isFirst)
              Positioned(
                top: -5,
                right: -5,
                child: Container(
                  padding: EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.amber,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.star,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
          ],
        ),
        SizedBox(height: 8),
        // User name
        Text(
          user['name'],
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: isFirst ? 14 : 12,
          ),
        ),
        // Streak
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.local_fire_department,
              color: Colors.orange,
              size: isFirst ? 20 : 16,
            ),
            SizedBox(width: 2),
            Text(
              "${user['streak']} days",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
                fontSize: isFirst ? 14 : 12,
              ),
            ),
          ],
        ),
        SizedBox(height: 6),
        // Podium platform
        Container(
          width: isFirst ? 100 : 80,
          height: height,
          decoration: BoxDecoration(
            color: _podiumColors[position].withOpacity(0.7),
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(8),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child: Text(
              "#${position + 1}",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: isFirst ? 22 : 18,
              ),
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildLeaderboardTile(int position, Map<String, dynamic> user) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 32,
              alignment: Alignment.center,
              child: Text(
                "$position",
                style: TextStyle(
                  color: Colors.white70,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
            SizedBox(width: 8),
            CircleAvatar(
              backgroundColor: Colors.white24,
              backgroundImage: user['photo'] != null ? NetworkImage(user['photo']) : null,
              child: user['photo'] == null
                  ? Icon(Icons.person, color: Colors.white)
                  : null,
            ),
          ],
        ),
        title: Text(
          user['name'],
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Activity badges
            ...?user['badges']?.map<Widget>((badge) {
              IconData icon = activityBadges[badge] ?? Icons.star;
              return Container(
                margin: EdgeInsets.only(right: 4),
                child: Icon(
                  icon,
                  color: Colors.white70,
                  size: 18,
                ),
              );
            }),
            SizedBox(width: 8),
            // Streak count
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: _getStreakColor(user['streak']).withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _getStreakColor(user['streak']).withOpacity(0.5),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.local_fire_department,
                    color: _getStreakColor(user['streak']),
                    size: 16,
                  ),
                  SizedBox(width: 4),
                  Text(
                    "${user['streak']} days",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        onTap: () {
          // Handle user selection
        },
      ),
    );
  }
  
  Color _getStreakColor(int streak) {
    if (streak >= 15) return Colors.amber;
    if (streak >= 10) return Colors.orange;
    if (streak >= 5) return Colors.deepOrange;
    return Colors.redAccent;
  }
}