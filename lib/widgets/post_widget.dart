import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class PostWidget extends StatelessWidget {
  final String username;
  final String userProfileImage;
  final String postImage;
  final String caption;
  final double aspectRatio;
  final String? musicUrl; // Optional music feature

  const PostWidget({
    required this.username,
    required this.userProfileImage,
    required this.postImage,
    required this.caption,
    required this.aspectRatio,
    this.musicUrl,
    Key? key,
  }) : super(key: key);

  // ✅ Function that returns a modern post widget
  Widget buildPost() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(15), // ✅ Rounded corners
      child: Stack(
        children: [
          // ✅ Background Image
          AspectRatio(
            aspectRatio: aspectRatio, // ✅ Dynamic aspect ratio
            child: Image.network(
              postImage,
              fit: BoxFit.cover,
              width: double.infinity,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Center(child: CircularProgressIndicator());
              },
              errorBuilder: (context, error, stackTrace) {
                return Center(
                    child: Icon(Icons.image_not_supported,
                        size: 50, color: Colors.grey));
              },
            ),
          ),

          //   // ✅ Gradient Overlay for better readability
          //   Container(
          //     decoration: BoxDecoration(
          //       gradient: LinearGradient(
          //         begin: Alignment.bottomCenter,
          //         end: Alignment.topCenter,
          //         colors: [
          //           Colors.black.withOpacity(0.6), // Dark overlay at the bottom
          //           Colors.transparent, // Fade out effect
          //         ],
          //       ),
          //     ),
          //   ),

          // ✅ Post Content Overlay
          Positioned(
            left: 15,
            bottom: 5,
            right: 15,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 5),

                // ✅ Caption
                // Container(
                //   padding: EdgeInsets.symmetric(
                //       horizontal: 8, vertical: 4), // Adds some spacing
                //   decoration: BoxDecoration(
                //     color: Colors.black
                //         .withOpacity(0.4), // Semi-transparent black background
                //     borderRadius: BorderRadius.circular(
                //         30), // Rounded corners for a soft look
                //   ),
                //   child: Text(
                //     caption,
                //     maxLines: 2,
                //     overflow: TextOverflow.ellipsis,
                //     style: TextStyle(
                //       color: Colors.white,
                //       fontSize: 14,
                //       fontWeight: FontWeight.w500,
                //     ),
                //   ),
                // ),
                // ✅ User Info Row
                // Row(
                //   children: [
                //     Padding(
                //         padding: EdgeInsets.only(top: 10),

                //         child: Row(
                //           children: [
                //             CircleAvatar(
                //               backgroundImage: userProfileImage.isNotEmpty
                //                   ? NetworkImage(userProfileImage)
                //                   : AssetImage("assets/default_profile.png")
                //                       as ImageProvider,
                //               radius: 18,
                //             ),
                //             SizedBox(width: 10),
                //             Text(
                //               username,
                //               style: TextStyle(
                //                 color: Colors.white,
                //                 fontWeight: FontWeight.bold,
                //                 fontSize: 16,
                //               ),
                //             ),
                //           ],
                //         )),
                //   ],
                // ),
                // ✅ Music Link (if available)
                // if (musicUrl != null)
                //   Padding(
                //     padding: EdgeInsets.only(top: 5),
                //     child: GestureDetector(
                //       onTap: () async {
                //         final Uri url = Uri.parse(musicUrl!);
                //         if (await canLaunchUrl(url)) {
                //           await launchUrl(url);
                //         } else {
                //           throw 'Could not launch $url';
                //         }
                //       },
                //       child: Text(
                //         "🎵 Listen to Music",
                //         style: TextStyle(
                //           color: Colors.blue,
                //           fontSize: 12,
                //           decoration: TextDecoration.underline,
                //         ),
                //       ),
                //     ),
                //   ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return buildPost();
  }
}
