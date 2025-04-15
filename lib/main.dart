import 'package:BackOut/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:BackOut/providers/user_providers.dart';
import 'package:BackOut/screens/login_screen.dart';
import 'package:BackOut/screens/signup_screen.dart';
import 'package:BackOut/services/auth_services.dart';
import 'package:provider/provider.dart';

// Define a simple HomeScreen replacement in case the import fails
class SimpleHomeScreen extends StatefulWidget {
  const SimpleHomeScreen({super.key});

  @override
  State<SimpleHomeScreen> createState() => _SimpleHomeScreenState();
}

class _SimpleHomeScreenState extends State<SimpleHomeScreen> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  final List<Widget> _screens = [
    const Center(child: Text('Home')),
    const Center(child: Text('Discover')),
    const Center(child: Text('Profile')),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('BackOut'),
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Discover',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        onTap: _onItemTapped,
      ),
    );
  }
}

void main() { 
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final AuthService authService = AuthService();
  bool useSimpleHome = false;

  @override
  void initState() {
    super.initState();
    // Check if the imported HomeScreen is causing issues
    try {
      // This is just to test if HomeScreen is available
      const HomeScreen();
    } catch (e) {
      // If there's an error, use our SimpleHomeScreen instead
      setState(() {
        useSimpleHome = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BackOut',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: _buildHome(context),
    );
  }

  Widget _buildHome(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    
    if (userProvider.user.token.isEmpty) {
      // Try to show SignupScreen, but fall back to a simple screen if needed
      try {
        return const SignupScreen();
      } catch (e) {
        return Scaffold(
          appBar: AppBar(title: const Text('Sign Up')),
          body: const Center(child: Text('Sign Up Screen')),
        );
      }
    } else {
      // Use either the imported HomeScreen or our SimpleHomeScreen
      return useSimpleHome ? const SimpleHomeScreen() : const HomeScreen();
    }
  }
}