import 'package:flutter/material.dart';
import 'package:BackOut/screens/home_screen.dart';
import 'package:BackOut/screens/inbox_screen.dart';
import 'package:BackOut/screens/ProfileScreen.dart';
import 'package:BackOut/providers/user_providers.dart';
import 'package:BackOut/services/auth_services.dart';
import 'package:provider/provider.dart';
import 'package:BackOut/screens/calendar_screen.dart';
import 'package:BackOut/screens/buddy_req_screen.dart';

class NavBarUtils {
  // Creates an AppBar that can be reused across screens
  static AppBar buildAppBar(BuildContext context, {String title = "BackOut", bool showBackButton = false}) {
    final user = Provider.of<UserProvider>(context).user;
    
    return AppBar(
      title: Text(title),
      leading: showBackButton 
          ? IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.pop(context);
              },
            )
          : null,
      actions: [
        IconButton(
          icon: const Icon(Icons.calendar_today, size: 26),
          tooltip: "Calendar",
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CalendarScreen(),
              ),
            );
          },
        ),
        IconButton(
          icon: const Icon(Icons.chat_bubble_outline, size: 30),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => InboxScreen(currentUser: user.name),
              ),
            );
          },
        ),
        IconButton(
          icon: CircleAvatar(
            radius: 15,
            backgroundImage: user.profilePicture != null &&
                    user.profilePicture!.isNotEmpty
                ? NetworkImage(user.profilePicture!)
                : null,
            backgroundColor: Colors.grey.shade300,
            child: user.profilePicture == null || user.profilePicture!.isEmpty
                ? const Icon(Icons.account_circle,
                    size: 30, color: Colors.white)
                : null,
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProfileScreen(
                  currentUser: user,
                  profileUser: user,
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  // Creates a drawer that can be reused across screens
  static Drawer buildDrawer(BuildContext context) {
    final user = Provider.of<UserProvider>(context).user;
    final authService = AuthService();
    
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(user.name),
            accountEmail: Text(user.email),
            currentAccountPicture: CircleAvatar(
              backgroundImage: user.profilePicture != null &&
                      user.profilePicture!.isNotEmpty
                  ? NetworkImage(user.profilePicture!)
                  : null,
              backgroundColor: Colors.grey.shade300,
              child: user.profilePicture == null || user.profilePicture!.isEmpty
                  ? const Icon(Icons.account_circle,
                      size: 50, color: Colors.white)
                  : null,
            ),
            decoration: BoxDecoration(
              color: Colors.black,
            ),
          ),
          ListTile(
            leading: Icon(Icons.home),
            title: Text("Home"),
            onTap: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (context) => const HomeScreen(),
                ),
                (route) => false,
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.calendar_today),
            title: Text("Calendar"),
            onTap: () {
              Navigator.pop(context); // Close the drawer first
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CalendarScreen(),
                ),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.people),
            title: Text("Find Buddies"),
            onTap: () {
              Navigator.pop(context); // Close the drawer first
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const BuddyRequestScreen(),
                ),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.message),
            title: Text("Messages"),
            onTap: () {
              Navigator.pop(context); // Close the drawer first
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => InboxScreen(currentUser: user.name),
                ),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.person),
            title: Text("Profile"),
            onTap: () {
              Navigator.pop(context); // Close the drawer first
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProfileScreen(
                    currentUser: user,
                    profileUser: user,
                  ),
                ),
              );
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.logout),
            title: Text("Sign Out"),
            onTap: () async {
              authService.signOut(context: context);
            },
          ),
        ],
      ),
    );
  }

  // Creates a bottom navigation bar
  static BottomNavigationBar buildBottomNavBar(BuildContext context, int currentIndex) {
    final user = Provider.of<UserProvider>(context).user;
    
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: (index) {
        if (index == currentIndex) return;
        
        switch (index) {
          case 0:
            Navigator.pushAndRemoveUntil(
              context, 
              MaterialPageRoute(builder: (context) => const HomeScreen()),
              (route) => false,
            );
            break;
          case 1:
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CalendarScreen(),
              ),
            );
            break;
          case 2:
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const BuddyRequestScreen(),
              ),
            );
            break;
          case 3:
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => InboxScreen(currentUser: user.name),
              ),
            );
            break;
          case 4:
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProfileScreen(
                  currentUser: user,
                  profileUser: user,
                ),
              ),
            );
            break;
        }
      },
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.calendar_today),
          label: 'Calendar',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.people),
          label: 'Buddies',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.chat_bubble_outline),
          label: 'Messages',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.account_circle),
          label: 'Profile',
        ),
      ],
    );
  }
}

