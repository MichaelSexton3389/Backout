import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:BackOut/providers/user_providers.dart';
import 'package:BackOut/models/user.dart';
import 'package:BackOut/widgets/post_widget.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ProfileScreen extends StatefulWidget {
  final User currentUser; // The user using the app
  final User profileUser; // The ID of the profile being viewed

  const ProfileScreen({
    required this.currentUser,
    required this.profileUser,
    Key? key,
  }) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
  
}

class _ProfileScreenState extends State<ProfileScreen> {
  
bool isEditing = false;
// Aspect ratio options
  final Map<String, double> aspectRatios = {
    "Square (1:1)": 1.0,
    "4:3": 4 / 3,
    "16:9": 16 / 9,
    "3:4": 3 / 4,
  };
  Color bg_color= Colors.black;
  Color nameColor = Colors.white; // Default name color
  Color counter_font = Colors.white;
  Color bioColor = Colors.white;
  // ignore: deprecated_member_use
  Color counter_bg = Colors.black.withOpacity(0.5);
  Color follow_font = Colors.black;
  Color follow_bg = Colors.white;
  String selectedFont = 'Roboto'; // Default font
  // FontWeight nameWeight= FontWeight.w100;

  List<Map<String, dynamic>> userPosts = []; // Define userPosts

  int palCount = 0;

  void fetchPalCount() async {
    final userId = widget.profileUser.id;
    final response = await http
        .get(Uri.parse("https://your-api.com/api/user/$userId/pal-count"));

    if (response.statusCode == 200) {
      
      setState(() {
        palCount = json.decode(response.body)['palCount'];
      });
    }
  }

  void changeAspectRatio(int index, Map<String, dynamic> selectedOption) {
  setState(() {
    userPosts[index]['aspectRatio'] = selectedOption['aspectRatio'];
    userPosts[index]['widthSpan'] = selectedOption['widthSpan'];
    userPosts[index]['heightSpan'] = selectedOption['heightSpan'];
  });
}

  void addPal() async {
    final userId = widget.currentUser.id;
    final targetUserId = widget.profileUser.id; // Replace with actual target user ID

    final response = await http.post(
      Uri.parse("https://your-api.com/api/follow"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"userId": userId, "targetUserId": targetUserId}),
    );

