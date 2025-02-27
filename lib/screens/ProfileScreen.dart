import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:BackOut/providers/user_providers.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Color nameColor = Colors.white; // Default name color
  Color counter_font= Colors.white;
  Color counter_bg= Colors.black.withOpacity(0.5);
  Color follow_font= Colors.black;
  Color follow_bg= Colors.white;
  String selectedFont = 'Roboto'; // Default font
  FontWeight nameWeight= FontWeight.w100;


  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).user;

    // ✅ Handle null safety for profilePicture
    String profileImage = (user.profilePicture != null && user.profilePicture!.isNotEmpty)
        ? user.profilePicture!
        : ""; // Default empty string (shows initials)

    return Scaffold(
      extendBodyBehindAppBar: true, // ✅ Allows image to extend to the top
      backgroundColor: Colors.white, // ✅ Ensures a clean fullscreen look
      body: Column(
        children: [
          // ✅ Profile Picture (Full-Screen Image)
          Expanded(
            flex: 3, // Takes 3/4 of the screen
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

                // ✅ Name (Positioned in lower 3/4 of image)
                Positioned(
                  bottom: 70,
                  left: 20,
                  child: Text(
                    user.name,
                    style: TextStyle(
                      fontSize: 70,
                      fontFamily: selectedFont,
                      fontWeight: nameWeight,
                      color: nameColor,
                    ),
                  ),
                ),

                // ✅ Pal Count & Activity Count (Bottom Right with Separator)
                Positioned(
                  bottom: 20,
                  right: 20,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                    decoration: BoxDecoration(
                      color: counter_bg, // Slight background for readability
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("128", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: counter_font)),
                            Text("Pals", style: TextStyle(fontSize: 10, color: counter_font)),
                          ],
                        ),
                        
                        SizedBox(width: 10), // Space between the text and line
                        Container(
                          width: 1, // Thin White Line Separator
                          height: 30,
                          color: counter_font,
                        ),
                        
                        SizedBox(width: 5), // Space between the line and next text
                        Column(
                          children: [
                            Text("12", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: counter_font)),
                            Text("Activities", style: TextStyle(fontSize: 10, color: counter_font)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // ✅ Transparent Back Button (Top Left)
                Positioned(
                  top: 50, // Adjust for safe area
                  left: 20,
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: CircleAvatar(
                      backgroundColor: Colors.black.withOpacity(0.3),
                      child: Icon(Icons.arrow_back, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ✅ Profile Actions
          Expanded(
            flex: 1, // Takes 1/4 of the screen
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ✅ Follow Button (Below the picture, right aligned)
                  Padding(
                    padding: const EdgeInsets.only(top:10.0),
                    child: Align(
                       alignment: Alignment.centerRight,
                       child: ElevatedButton(
                       style: ButtonStyle(
                       backgroundColor: MaterialStateProperty.all(Colors.black),
                       ),
                       onPressed: () {},
                       child: Text(
                         "Follow",
                         style: TextStyle(fontFamily: selectedFont, color: Colors.white),
                        
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 15),

                  // ✅ Bio Section
                  Text(
                    user.safeBio,
                    textAlign: TextAlign.left,
                    style: TextStyle(fontSize: 16, fontFamily: selectedFont),
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