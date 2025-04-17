import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'dart:ui'; // Add this import for ImageFilter
import 'package:http/http.dart' as http;
import 'package:BackOut/utils/constants.dart';
import 'package:BackOut/providers/user_providers.dart';
import 'package:BackOut/models/user.dart';
import 'package:BackOut/screens/ProfileScreen.dart';

class BuddyRequestScreen extends StatefulWidget {
  const BuddyRequestScreen({super.key});

  @override
  State<BuddyRequestScreen> createState() => _BuddyRequestScreenState();
}

class _BuddyRequestScreenState extends State<BuddyRequestScreen> {
  List<Map<String, dynamic>> users = [];
  bool isLoading = true;
  Set<String> _palIds = {};
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadUsers();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchPals();
    });
  }

  Future<List<Map<String, dynamic>>> fetchUsers() async {
    final response = await http.get(Uri.parse('${Constants.uri}/api/user/users'));
    
    if (response.statusCode == 200) {
      List<dynamic> usersJson = json.decode(response.body);
      return usersJson.map((user) => user as Map<String, dynamic>).toList();
    } else {
      throw Exception("Failed to load users");
    }
  }

  Future<User> fetchUserById(String userId) async {
    final response = await http.get(Uri.parse('${Constants.uri}/api/user/$userId'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      return User.fromMap(data);
    } else {
      throw Exception('Failed to load user');
    }
  }

  Future<void> loadUsers() async {
    try {
      users = await fetchUsers();
    } catch (e) {
      print("Error fetching users: $e");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _fetchPals() async {
    final currentUser = Provider.of<UserProvider>(context, listen: false).user;
    final url = Uri.parse('${Constants.uri}/api/users/${currentUser.id}/pals');
    
    try {
      final resp = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer ${currentUser.token}',
        },
      );
      
      if (resp.statusCode == 200) {
        final body = json.decode(resp.body) as Map<String, dynamic>;
        final pals = (body['pals'] as List<dynamic>).cast<Map<String, dynamic>>();
        setState(() {
          _palIds = pals.map((p) => p['_id'].toString()).toSet();
        });
      }
    } catch (e) {
      print("Error fetching pals: $e");
    }
  }

  Future<void> _addPal(String targetId) async {
    final currentUser = Provider.of<UserProvider>(context, listen: false).user;
    final url = Uri.parse('${Constants.uri}/api/user/addPal');
    
    try {
      final resp = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer ${currentUser.token}',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'userId': currentUser.id,
          'targetUserId': targetId,
        }),
      );
      
      if (resp.statusCode == 200) {
        setState(() {
          _palIds.add(targetId);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Buddy added successfully!'))
        );
      } else {
        print('Failed to add pal: ${resp.body}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add buddy. Try again later.'))
        );
      }
    } catch (e) {
      print('Error adding pal: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error adding buddy. Check your connection.'))
      );
    }
  }

  List<Map<String, dynamic>> get filteredUsers {
    if (_searchQuery.isEmpty) {
      return users;
    }
    
    return users.where((user) {
      return user['name'].toString().toLowerCase().contains(_searchQuery.toLowerCase()) ||
             (user['email'] != null && user['email'].toString().toLowerCase().contains(_searchQuery.toLowerCase()));
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
          title: Text("Find Buddies"),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Column(
          children: [
            // Search bar with frosted glass effect
            Padding(
              padding: EdgeInsets.all(16),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
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
                        hintText: "Search buddies...",
                        hintStyle: TextStyle(color: Colors.white60),
                        prefixIcon: Icon(Icons.search, color: Colors.white60),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 15),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            
            // Users grid
            Expanded(
              child: isLoading 
                ? Center(child: CircularProgressIndicator(color: Colors.white))
                : filteredUsers.isEmpty
                  ? Center(
                      child: Text(
                        "No buddies found",
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
                      itemCount: filteredUsers.length,
                      itemBuilder: (context, index) {
                        final user = filteredUsers[index];
                        final userId = (user['_id'] ?? user['id']).toString();
                        final isPal = _palIds.contains(userId);
                        
                        return _buildBuddyCard(user, userId, isPal, context);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildBuddyCard(Map<String, dynamic> user, String userId, bool isPal, BuildContext context) {
    final imageUrl = (user['profile_picture'] != null && user['profile_picture'].toString().isNotEmpty)
      ? user['profile_picture']
      : 'https://images.pexels.com/photos/96938/pexels-photo-96938.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=2';
    
    return GestureDetector(
      onTap: () async {
        try {
          // Show loading indicator
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),
          );
          
          final profileUser = await fetchUserById(userId);
          final currentUser = Provider.of<UserProvider>(context, listen: false).user;
          
          // Close loading indicator
          Navigator.pop(context);
          
          // Navigate to profile
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProfileScreen(
                currentUser: currentUser,
                profileUser: profileUser,
              ),
            ),
          );
        } catch (e) {
          // Close loading indicator if open
          if (Navigator.canPop(context)) {
            Navigator.pop(context);
          }
          
          print('Error loading user: $e');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to load profile. Try again later.')),
          );
        }
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.3),
              borderRadius: BorderRadius.circular(24),
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // User image with name overlay
                Expanded(
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Image
                      Image.network(
                        imageUrl,
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
                      
                      // User name
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
                            user['name'],
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
                      
                      // Bottom action section
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
                              // Email or other info if available
                              if (user['email'] != null)
                                Text(
                                  user['email'],
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              
                              SizedBox(height: 8),
                              
                              // Add Pal button
                              GestureDetector(
                                onTap: isPal ? null : () => _addPal(userId),
                                child: Container(
                                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.white24,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    isPal ? "Pal!" : "Add Pal",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
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
        ),
      ),
    );
  }
}