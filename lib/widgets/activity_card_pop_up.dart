import 'package:flutter/material.dart';
import 'activity_card_pop_up.dart';
import 'dart:ui';
class ActivityCardPopUp extends StatelessWidget {
  final String title;
  final String date;
  final String location;
  final String createdBy;
  final List<String> participants;
  final String backgroundImageUrl;

  const ActivityCardPopUp({
    super.key,
    required this.title,
    required this.date,
    required this.location,
    required this.createdBy,
    required this.participants,
    required this.backgroundImageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Colors.transparent,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            Positioned.fill(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(color: Colors.black.withOpacity(0.5)),
      ),
    ),
            SizedBox(
              width: double.infinity,
              child: Image.network(
                backgroundImageUrl,
                fit: BoxFit.cover,
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today, color: Colors.white70, size: 16),
                      const SizedBox(width: 8),
                      Text(date, style: const TextStyle(color: Colors.white70)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.location_pin, color: Colors.white70, size: 16),
                      const SizedBox(width: 8),
                      Text(location, style: const TextStyle(color: Colors.white70)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Hosted by $createdBy',
                    style: const TextStyle(color: Colors.white70),
                  ),
                  const Divider(color: Colors.white24, height: 20),
                  const Text(
                    'Participants:',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  Wrap(
  spacing: 8,
  children: participants
      .map((name) => Chip(
            label: Text(
              name,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
            ),
            backgroundColor: Colors.black.withOpacity(0.4),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Colors.white30),
            ),
            elevation: 0,
          ))
      .toList(),
),
                  const SizedBox(height: 16),
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurpleAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Close'),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
