import 'package:BackOut/models/user.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:BackOut/services/user_service.dart';
import 'package:flutter/services.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({Key? key}) : super(key: key);

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final TextEditingController descriptionController = TextEditingController();
  final List<String> activities = [
    'swimming.svg', 'biking.svg', 'lifting.svg', 'running.svg',
    'skiing.svg', 'snowboarding.svg', 'hiking.svg', 'hockey.svg',
    'soccer.svg', 'kayaking.svg', 'basketball.svg', 'three_circle_fill.svg',
  ];
  final Set<int> selected = {};

  void toggleSelection(int index) {
    setState(() {
      if (selected.contains(index)) selected.remove(index);
      else selected.add(index);
    });
  }

@override
void initState() {
  super.initState();
  for (final file in activities) {
    rootBundle
      .loadString('assets/$file')
      .then((s) => print('$file loaded (${s.length} chars)'))
      .catchError((e) => print('Failed to load $file: $e'));
  }
}

   @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Remove the solid background; use a gradient instead
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFc31432),
              Color(0xFF240b36),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 16),
                const Text(
                  'Registration',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: CircleAvatar(
                    radius: 50,
                    backgroundImage: AssetImage('assets/profile_placeholder.png'),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'About You',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                const SizedBox(height: 12),
                TextField(
                  controller: descriptionController,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: 'Short description about you',
                    filled: true,
                    fillColor: Colors.grey[200],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'What interests you?',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: GridView.count(
                    crossAxisCount: 4,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    children: List.generate(activities.length, (i) {
                      final isSelected = selected.contains(i);
                      return GestureDetector(
                        onTap: () => toggleSelection(i),
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isSelected ? Colors.lightBlue : const Color.fromARGB(255, 255, 255, 255),
                          ),
                          padding: const EdgeInsets.all(8),
                          child: SvgPicture.asset(
                            'assets/${activities[i]}',
                            height: 150,
                            width: 150,
                            color: isSelected ? Colors.white : Colors.black,
                          ),
                        ),
                      );
                    }),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.search),
                      label: const Text('More Activities!'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.lightBlue,
                        shape: const StadiumBorder(),
                        padding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 20),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.lightBlue,
                        shape: const StadiumBorder(),
                        padding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 20),
                      ),
                      child: const Text('Ready to get Backout?'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
