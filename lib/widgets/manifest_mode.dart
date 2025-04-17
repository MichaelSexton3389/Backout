import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:BackOut/widgets/modal_background.dart';
import 'package:BackOut/widgets/activity_pals_invite.dart';
import 'package:BackOut/widgets/create_activty_form.dart';
// import 'package:assets/api_keys.json';

class ManifestModeScreen extends StatefulWidget {
  const ManifestModeScreen({Key? key}) : super(key: key);

  @override
  State<ManifestModeScreen> createState() => _ManifestModeScreenState();
}

class _ManifestModeScreenState extends State<ManifestModeScreen> {
  final TextEditingController _controller = TextEditingController();
  final TextEditingController _locationController =
      TextEditingController(); // New TextEditingController for location input
  bool _loading = false;
  List<ActivitySuggestion> _suggestions = [];
  String _selectedMode = 'Go out'; // New state variable for mode selection.
  final Map<String, List<ActivitySuggestion>> _cache =
      {}; // In-memory cache for suggestions.

  // Replace with your actual API key.
  // final String _k ="gptkey" 
  final String _k=""
      ;

  Future<void> _fetchSuggestions(String userInput) async {
    setState(() {
      _loading = true;
    });
    print("User input: $userInput");

    try {
      if (_cache.containsKey(userInput)) {
        print("Loaded from cache");
        setState(() {
          _suggestions = _cache[userInput]!;
        });
        return;
      }

      String finalResponse =
          await _fetchActivitySuggestionsWithGpt4oMini(userInput);
      print("Final Activity Suggestions: $finalResponse");

      final suggestions = _parseSuggestions(finalResponse);
      _cache[userInput] = suggestions;
      setState(() {
        _suggestions = suggestions;
      });
    } catch (e) {
      print('Exception: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error generating suggestions.')),
      );
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  Future<String> _fetchActivitySuggestionsWithGpt4oMini(
      String userInput) async {
    final prompt = """
Your task is to suggest 3 realistic, fun, casual outdoor activities or hangout spots perfect for Gen Z friends based specifically on this input: "$userInput". 

Important guidelines:
- Activities must be realistically available and culturally suitable for the provided location.
- Suggest spontaneous, unique, and adventurous experiences that Gen Z friends would genuinely enjoy and can easily participate in locally.
- Avoid overly generic or stereotypical suggestions; ensure suggestions are practical, accessible, and reflect actual possibilities at the given location.

Format your response exactly like this:

1. Title: <title>
   Description: <description (highlighting why it's fun and relevant)>
   Location: <specific, accessible, and realistic location within the provided city/area>

2. Title: ...
""";

    final url = Uri.parse('https://api.openai.com/v1/chat/completions');
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $_k',
    };
    final body = jsonEncode({
      'model': 'gpt-4o-mini',
      'messages': [
        {'role': 'user', 'content': prompt},
      ],
      'temperature': 0.8,
      'max_tokens': 400,
    });

    try {
      final response = await http.post(url, headers: headers, body: body);
      print("GPT-4o-mini response: ${response.body}");
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['choices'][0]['message']['content'] as String;
        return content;
      } else {
        throw Exception(
            'Error in GPT-4o-mini API call: ${response.statusCode}');
      }
    } catch (e) {
      print('Exception in GPT-4o-mini API call: $e');
      rethrow;
    }
  }

  // A simple parser using RegExp.
  // Assumes each suggestion is formatted exactly as in the prompt.
  List<ActivitySuggestion> _parseSuggestions(String content) {
    List<ActivitySuggestion> suggestions = [];
    // This regex expects suggestions starting with "1. Title: ..." on separate lines.
    final regex = RegExp(
      r'\d+\.\s*Title:\s*(.*?)\s*Description:\s*(.*?)\s*Location:\s*(.*?)(?=\n\d+\.|$)',
      dotAll: true,
    );
    final matches = regex.allMatches(content);
    for (final match in matches) {
      if (match.groupCount >= 3) {
        suggestions.add(ActivitySuggestion(
          title: match.group(1)?.trim() ?? '',
          description: match.group(2)?.trim() ?? '',
          location: match.group(3)?.trim() ?? '',
        ));
      }
    }
    return suggestions;
  }

  void _applySuggestion(ActivitySuggestion suggestion) {
    // For now, we just show a dialog with the suggestion.
    // In your actual app, you might pre-fill your Create Activity form and then navigate to the Invite Pals overlay.
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Selected Suggestion"),
          content: Text("Title: ${suggestion.title}\n"
              "Description: ${suggestion.description}\n"
              "Location: ${suggestion.location}"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                // Navigate to your Invite Pals overlay or pre-filled form.
              },
              child: const Text("OK"),
            )
          ],
        );
      },
    );
  }

  void showInviteBuddiesOverlay() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return FractionallySizedBox(
          heightFactor: 0.9,
          child: ModalBackground(
            child: Material(
              type: MaterialType.transparency,
              // child: InvitePalsScreen(),
            ),
          ),
        );
      },
    );
  }

