class Event {
  String name;
  String location;
  String start;
  String end;
  String description;
  String date;

  Event({
    required this.name,
    required this.location,
    required this.start,
    required this.end,
    required this.description,
    required this.date,
  });

  // Method to convert Event object to JSON
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'location': location,
      'start': start,
      'end': end,
      'description': description,
      'date': date,
    };
  }

  // Method to create Event from JSON
  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      name: json['name'],
      location: json['location'],
      start: json['start'],
      end: json['end'],
      description: json['description'],
      date: json['date'],
    );
  }
}