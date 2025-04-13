import 'package:flutter/material.dart';
import 'package:BackOut/models/event.dart';
import 'package:BackOut/services/event_service.dart';

class EventProvider with ChangeNotifier {
  List<Event> _events = [];

  List<Event> get events => _events;

  // Add event to the list
  void addEvent(Event event) {
    _events.add(event);
    notifyListeners();
  }

  // Fetch events from local database/storage
  Future<void> fetchEvents(String date) async {
    _events = await EventService.getEvents(date);
    notifyListeners();
  }

  // Save event to local database/storage
  Future<void> saveEvent(Event event) async {
    await EventService.saveEvent(event);
    addEvent(event);
  }
}