    if (response.statusCode == 200) {
      fetchPalCount(); // Refresh pal count
    }
  }

  void fetchUserPosts() async {
  final userId = Provider.of<UserProvider>(context, listen: false).user.id;
  final response = await http.get(Uri.parse("https://your-api.com/api/user/$userId/posts"));

  if (response.statusCode == 200) {
    setState(() {
      userPosts = List<Map<String, dynamic>>.from(json.decode(response.body)).map((post) {
        return {
          ...post,
          "aspectRatio": (post["aspectRatio"] is double) 
              ? post["aspectRatio"] 
              : (post["aspectRatio"] is int) 
                ? (post["aspectRatio"] as int).toDouble() 
                : 1.0, // ✅ Ensures aspectRatio is always a double
        };
      }).toList();
    });
  } else {
    print("Error Fetching Posts: ${response.statusCode}");

    // Fallback dummy posts

setState(() {
  userPosts = [
    {
      "aspectRatio": 2.5, // Super Wide
      "widthSpan": 3,
      "heightSpan": 2,
      "postImage": "https://images.pexels.com/photos/4719837/pexels-photo-4719837.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=2",
      "caption": "Best coach one could ask for!",
      "musicUrl": null
    },
    {
      "aspectRatio": 1.0, // Square
      "widthSpan": 1,
      "heightSpan": 1,
      "postImage": "https://images.pexels.com/photos/30911610/pexels-photo-30911610/free-photo-of-sunny-lakeside-promenade-with-lush-trees.jpeg",
      "caption": "Morning runs. I tell you man.",
      "musicUrl": null
    },
    {
      "aspectRatio": 0.6, // Tall
      "widthSpan": 1,
      "heightSpan": 2,
      "postImage": "https://images.pexels.com/photos/1366919/pexels-photo-1366919.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=2",
      "caption": "Tall vibes.",
      "musicUrl": null
    },
    {
      "aspectRatio": 1.8, // Wide
      "widthSpan": 2,
      "heightSpan": 1,
      "postImage": "https://images.pexels.com/photos/1274260/pexels-photo-1274260.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=2",
      "caption": "Sunset scenes.",
      "musicUrl": null
    },
    {
      "aspectRatio": 0.75, // Tallish
      "widthSpan": 1,
      "heightSpan": 2,
      "postImage": "https://images.pexels.com/photos/30975669/pexels-photo-30975669/free-photo-of-horseback-riders-in-rural-ulupamir-turkiye.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=2",
      "caption": "Towering trees.",
      "musicUrl": null
    },
    {
      "aspectRatio": 1.4, // Square
      "widthSpan": 2,
      "heightSpan": 2,
      "postImage": "https://images.pexels.com/photos/1194235/pexels-photo-1194235.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=2",
      "caption": "Mountain goals.",
      "musicUrl": null
    },
    {
      "aspectRatio": 1.4, // Semi-Wide
      "widthSpan": 2,
      "heightSpan": 2,
      "postImage": "https://images.pexels.com/photos/29267513/pexels-photo-29267513/free-photo-of-young-tourist-taking-photo-on-busy-city-street.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=2",
      "caption": "City lights.",
      "musicUrl": null
    },
    // {
    //   "aspectRatio": 0.5, // Extra Tall
    //   "widthSpan": 1,
    //   "heightSpan": 3,
    //   "postImage": "https://images.pexels.com/photos/159711/lighthouse-sea-horizon-ocean-159711.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=2",
    //   "caption": "Lighthouse lookout.",
    //   "musicUrl": null
    // },
  ];
});
  }
}

  @override
  void initState() {
    super.initState();
    fetchPalCount();
    fetchUserPosts();
  }

  @override
  Widget build(BuildContext context) {
    User loggedInUser= widget.currentUser;
    User profileUser= widget.profileUser;

    final user = profileUser;

    
    // ✅ Handle null safety for profilePicture
    String profileImage =
        (user.profilePicture != null && user.profilePicture!.isNotEmpty)
            ? user.profilePicture!
            : ""; // Default empty string (shows initials)

    return Scaffold(
      extendBodyBehindAppBar: true, // ✅ Allows image to extend to the top
      backgroundColor: bg_color, // ✅ Ensures a clean fullscreen look
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 40),
          child: Column(
            children: [
              // ✅ Profile Picture (Full-Screen Image)
              Container(
                height: MediaQuery.of(context).size.height * 0.75,
                width: double.infinity,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Profile Image
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        image: profileImage.isNotEmpty
                            ? DecorationImage(
                                image: NetworkImage(profileImage),
                                fit: BoxFit.cover,
                              )
                            : null,
                        color: Colors.grey[800], // Fallback color
                      ),
                      child: profileImage.isEmpty
                          ? Center(
                              child: Text(
                                user.name.substring(0, 2).toUpperCase(),
                                style: TextStyle(
                                  fontSize: 50,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            )
                          : null,
                    ),
                    // ✅ Back Button (Transparent Circle with Arrow)
                    Positioned(
                      top: 70, // Adjust for safe area padding
                      left: 30, // Position on the left
                      child: GestureDetector(
                        onTap: () {
                          Navigator.pop(
                              context); // ✅ Takes user back to Home Screen
                        },
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.black.withOpacity(
                                0.4), // ✅ Transparent black background
                          ),
                          child: Center(
                            child: Icon(Icons.arrow_back,
                                color: Colors.white), // ✅ White arrow
                          ),
                        ),
                      ),
                    ),
                    // ✅ Name (Positioned in lower 3/4 of image)
                    // ✅ Name & Pal Count Positioned in lower-left of image
                    Positioned(
                      bottom: 20,
                      left: 20,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Name
                          Text(
                            user.name,
                            style: TextStyle(
                              fontSize: 70,
                              fontFamily: selectedFont,
                              // fontWeight: nameWeight,
                              color: nameColor,
                            ),
                          ),

                          const SizedBox(height: 10), // Spacing

                          // ✅ Pal Count & Activity Count (Now below the name)
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 20, vertical: 4),
                            decoration: BoxDecoration(
                              color:
                                  counter_bg, // Slight background for readability
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("$palCount",
                                        style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            color: counter_font)),
                                    Text("Pals",
                                        style: TextStyle(
                                            fontSize: 10, color: counter_font)),
                                  ],
                                ),

                                SizedBox(
                                    width:
                                        10), // Space between the text and line
                                Container(
                                  width: 1, // Thin White Line Separator
                                  height: 30,
                                  color: counter_font,
                                ),

                                SizedBox(
                                    width:
                                        5), // Space between the line and next text
                                Column(
                                  children: [
                                    Text("12",
                                        style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            color: counter_font)),
                                    Text("Activities",
                                        style: TextStyle(
                                            fontSize: 10, color: counter_font)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // ✅ Pals Button (Now in the bottom-right)
                    Positioned(
                      bottom: 20,
                      right: 20,
                      child: ElevatedButton(
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all(
                              Colors.blue.withOpacity(0.8)),
                        ),
                        onPressed: (user.id == loggedInUser.id) ? (){
                          setState(() {
                            isEditing = !isEditing;
                          });
                        } : addPal,
                        child: Text(
                          user.id == loggedInUser.id ? (isEditing ? "Save" : "Edit") : "Add Pal",
                          style: TextStyle(
                              fontFamily: selectedFont, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ✅ Profile Actions
              // Takes 1/4 of the screen
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 15),

                    // ✅ Bio Section
                    Text(
                      user.safeBio,
                      textAlign: TextAlign.left,
                      style: TextStyle(fontSize: 16, fontFamily: selectedFont, color: bioColor),
                    ),
                    userPosts.isEmpty
  ? Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.camera_alt, size: 50, color: Colors.grey),
          SizedBox(height: 10),
          Text("No Posts Yet", style: TextStyle(fontSize: 18, color: Colors.grey)),
        ],
      ),
    )
