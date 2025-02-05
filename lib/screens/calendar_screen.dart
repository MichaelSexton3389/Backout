import 'package:flutter/material.dart';

class CalendarScreen extends StatelessWidget {
  const CalendarScreen({super.key});  // Ensure this is correctly defined

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Calendar")),
      body: Center(
        child: Text("Calendar Page - Coming Soon", style: TextStyle(fontSize: 20)),
      ),
    );
  }
}
