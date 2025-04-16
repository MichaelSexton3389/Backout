import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'upcoming.dart';

class PalsScreen extends StatelessWidget {
  const PalsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF6A1B1A),
            Color(0xFF000000),
            Color(0xFF0D3B4C),
          ],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    PageRouteBuilder(
                      pageBuilder: (_, __, ___) => const HomeScreen(),
                      transitionsBuilder: (_, animation, __, child) {
                        return SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(-1, 0),
                            end: Offset.zero,
                          ).animate(animation),
                          child: child,
                        );
                      },
                    ),
                  );
                },
                child: const Text(
                  "Memories",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 30,
                    color: Color.fromARGB(255, 255, 255, 255),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    PageRouteBuilder(
                      pageBuilder: (_, __, ___) => const HomeScreen(),
                      transitionsBuilder: (_, animation, __, child) {
                        return SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0, 1),
                            end: Offset.zero,
                          ).animate(animation),
                          child: child,
                        );
                      },
                    ),
                  );
                },
                child: const Text(
                  "BackOut",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: Colors.grey,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    PageRouteBuilder(
                      pageBuilder: (_, __, ___) => UpcomingScreen(),
                      transitionsBuilder: (_, animation, __, child) {
                        return SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(1, 0),
                            end: Offset.zero,
                          ).animate(animation),
                          child: child,
                        );
                      },
                    ),
                  );
                },
                child: const Text(
                  "Discover",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: Colors.grey,
                  ),
                ),
              ),
            ],
          ),
        ),
        body: Center(
          child: const Text('Pals Screen'),
        ),
      ),
    );
  }
}
