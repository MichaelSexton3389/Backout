import 'package:flutter/material.dart';

class BuddyCard extends StatelessWidget {
  final String name;
  final String imageUrl;
  final VoidCallback onInvite;

  const BuddyCard({
    Key? key,
    required this.name,
    required this.imageUrl,
    required this.onInvite,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
      height: 220,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        // If you want a shadow:
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            // Profile image
            Image.network(
              imageUrl,
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
            ),

            // A slight gradient overlay at the bottom
            Positioned(
  bottom: 0,
  left: 0,
  right: 0,
  child: Container(
    height: 60,
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [
          Colors.transparent,
          Colors.black.withOpacity(0.3), // Lighten from 0.7 to 0.3
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ),
    ),
  ),
),

            // Pal's name at the top
            Positioned(
              top: 12,
              left: 12,
              child: Text(
                name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      blurRadius: 4,
                      color: Colors.black45,
                      offset: Offset(1, 1),
                    ),
                  ],
                ),
              ),
            ),

            // Invite button at the bottom-right
            Positioned(
              bottom: 12,
              right: 12,
              child: ElevatedButton(
  onPressed: onInvite,
  style: ElevatedButton.styleFrom(
    backgroundColor: const Color.fromARGB(255, 29, 21, 50), // brand color
    foregroundColor: Colors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(25),
    ),
  ),
  child: const Text('Invite'),
),
            ),
          ],
        ),
      ),
    );
  }
}