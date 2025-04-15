import 'package:BackOut/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:BackOut/providers/user_providers.dart';
import 'package:BackOut/screens/login_screen.dart';
import 'package:BackOut/screens/signup_screen.dart';
import 'package:BackOut/services/auth_services.dart';
import 'package:provider/provider.dart';
import 'package:BackOut/services/notification_service.dart';
import 'package:BackOut/services/app_lifecycle_manager.dart'; // Add this import

// Add a global navigator key for navigation from notifications
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.initialize();
  await NotificationService.createNotificationChannel();
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
      ],
      child: const AppLifecycleManager(
        child: MyApp(),
      ),
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

  @override
  void initState() {
    super.initState();
    //authService.getUserData(context);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'Flutter Node Auth',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Provider.of<UserProvider>(context).user.token.isEmpty 
          ? const SignupScreen() 
          : const HomeScreen(),
    );
  }
}