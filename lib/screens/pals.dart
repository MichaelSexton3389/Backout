import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'upcoming.dart';

class PalsScreen extends StatefulWidget {
  const PalsScreen({Key? key}) : super(key: key);

  @override
  _PalsScreenState createState() => _PalsScreenState();
}

class _PalsScreenState extends State<PalsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // Sample memories data
  final List<Map<String, dynamic>> memories = [
    {
      'title': 'Winter Park Trip',
      'date': 'Feb 15, 2025',
      'image': 'https://live.staticflickr.com/3500/3845264221_1435f80f18_c.jpg',
      'participants': 12,
    },
    {
      'title': 'Chautauqua Hike',
      'date': 'Mar 5, 2025',
      'image': 'https://live.staticflickr.com/7381/12369616423_2a5d035436_c.jpg',
      'participants': 8,
    },
    {
      'title': 'Valmont Bike Park',
      'date': 'Mar 12, 2025',
      'image': 'https://live.staticflickr.com/1568/25281518844_3ea51e32ef_c.jpg',
      'participants': 5,
    },
    {
      'title': 'Boulder Canyon Climbing',
      'date': 'Mar 18, 2025',
      'image': 'https://images.pexels.com/photos/2404055/pexels-photo-2404055.jpeg',
      'participants': 6,
    },
    {
      'title': 'Boulder Creek Run',
      'date': 'Mar 22, 2025',
      'image': 'https://images.pexels.com/photos/1387037/pexels-photo-1387037.jpeg',
      'participants': 9,
    },
    {
      'title': 'Barker Reservoir Kayaking',
      'date': 'Mar 28, 2025',
      'image': 'https://images.pexels.com/photos/1497585/pexels-photo-1497585.jpeg',
      'participants': 4,
    },
  ];

  List<Map<String, dynamic>> get filteredMemories {
    if (_searchQuery.isEmpty) {
      return memories;
    }
    
    return memories.where((memory) {
      return memory['title'].toString().toLowerCase().contains(_searchQuery.toLowerCase()) ||
             memory['date'].toString().toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF6A1B1A),
            Color(0xFF000000),
            Color(0xFF0D3B4C),
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
              const Text(
                "Memories",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 30,
                  color: Color.fromARGB(255, 255, 255, 255),
                ),
              ),
              const SizedBox(width: 16),
              GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    PageRouteBuilder(
                      pageBuilder: (_, __, ___) => const HomeScreen(),
                      transitionsBuilder: (_, animation, __, child) {
                        return SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0, 1),
                            end: Offset.zero,
                          ).animate(animation),
                          child: child,
                        );
                      },
                    ),
                  );
                },
                child: const Text(
                  "BackOut",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: Colors.grey,
                  ),
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
                child: const Text(
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
                    hintText: "Search memories...",
                    hintStyle: TextStyle(color: Colors.white60),
                    prefixIcon: Icon(Icons.search, color: Colors.white60),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 15),
                  ),
                ),
              ),
            ),
            
            // Memories grid
            Expanded(
              child: filteredMemories.isEmpty
                  ? Center(
                      child: Text(
                        "No memories found",
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
                      itemCount: filteredMemories.length,
                      itemBuilder: (context, index) {
                        final memory = filteredMemories[index];
                        return _buildMemoryCard(memory);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildMemoryCard(Map<String, dynamic> memory) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(24),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Image
          Image.network(
            memory['image'],
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
          
          // Memory title
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
                memory['title'],
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
                  // Date
                  Text(
                    memory['date'],
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  SizedBox(height: 8),
                  
                  // Participants
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.people,
                            size: 16,
                            color: Colors.white70,
                          ),
                          SizedBox(width: 4),
                          Text(
                            "${memory['participants']} buddies",
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white24,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          "View",
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
    );
  }
}