void _showPrefilledActivityForm(ActivitySuggestion suggestion) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return FractionallySizedBox(
        heightFactor: 0.95,
        child: ModalBackground(
          child: Material(
            type: MaterialType.transparency,
            child: CreateActivityFormUpdated(
              initialTitle: suggestion.title,
              initialLocation: suggestion.location,
              initialDescription: suggestion.description,
            ),
          ),
        ),
      );
    },
  );
}

  @override
  Widget build(BuildContext context) {
    // Remove Scaffold and use SafeArea with a bounded Container.
    return Scaffold(
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Stack(
          children: [
            // Background Image
            SizedBox.expand(
              child: Image.network(
                'https://images.pexels.com/photos/2604622/pexels-photo-2604622.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=2',
                fit: BoxFit.cover,
              ),
            ),
            // Dark overlay for contrast
            Container(color: Colors.black.withOpacity(0.3)),
            // Main content within a SafeArea
            // Main content within a SafeArea
            SafeArea(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 50),
                    // The content container that holds input fields and buttons
                    Container(
                      padding: const EdgeInsets.all(16),
                      margin: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        children: [
                          // Mode navigation chips
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(20),
                                  onTap: () {
                                    Navigator.pop(context);
                                    showModalBottomSheet(
                                      context: context,
                                      isScrollControlled: true,
                                      backgroundColor: Colors.transparent,
                                      builder: (context) {
                                        return const FractionallySizedBox(
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
                                  },
                                  child: const Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                    child: Text(
                                      'BackOff AI',
                                      style: TextStyle(color: Colors.black),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Color(0xFF6A1B9A), // Deep Purple
                                      Color(0xFFAB47BC), // Soft Pinkish Purple
                                    ],
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(20),
                                  onTap: () {
                                    Navigator.pop(context);
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                    child: Text(
                                      'Manifest Mode',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          // Input for location
                          const Text(
                            "Enter your location:",
                            style: TextStyle(color: Colors.white),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _locationController,
                            style: const TextStyle(color: Colors.white),
                            decoration: const InputDecoration(
                              hintText: 'e.g. Las Vegas',
                              hintStyle: TextStyle(color: Colors.white70),
                              filled: true,
                              fillColor: Colors.black26,
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Input for event idea
                          const Text(
                            "Enter your event idea:",
                            style: TextStyle(color: Colors.white),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _controller,
                            style: const TextStyle(color: Colors.white),
                            maxLines: 5,
                            decoration: const InputDecoration(
                              hintText:
                                  "I want to experience nature this weekend",
                              hintStyle: TextStyle(color: Colors.white70),
                              filled: true,
                              fillColor: Colors.black26,
                              border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(12)),
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                  vertical: 16, horizontal: 16),
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Additional mode selection
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ChoiceChip(
                                label: Text(
                                  'Invite friends over',
                                  style: TextStyle(
                                      color:
                                          _selectedMode == 'Invite friends over'
                                              ? Colors.black
                                              : Colors.white),
                                ),
                                selected:
                                    _selectedMode == 'Invite friends over',
                                selectedColor: Colors.purpleAccent,
                                backgroundColor: Colors.black54,
                                onSelected: (bool selected) {
                                  setState(() {
                                    _selectedMode = 'Inside';
                                  });
                                },
                              ),
                              const SizedBox(width: 8),
                              ChoiceChip(
                                label: Text(
                                  'Go Out',
                                  style: TextStyle(
                                      color: _selectedMode == 'Go Out'
                                          ? Colors.black
                                          : Colors.white),
                                ),
                                selected: _selectedMode == 'Go Out',
                                selectedColor: Colors.purpleAccent,
                                backgroundColor: Colors.black54,
                                onSelected: (bool selected) {
                                  setState(() {
                                    _selectedMode = 'Outside';
                                  });
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          // Generate Suggestions button
                          _loading
                              ? const CircularProgressIndicator()
                              : InkWell(
                                  onTap: () {
                                    final userInput = _controller.text;
                                    final userLocation =
                                        _locationController.text.trim();
                                    final combinedInput =
                                        '$userInput. Mode: $_selectedMode. Location: $userLocation';
                                    _fetchSuggestions(combinedInput);
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 24, vertical: 14),
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [
                                          Colors.deepPurple,
                                          Colors.purpleAccent
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Text(
                                      "Generate Suggestions",
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                          const SizedBox(height: 16),
                          // Display suggestions if available
                          if (_suggestions.isNotEmpty)
                            Column(
                              children: _suggestions.map((suggestion) {
                                return Card(
                                  color: const Color.fromARGB(188, 36, 34, 39),
                                  elevation: 4,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  margin:
                                      const EdgeInsets.symmetric(vertical: 8),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          suggestion.title,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 20,
                                            color: Colors.white,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          suggestion.description,
                                          style: const TextStyle(
                                            color: Color(0xFFDDDDDD),
                                            height: 1.4,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          suggestion.location,
                                          style: const TextStyle(
                                            color: Color(0xFFB0B0B0),
                                            fontStyle: FontStyle.italic,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.stretch,
                                          children: [
                                            
                                            const SizedBox(height: 8),
                                            Container(
                                              decoration: BoxDecoration(
                                                gradient: const LinearGradient(
                                                  colors: [
                                                    Color.fromARGB(255, 20, 16, 28),
                                                    Color.fromARGB(255, 188, 105, 202)
                                                  ],
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              child: TextButton(
                                                onPressed: () =>
                                                    _showPrefilledActivityForm(
                                                        suggestion),
                                                child: const Text(
                                                  'Make it Happen',
                                                  style: TextStyle(
                                                      color: Color.fromARGB(255, 255, 255, 255),
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                        ], // End of Column children in SingleChildScrollView\n          ),\n        ),\n      ], // End of Stack children\n    ),\n  ),\n);\n```\n\nMake sure that after this block you correctly close the Stack, GestureDetector, and Scaffold with matching parentheses. This should resolve the unmatched parenthesis error."
                      ),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class ActivitySuggestion {
  final String title;
  final String description;
  final String location;

  ActivitySuggestion({
    required this.title,
    required this.description,
    required this.location,
  });
}
