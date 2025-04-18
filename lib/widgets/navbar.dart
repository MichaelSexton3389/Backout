import 'package:flutter/material.dart';
import 'package:BackOut/widgets/navbar.dart';

class FloatingNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final String? profileImageUrl;

  const FloatingNavBar({
    Key? key,
    required this.currentIndex,
    required this.onTap,
    this.profileImageUrl,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 40.0),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 30),
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.35),
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 10,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(Icons.home, 0),
              _buildNavItem(Icons.calendar_today, 1),
              _buildNavItem(Icons.add_circle_outline, 2),
              _buildNavItem(Icons.chat_bubble_outline, 3),
              _buildProfileItem(4),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, int index) {
    return GestureDetector(
      onTap: () => onTap(index),
      child: Icon(
        icon,
        color: currentIndex == index
            ? const Color(0xFFFF5C57) // Hot Coral – Friendly + rebellious mix
            : const Color(0xFFB0BEC5), // Soft pastel blue-grey for inactive
        size: 30,
      ),
    );
  }

  Widget _buildProfileItem(int index) {
    return GestureDetector(
      onTap: () => onTap(index),
      child: CircleAvatar(
        radius: 16,
        backgroundColor: currentIndex == index
            ? const Color(0xFFFF4081) // Fun pink for active profile
            : const Color(0xFFCFD8DC), // Soft grey-blue for inactive
        backgroundImage: (profileImageUrl != null && profileImageUrl!.isNotEmpty)
            ? NetworkImage(profileImageUrl!)
            : null,
        child: (profileImageUrl == null || profileImageUrl!.isEmpty)
            ? Icon(Icons.person, size: 20, color: Colors.white)
            : null,
      ),
    );
  }
}
