import 'package:flutter/material.dart';
import 'package:BackOut/providers/user_providers.dart';
import 'package:BackOut/services/auth_services.dart';
import 'package:provider/provider.dart';
import 'calendar_screen.dart';  //Import CalendarScreen

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;  //Track selected page index

  //Define screens for navigation
  final List<Widget> _screens = [
    HomeContent(),  
    CalendarScreen(),  //Add Calendar Page
  ];

  void _onItemTapped(int index) {  //Update selected index
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex], //Switch between pages
      bottomNavigationBar: BottomNavigationBar( //Bottom Navigation Bar
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),  //Calendar Icon
            label: "Calendar",
          ),
        ],
      ),
    );
  }
}

//UNCHANGED:Home Content
class HomeContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).user;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(user.id),
        Text(user.email),
        Text(user.name),
      ],
    );
  }
}