: StaggeredGrid.count(
    crossAxisCount: 3, // 3 columns
    mainAxisSpacing: 8,
    crossAxisSpacing: 8,
    children: userPosts.asMap().entries.map((entry) {
      final index = entry.key;
      final post = entry.value;
      return StaggeredGridTile.count(
        crossAxisCellCount: post['widthSpan'],
        mainAxisCellCount: post['heightSpan'],
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                post["postImage"],
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
              ),
            ),
            if (isEditing)
  Positioned(
    top: 8,
    right: 8,
    child: PopupMenuButton<Map<String, dynamic>>(
      icon: Icon(Icons.crop, color: Colors.white, size: 20),
      color: Colors.black.withOpacity(0.9),
      onSelected: (selectedOption) {
        changeAspectRatio(index, selectedOption);
      },
      itemBuilder: (context) => [
        {"label": "Square (1:1)", "aspectRatio": 1.0, "widthSpan": 1, "heightSpan": 1},
        {"label": "Wide (16:9)", "aspectRatio": 1.8, "widthSpan": 2, "heightSpan": 1},
        {"label": "Tall (3:4)", "aspectRatio": 3 / 4, "widthSpan": 1, "heightSpan": 2},
        {"label": "Super Wide (3x2)", "aspectRatio": 2.5, "widthSpan": 3, "heightSpan": 2},
      ].map((option) {
        return PopupMenuItem<Map<String, dynamic>>(
          value: option,
          child: Text(
            option["label"] as String,
            style: TextStyle(color: Colors.white),
          ),
        );
      }).toList(),
    ),
  ),
          ],
        ),
      );
    }).toList(),
  ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
