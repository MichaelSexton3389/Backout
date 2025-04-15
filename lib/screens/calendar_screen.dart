import 'dart:convert'; // To convert your Map to a string and vice versa
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CalendarScreen extends StatefulWidget {
  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  // In-memory storage for events (also used for SharedPreferences data
  final Map<DateTime, List<Map<String, String>>> _events = {};

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  // This method is responsible for loading events for a specific day.
  List<Map<String, String>> _getEventsForDay(DateTime day) {
    return _events[DateTime(day.year, day.month, day.day)] ?? [];
  }

  // Load events from SharedPreferences
  Future<void> _loadEvents() async {
    final prefs = await SharedPreferences.getInstance();
    final String? eventsData = prefs.getString('events');
    if (eventsData != null) {
      final Map<String, dynamic> decodedData = jsonDecode(eventsData);
      setState(() {
        _events.clear();
        decodedData.forEach((key, value) {
          final date = DateTime.parse(key);
          _events[date] = List<Map<String, String>>.from(value.map((e) => Map<String, String>.from(e)));
        });
      });
    }
  }

  // Save events to shared preferences
  void _saveEvents() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String eventsJson = jsonEncode(_events);  // Convert events map to JSON
    await prefs.setString('events', eventsJson);  // Save JSON string
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Your Events")),
      body: Column(
        children: [
          // TableCalendar widget for displaying the calendar
          TableCalendar(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            calendarFormat: _calendarFormat,
            selectedDayPredicate: (day) {
              return isSameDay(_selectedDay, day);
            },
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            eventLoader: _getEventsForDay,
          ),
          
          const SizedBox(height: 16),
          
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Check if there are events for the selected day
                if (_selectedDay != null &&
                    _events.containsKey(DateTime(
                        _selectedDay!.year, _selectedDay!.month, _selectedDay!.day)))
                  Column(
                    children: [
                      Text(
                        "Events on ${_selectedDay!.year}-${_selectedDay!.month}-${_selectedDay!.day}",
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      // List of events for the selected day
                      ..._events[DateTime(
                              _selectedDay!.year, _selectedDay!.month, _selectedDay!.day)]!
                          .map((event) => Padding(
                                padding: const EdgeInsets.symmetric(vertical: 6),
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        const Icon(Icons.event, size: 24),
                                        const SizedBox(width: 8),
                                        Text(
                                          event["name"] ?? "Unnamed Event",
                                          style: const TextStyle(fontSize: 16),
                                        ),
                                      ],
                                    ),
                                    Text("Start: ${event["start"]} - End: ${event["end"]}"),
                                    Text("Location: ${event["location"]}"),
                                    Text("Description: ${event["description"]}"),
                                    const SizedBox(height: 8),
                                    IconButton(
                                      icon: const Icon(Icons.delete, color: Colors.red),
                                      onPressed: () => _deleteEvent(event),
                                    ),
                                    const Divider(),
                                  ],
                                ),
                              )),
                    ],
                  )
                else
                  const Text(
                    "No events selected",
                    style: TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _selectedDay != null ? _showAddEventDialog : null,
        child: const Icon(Icons.add),
      ),
    );
  }

  void _addEvent(String name, String location, String start, String end, String description) async {
    setState(() {
      DateTime selectedDate = DateTime(_selectedDay!.year, _selectedDay!.month, _selectedDay!.day);
      if (_events[selectedDate] == null) {
        _events[selectedDate] = [];
      }
      _events[selectedDate]!.add({
        "name": name,
        "start": start,
        "end": end,
        "location": location,
        "description": description,
      });
    });

    // Save to shared preferences
    _saveEvents();
  }

  void _deleteEvent(Map<String, String> event) async {
    setState(() {
      DateTime selectedDate = DateTime(_selectedDay!.year, _selectedDay!.month, _selectedDay!.day);
      _events[selectedDate]?.remove(event);
      if (_events[selectedDate]?.isEmpty == true) {
        _events.remove(selectedDate);
      }
    });

    // Save updated events to shared preferences
    _saveEvents();
  }

  void _showAddEventDialog() {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  TimeOfDay? startTime;
  TimeOfDay? endTime;

  showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text("Add Event"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: "Event Name"),
                ),
                TextField(
                  controller: locationController,
                  decoration: const InputDecoration(labelText: "Location"),
                ),
                ListTile(
                  title: Text(startTime != null
                      ? 'Start Time: ${startTime!.format(context)}'
                      : 'Select Start Time'),
                  trailing: const Icon(Icons.access_time),
                  onTap: () async {
                    final pickedTime = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                    );
                    if (pickedTime != null) {
                      setState(() => startTime = pickedTime);
                    }
                  },
                ),
                ListTile(
                  title: Text(endTime != null
                      ? 'End Time: ${endTime!.format(context)}'
                      : 'Select End Time'),
                  trailing: const Icon(Icons.access_time),
                  onTap: () async {
                    final pickedTime = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                    );
                    if (pickedTime != null) {
                      setState(() => endTime = pickedTime);
                    }
                  },
                ),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(labelText: "Description"),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  if (startTime != null && endTime != null) {
                    _addEvent(
                      nameController.text,
                      locationController.text,
                      startTime!.format(context),
                      endTime!.format(context),
                      descriptionController.text,
                    );
                    Navigator.of(context).pop();
                  }
                },
                child: const Text("Add Event"),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text("Cancel"),
              ),
            ],
          );
        },
      );
    },
  );
}
}