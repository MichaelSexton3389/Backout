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

  final Map<DateTime, List<String>> _events = {};  //Map to store events, where each date has a list of event names

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
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center, //Center align
                                  children: [
                                    const Icon(Icons.event, size: 24), //Event icon
                                    const SizedBox(width: 8), //Spacing between icon and text
                                    Text(
                                      event, //Event name
                                      style: const TextStyle(fontSize: 16),
                                    ),
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
    );
  }
}
