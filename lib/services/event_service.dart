import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:BackOut/models/event.dart';

class EventService {
  static const String _eventKey = 'events';

  // Fetch events from local storage
  static Future<List<Event>> getEvents(String date) async {
    final prefs = await SharedPreferences.getInstance();
    String? eventsJson = prefs.getString(_eventKey);

    if (eventsJson == null) {
      return [];
    }

    List<dynamic> eventsList = json.decode(eventsJson);
    return eventsList
        .where((eventJson) => eventJson['date'] == date)
        .map((eventJson) => Event.fromJson(eventJson))
        .toList();
  }

  // Save event to local storage
  static Future<void> saveEvent(Event event) async {
    final prefs = await SharedPreferences.getInstance();
    String? eventsJson = prefs.getString(_eventKey);

    List<dynamic> eventsList = eventsJson == null ? [] : json.decode(eventsJson);
    eventsList.add(event.toJson());
    prefs.setString(_eventKey, json.encode(eventsList));
  }
}