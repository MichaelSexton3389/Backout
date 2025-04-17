import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:BackOut/providers/user_providers.dart';
import 'package:BackOut/widgets/activity_card.dart';
import 'package:BackOut/widgets/navbar.dart';
import 'package:BackOut/screens/home_screen.dart';
import 'package:BackOut/screens/inbox_screen.dart';
import 'package:BackOut/screens/ProfileScreen.dart';
import 'package:BackOut/widgets/modal_background.dart';
import 'package:BackOut/widgets/create_activty_form.dart';
import 'package:BackOut/utils/constants.dart';

class CalendarScreen extends StatefulWidget {
  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  final Map<DateTime, List<Map<String, String>>> _events = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadEvents());
  }

  List<Map<String, String>> _getEventsForDay(DateTime day) {
    return _events[DateTime(day.year, day.month, day.day)] ?? [];
  }

  String _formatDate(String? dateStr) {
    try {
      final parsedDate = DateTime.parse(dateStr ?? '');
      return DateFormat.yMMMd().add_jm().format(parsedDate);
    } catch (e) {
      return 'Invalid date';
    }
  }

  Future<void> _loadEvents() async {
    final user = Provider.of<UserProvider>(context, listen: false).user;
    final url = Uri.parse('${Constants.uri}/api/user/${user.id}/upcoming-activity-details');

    try {
      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer ${user.token}'},
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        final fetchedActivities = data['activities'];

        setState(() {
          _events.clear();
          for (var activity in fetchedActivities) {
            final DateTime date = DateTime.parse(activity['date']);
            final key = DateTime(date.year, date.month, date.day);

            if (!_events.containsKey(key)) {
              _events[key] = [];
            }

            _events[key]!.add({
              'id': activity['_id'] ?? '',
              'name': activity['title'] ?? '',
              'start': activity['date'] ?? '',
              'end': activity['end'] ?? '',
              'location': activity['location'] ?? '',
              'description': activity['description'] ?? '',
              'bg_img': activity['bg_img'] ?? '',
            });
          }
        });
      } else {
        print("Failed to load activities: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching activities: $e");
    }
  }

  void _deleteEvent(DateTime day, Map<String, String> event) {
    final key = DateTime(day.year, day.month, day.day);
    setState(() {
      _events[key]?.remove(event);
      if (_events[key]?.isEmpty ?? true) {
        _events.remove(key);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).user;

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF6A1B1A), // Deep red
            Color(0xFF0D3B4C), // Dark blue
          ],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            Column(
              children: [
                const SizedBox(height: 50),
                TableCalendar(
                  firstDay: DateTime.utc(2020, 1, 1),
                  lastDay: DateTime.utc(2030, 12, 31),
                  focusedDay: _focusedDay,
                  calendarFormat: _calendarFormat,
                  availableCalendarFormats: const {
                    CalendarFormat.month: 'Month',
                  },
                  selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                  onDaySelected: (selectedDay, focusedDay) {
                    setState(() {
                      _selectedDay = selectedDay;
                      _focusedDay = focusedDay;
                    });
                  },
                  eventLoader: _getEventsForDay,
                  calendarStyle: const CalendarStyle(
                    defaultTextStyle: TextStyle(color: Colors.white),
                    weekendTextStyle: TextStyle(color: Colors.white),
                    outsideTextStyle: TextStyle(color: Colors.white38),
                    todayTextStyle: TextStyle(color: Colors.black),
                    todayDecoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    selectedTextStyle: TextStyle(color: Colors.black),
                    selectedDecoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    markerDecoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
                  daysOfWeekStyle: const DaysOfWeekStyle(
                    weekdayStyle: TextStyle(color: Colors.white),
                    weekendStyle: TextStyle(color: Colors.redAccent),
                  ),
                  headerStyle: const HeaderStyle(
                    titleTextStyle: TextStyle(color: Colors.white),
                    formatButtonTextStyle: TextStyle(color: Colors.black),
                    formatButtonDecoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                    ),
                    leftChevronIcon: Icon(Icons.chevron_left, color: Colors.white),
                    rightChevronIcon: Icon(Icons.chevron_right, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: _selectedDay != null &&
                              _events.containsKey(DateTime(_selectedDay!.year, _selectedDay!.month, _selectedDay!.day))
                          ? _events[DateTime(_selectedDay!.year, _selectedDay!.month, _selectedDay!.day)]!
                              .map((event) => Stack(
                                    children: [
                                      ActivityCard(
                                        title: event['name'] ?? '',
                                        date: _formatDate(event['start']),
                                        time: '',
                                        location: event['location'] ?? '',
                                        imageUrl: event['bg_img'] ?? '',
                                        description: event['description'] ?? '',
                                      ),
                                      Positioned(
                                        top: 8,
                                        right: 12,
                                        child: IconButton(
                                          icon: const Icon(Icons.delete, color: Colors.redAccent),
                                          onPressed: () => _deleteEvent(_selectedDay!, event),
                                        ),
                                      ),
                                    ],
                                  ))
                              .toList()
                          : const [
                              Text(
                                "No events selected",
                                style: TextStyle(color: Colors.white),
                              )
                            ],
                    ),
                  ),
                ),
              ],
            ),

            /// FloatingNavBar
            FloatingNavBar(
              currentIndex: 1, // Calendar tab
              profileImageUrl: user.profilePicture,
              onTap: (index) {
                if (index == 0) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const HomeScreen()),
                  );
                } else if (index == 1) {
                  // Already here
                } else if (index == 2) {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    barrierColor: Colors.black12,
                    builder: (context) {
                      return FractionallySizedBox(
                        heightFactor: 0.85,
                        child: ModalBackground(
                          child: Material(
                            type: MaterialType.transparency,
                            child: CreateActivityFormUpdated(),
                          ),
                        ),
                      );
                    },
                  );
                } else if (index == 3) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => InboxScreen(currentUser: user.name),
                    ),
                  );
                } else if (index == 4) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProfileScreen(
                        currentUser: user,
                        profileUser: user,
                      ),
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
