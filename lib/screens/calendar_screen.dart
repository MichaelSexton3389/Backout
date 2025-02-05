import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;   //Controls the calendar's format (month, week, or 2 weeks view)

  DateTime _focusedDay = DateTime.now();  //The currently focused day (defaults to today)

  DateTime? _selectedDay;  //The selected day, initialized as null (user selects a day)

  final Map<DateTime, List<Map<String, String>>> _events = {};  //Map to store events with additional details

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Your Events")), //Top bar with title
      body: Column(
        children: [
          //TableCalendar widget for displaying the calendar
          TableCalendar(
            firstDay: DateTime.utc(2020, 1, 1), //Sets the earliest selectable date
            lastDay: DateTime.utc(2030, 12, 31), //Sets the latest selectable date
            focusedDay: _focusedDay, //Defines which month is displayed initially
            calendarFormat: _calendarFormat, //Controls the view format (month, week, etc.)

            selectedDayPredicate: (day) {  //Determines if a day is selected (returns true if it matches _selectedDay)
              return isSameDay(_selectedDay, day);
            },

            onDaySelected: (selectedDay, focusedDay) { //Triggers when a user selects a day
              setState(() {
                _selectedDay = selectedDay; //Updates the selected day
                _focusedDay = focusedDay; //Ensures the calendar remains on the correct month
              });
            },

            //Loads events for a given date
            eventLoader: (day) {
              return _events[DateTime(day.year, day.month, day.day)] ?? [];
            },
          ),

          const SizedBox(height: 16), //Adds spacing below the calendar

          //Expanded widget allows the list to take up available space
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center, //Centers content vertically
              crossAxisAlignment: CrossAxisAlignment.center, //Centers content horizontally
              children: [
                //Check if there are events for the selected day
                if (_selectedDay != null &&
                    _events.containsKey(DateTime(
                        _selectedDay!.year, _selectedDay!.month, _selectedDay!.day)))
                  Column(
                    children: [
                      //Display the date of selected events
                      Text(
                        "Events on ${_selectedDay!.year}-${_selectedDay!.month}-${_selectedDay!.day}",
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8), //Spacing before event list

                      //Display list of events for the selected day
                      ..._events[DateTime(
                              _selectedDay!.year, _selectedDay!.month, _selectedDay!.day)]!
                          .map((event) => Padding(
                                padding: const EdgeInsets.symmetric(vertical: 6),
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center, //Center align
                                      children: [
                                        const Icon(Icons.event, size: 24), //Event icon
                                        const SizedBox(width: 8), //Spacing between icon and text
                                        Text(
                                          event["name"] ?? "Unnamed Event", //Event name
                                          style: const TextStyle(fontSize: 16),
                                        ),
                                      ],
                                    ),
                                    Text("Start: ${event["start"]} - End: ${event["end"]}"),
                                    Text("Location: ${event["location"]}"),
                                    Text("Description: ${event["description"]}"), // Display description
                                    const SizedBox(height: 8), //Spacing before delete button
                                    IconButton(
                                      icon: const Icon(Icons.delete, color: Colors.red), //Delete button
                                      onPressed: () => _deleteEvent(event),
                                    ),
                                    const Divider(), //Separates events
                                  ],
                                ),
                              )),
                    ],
                  )
                else
                  //Show a message if no events exist for the selected day
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

      //Floating action button for adding events
      floatingActionButton: FloatingActionButton(
        onPressed: _selectedDay != null ? _showAddEventDialog : null, //Disables if no date is selected
        child: const Icon(Icons.add),
      ),
    );
  }

  //Function to add an event to the selected date
  void _addEvent(String name, String location, String start, String end, String description) {
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
        "description": description, // Store description
      });
    });
  }

  //Function to delete an event
  void _deleteEvent(Map<String, String> event) {
    setState(() {
      DateTime selectedDate = DateTime(_selectedDay!.year, _selectedDay!.month, _selectedDay!.day);
      _events[selectedDate]?.remove(event);
      if (_events[selectedDate]?.isEmpty == true) {
        _events.remove(selectedDate);
      }
    });
  }

  //Function to show a dialog for adding an event with keyboard-based time selection defaulting to "00:00"
  void _showAddEventDialog() {
    TextEditingController eventController = TextEditingController();
    TextEditingController locationController = TextEditingController();
    TextEditingController startTimeController = TextEditingController(text: "00:00"); // Default value
    TextEditingController endTimeController = TextEditingController(text: "00:00"); // Default value
    TextEditingController descriptionController = TextEditingController(); // Description field

    Future<void> _pickTime(TextEditingController controller) async {
      TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay(hour: 0, minute: 0), // Default to 00:00
        initialEntryMode: TimePickerEntryMode.inputOnly, //Forces keyboard mode instead of dial
      );
      if (pickedTime != null) {
        setState(() {
          controller.text = pickedTime.format(context); //Display selected time
        });
      }
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Add Event"), //Dialog title
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start, //Aligns content to the left
          children: [
            TextField(
              controller: eventController, //input field for event name
              decoration: const InputDecoration(hintText: "Enter event name"),
            ),
            const SizedBox(height: 12), //Spacing
            TextField(
              controller: locationController, //Input field for event location
              decoration: const InputDecoration(hintText: "Enter location"),
            ),
            const SizedBox(height: 12), //spacing
            TextField(
              controller: descriptionController, //Input field for event description
              decoration: const InputDecoration(hintText: "Enter event description"),
            ),
            const SizedBox(height: 20), //More spacing before time fields
            
            //Start Time Selection (Keyboard-Based)
            TextField(
              controller: startTimeController, //Displays selected start time
              readOnly: true, //Prevents manual input
              decoration: const InputDecoration(
                hintText: "Pick Start Time",
                suffixIcon: Icon(Icons.access_time), //Clock icon for clarity
              ),
              onTap: () => _pickTime(startTimeController), //Opens keyboard time picker
            ),
            const SizedBox(height: 12), //Spacing

            //End Time Selection (Keyboard-Based)
            TextField(
              controller: endTimeController, //Displays selected end time
              readOnly: true, //Prevents manual input
              decoration: const InputDecoration(
                hintText: "Pick End Time",
                suffixIcon: Icon(Icons.access_time), //Clock icon for clarity
              ),
              onTap: () => _pickTime(endTimeController), //Opens keyboard time picker
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), //Closes the dialog
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              _addEvent(eventController.text, locationController.text, startTimeController.text, endTimeController.text, descriptionController.text);
              Navigator.pop(context); //Closes the dialog
            },
            child: const Text("Add"),
          ),
        ],
      ),
    );
  }
}
