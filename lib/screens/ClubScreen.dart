import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ClubScreen extends StatefulWidget {
  final Map<String, dynamic>? clubData;

  ClubScreen({this.clubData});

  @override
  _ClubScreenState createState() => _ClubScreenState();
}

class _ClubScreenState extends State<ClubScreen> {
  bool isJoined = false;
  int selectedTabIndex = 0;
  
  @override
  Widget build(BuildContext context) {
    // Mock data for two clubs
    final clubData = widget.clubData ?? {
      'name': 'Boulder Freeride',
      'memberCount': 2,
      'description': 'Welcome to a community of outdoor enthusiasts!',
      'image': 'https://live.staticflickr.com/3500/3845264221_1435f80f18_c.jpg',
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
        {
          'title': 'Trek Jam & Workshop Valmont BP',
          'location': '1pm',
          'distance': '4mi!!',
        },
      ],
      'nextMeeting': {
        'day': 'Wednesday',
        'date': 'Dec 9',
        'items': ['Weekly Meeting', 'Copper Trip'],
      },
    };

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF1A0000),
            Color(0xFF3D0A0A),
            Color(0xFF0D243D),
          ],
          stops: [0.0, 0.5, 1.0],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text(clubData['name']),
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Club image and name
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Stack(
                    children: [
                      Image.network(
                        clubData['image'],
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withOpacity(0.8),
                              ],
                            ),
                          ),
                          child: Text(
                            clubData['name'],
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                SizedBox(height: 20),
                
                // Member count and join button
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Member Count',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            '${clubData['memberCount']}',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          isJoined = !isJoined;
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white.withOpacity(0.2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                      child: Text(
                        isJoined ? 'Members' : 'Join',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                
                SizedBox(height: 10),
                
                // Club description
                Text(
                  clubData['description'],
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 14,
                  ),
                ),
                
                SizedBox(height: 20),
                
                // Upcoming Events Section
                Container(
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Upcoming',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 12),
                      ...clubData['upcoming'].map<Widget>((event) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.4),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    '${event['title']} @ ${event['location']} - ${event['distance']}',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    'Join',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                ),
                
                SizedBox(height: 20),
                
                // Activity Icons Row 1
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildIconTile(Icons.camera, Colors.black),
                    _buildIconTile(Icons.photo, Colors.white),
                  ],
                ),
                
                SizedBox(height: 12),
                
                // Activity Icons Row 2
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildActivityIconsGrid(),
                    _buildNextMeetingTile(clubData['nextMeeting']),
                  ],
                ),
                
                SizedBox(height: 12),
                
                // Bottom Icons Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildIconTile(Icons.shield, Colors.black),
                    _buildIconTile(Icons.star, Colors.blueGrey),
                  ],
                ),
                
                SizedBox(height: 50),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildIconTile(IconData icon, Color backgroundColor) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.44,
      height: 90,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: Icon(
          icon,
          color: Colors.white,
          size: 36,
        ),
      ),
    );
  }
  
  Widget _buildActivityIconsGrid() {
    return Container(
      width: MediaQuery.of(context).size.width * 0.44,
      height: 90,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: EdgeInsets.all(8),
      child: GridView.count(
        crossAxisCount: 4,
        physics: NeverScrollableScrollPhysics(),
        children: [
          _buildSmallIcon(Icons.directions_bike),
          _buildSmallIcon(Icons.directions_walk),
          _buildSmallIcon(Icons.public),
          _buildSmallIcon(Icons.pool),
          _buildSmallIcon(Icons.snowboarding),
          _buildSmallIcon(Icons.kayaking),
          _buildSmallIcon(Icons.hiking),
          _buildSmallIcon(Icons.nordic_walking),
          _buildSmallIcon(Icons.sports_soccer),
          _buildSmallIcon(Icons.sports_basketball),
          _buildSmallIcon(Icons.sports_tennis),
          _buildSmallIcon(Icons.more_horiz),
        ],
      ),
    );
  }
  
  Widget _buildSmallIcon(IconData icon) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Icon(
          icon,
          color: Colors.white,
          size: 14,
        ),
      ),
    );
  }
  
  Widget _buildNextMeetingTile(Map<String, dynamic> meeting) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.44,
      height: 90,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            meeting['day'],
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            meeting['date'],
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 12,
            ),
          ),
          SizedBox(height: 6),
          ...meeting['items'].map<Widget>((item) {
            return Row(
              children: [
                Container(
                  width: 5,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.8),
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: 5),
                Text(
                  item,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 12,
                  ),
                ),
              ],
            );
          }).toList(),
        ],
      ),
    );
  }
}

// Use this to navigate to the club screen
// Navigator.push(
//   context,
//   MaterialPageRoute(
//     builder: (context) => ClubScreen(
//       clubData: {
//         'name': 'Hiking Club', 
//         'memberCount': 150,
//         'description': 'For those who love exploring trails!',
//         'image': 'https://live.staticflickr.com/7381/12369616423_2a5d035436_c.jpg',
//         'upcoming': [
//           {
//             'title': 'Chautauqua Park Hike',
//             'location': '8am',
//             'distance': '3mi',
//           },
//           {
//             'title': 'Royal Arch Trail',
//             'location': '7am',
//             'distance': '4mi',
//           },
//           {
//             'title': 'Green Mountain Summit',
//             'location': '6am',
//             'distance': '6mi',
//           },
//         ],
//         'nextMeeting': {
//           'day': 'Tuesday',
//           'date': 'Dec 15',
//           'items': ['Trail Planning', 'Gear Exchange'],
//         },
//       },
//     ),
//   ),
// );