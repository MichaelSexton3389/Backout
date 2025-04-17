import 'package:flutter/material.dart';
import 'package:BackOut/widgets/manifest_mode.dart';
import 'package:BackOut/widgets/modal_background.dart';
import 'package:BackOut/widgets/select_activity_picture.dart';
import 'package:BackOut/providers/user_providers.dart';
import 'package:provider/provider.dart';
import 'package:BackOut/widgets/activity_pals_invite.dart';

class CreateActivityFormUpdated extends StatefulWidget {
  final String? initialTitle;
  final String? initialLocation;
  final String? initialDescription;
  const CreateActivityFormUpdated({
    super.key,
        this.initialTitle,
    this.initialLocation,
    this.initialDescription,
    });

  @override
  State<CreateActivityFormUpdated> createState() =>
      _CreateActivityFormUpdatedState();

      
}

class _CreateActivityFormUpdatedState extends State<CreateActivityFormUpdated> {
  
  DateTime selectedDateTime = DateTime.now();
  @override
void initState() {
  super.initState();
  _titleController = TextEditingController(text: widget.initialTitle ?? '');
  _locationController = TextEditingController(text: widget.initialLocation ?? '');
  _descriptionController = TextEditingController(text: widget.initialDescription ?? '');
}
  late final TextEditingController _titleController;
  late final TextEditingController _locationController;
  late final TextEditingController _descriptionController;
  bool isEditingTitle = false;
  bool isEditingLocation = false;
  bool isEditingDescription = false;
  String selectedImageUrl = 'https://images.pexels.com/photos/2604622/pexels-photo-2604622.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=2';


  



  Future<void> _pickDateTime() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDateTime,
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
      builder: (BuildContext context, Widget? child) {
    return Theme(
      data: Theme.of(context).copyWith(
        colorScheme: ColorScheme.light(
          primary: const Color.fromARGB(255, 255, 255, 255),    // Header background color
          onPrimary: const Color.fromARGB(255, 255, 0, 0),       // Header text color
          surface: const Color.fromARGB(248, 0, 0, 0),          // Background color for the main area
          onSurface: const Color.fromARGB(255, 255, 255, 255),       // Text color for the main area
        ),
        dialogBackgroundColor: Colors.blueGrey, // Overall background color of the picker dialog
      ),
      child: child!,
    );
  },
    );

    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(selectedDateTime),
        builder: (BuildContext context, Widget? child) {
    return Theme(
      data: Theme.of(context).copyWith(
        colorScheme: ColorScheme.light(
          primary: const Color.fromARGB(255, 255, 255, 255),    // Header background color
          onPrimary: const Color.fromARGB(255, 255, 0, 0),       // Header text color
          surface: const Color.fromARGB(248, 0, 0, 0),          // Background color for the main area
          onSurface: const Color.fromARGB(255, 255, 255, 255),       // Text color for the main area
        ),
        dialogBackgroundColor: Colors.blueGrey, // Overall background color of the picker dialog
      ),
      child: child!,
    );
  },
      );

      if (pickedTime != null) {
        setState(() {
          selectedDateTime = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
    }
  }
  void showInviteBuddiesOverlay() {
    print("Title being sent to invite overlay: '${_titleController.text}'");
    print("Location being sent to invite overlay: '${_locationController.text}'");
    print("description being sent to invite overlay: '${ _descriptionController.text}'");
    print("bgImg being sent to invite overlay: '$selectedImageUrl'");
    print("date being sent to invite overlay: '${selectedDateTime.toIso8601String()}'");

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
            child: InvitePalsScreen(
              title: _titleController.text,
              location: _locationController.text,
              description: _descriptionController.text,
              bgImg: selectedImageUrl,
              date: selectedDateTime.toIso8601String(),
            ),
          ),
        ),
      );
    },
  );
}
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        // This onTap will dismiss editing mode when tapping outside
        behavior: HitTestBehavior.opaque,
        onTap: () {
          if (isEditingTitle) {
            setState(() {
              isEditingTitle = false;
            });
            FocusScope.of(context).unfocus();
          }
          if (isEditingLocation) {
            setState(() {
              isEditingLocation = false;
            });
            FocusScope.of(context).unfocus();
          }
          if (isEditingDescription) {
            setState(() {
              isEditingDescription = false;
            });
            FocusScope.of(context).unfocus();
          }
        },
        child: Stack(
          children: [
            // Background Image
            SizedBox.expand(
              child: Image.network(
                selectedImageUrl,
                fit: BoxFit.cover,
              ),
            ),
            Container(
              color: Colors.black.withOpacity(0.4),
            ),
            SafeArea(
              
              child: Column(
                children: [
                  const Spacer(),
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
                            // Already on BackOff AI, do nothing
                          },
                          child: const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            child: Text(
                              'Create',
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
                                      child: ManifestModeScreen(),
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                          child: const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                  Container(
                    padding: const EdgeInsets.all(16),
                    margin:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Stack(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const SizedBox(height: 12),
                                                        ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white.withOpacity(0.2),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: () {
                                showModalBottomSheet(
                                  context: context,
                                  isScrollControlled: true,
                                  backgroundColor: Colors.transparent,
                                  builder: (context) {
                                    return FractionallySizedBox(
                                      heightFactor: 0.85,
                                      child: ModalBackground(
                                        child: Material(
                                          type: MaterialType.transparency,
                                          child: SelectActivityPicture(
                                            onImageSelected: (url) {
                                              setState(() {
                                                selectedImageUrl = url;
                                              });
                                            },
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                );
                              },
                              icon: const Icon(Icons.image, color: Colors.white),
                              label: const Text(
                                'Select Activity Image',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                            const SizedBox(height: 12),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  isEditingTitle = true;
                                });
                              },
                                  child: isEditingTitle
                                  ? Theme(
                                      data: Theme.of(context).copyWith(
                                        textSelectionTheme:
                                            const TextSelectionThemeData(
                                          selectionColor: Colors.grey,
                                        ),
                                      ),
                                      child: TextField(
                                        controller: _titleController,
                                        autofocus: true,
                                        style: const TextStyle(
                                          fontSize: 28,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                        cursorColor: Colors.white,
                                        textAlign: TextAlign.center,
                                        maxLines: 2,
                                        decoration: const InputDecoration(
                                          border: InputBorder.none,
                                          hintText: 'Add Title',
                                          hintStyle: TextStyle(color: Colors.white54),
                                        ),
                                        onSubmitted: (_) {
                                          setState(() {
                                            isEditingTitle = false;
                                          });
                                        },
                                      ),
                                    )
                                  : Text(
                                      _titleController.text.isEmpty ? 'Add Title' : _titleController.text,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontSize: 28,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                            ),
                            const SizedBox(height: 12),
                            GestureDetector(
                              onTap: _pickDateTime,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.calendar_today,
                                      color: Colors.white70, size: 18),
                                  const SizedBox(width: 8),
                                  Text(
                                    '${selectedDateTime.day} ${_monthName(selectedDateTime.month)}, ${selectedDateTime.hour}:${selectedDateTime.minute.toString().padLeft(2, '0')} ${selectedDateTime.hour >= 12 ? "PM" : "AM"}',
                                    style:
                                        const TextStyle(color: Colors.white70),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                            isEditingLocation
                                ? TextField(
                                    controller: _locationController,
                                    autofocus: true,
                                    style: const TextStyle(
                                      color: Colors.white70,
                                    ),
                                    cursorColor: Colors.white70,
                                    textAlign: TextAlign.center,
                                    maxLines: 2,
                                    decoration: const InputDecoration(
                                      border: InputBorder.none,
                                      hintText: 'Add Location',
                                      hintStyle: TextStyle(color: Colors.white54),
                                    ),
                                    onSubmitted: (_) {
                                      setState(() {
                                        isEditingLocation = false;
                                      });
                                    },
                                  )
                                : GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        isEditingLocation = true;
                                      });
                                    },
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        const Icon(Icons.location_pin,
                                            color: Colors.white70),
                                        const SizedBox(width: 8),
                                        Text(
                                          _locationController.text.isEmpty ? 'Add Location' : _locationController.text,
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(color: Colors.white70),
                                        ),
                                      ],
                                    ),
                                  ),
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    backgroundImage: (Provider.of<UserProvider>(
                                                        context)
                                                    .user
                                                    .profilePicture ??
                                                '')
                                            .isNotEmpty
                                        ? NetworkImage(
                                            Provider.of<UserProvider>(context)
                                                .user
                                                .profilePicture!)
                                        : null,
                                    child: (Provider.of<UserProvider>(context)
                                                    .user
                                                    .profilePicture ??
                                                '')
                                            .isEmpty
                                        ? Text(
                                            Provider.of<UserProvider>(context)
                                                    .user
                                                    .name
                                                    .isNotEmpty
                                                ? Provider.of<UserProvider>(
                                                        context)
                                                    .user
                                                    .name[0]
                                                : "U",
                                            style: const TextStyle(
                                                color: Colors.white),
                                          )
                                        : null,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Hosted by ${Provider.of<UserProvider>(context).user.name}",
                                          style: const TextStyle(
                                              color: Colors.white),
                                        ),
                                        Focus(
                                          onFocusChange: (hasFocus) {
                                            setState(() {
                                              isEditingDescription = hasFocus;
                                            });
                                          },
                                          child: TextField(
                                            controller: _descriptionController,
                                            style: const TextStyle(color: Colors.white70),
                                            cursorColor: Colors.white70,
                                            maxLines: null,
                                            decoration: const InputDecoration(
                                              border: InputBorder.none,
                                              hintText: 'Add a description',
                                              hintStyle: TextStyle(color: Colors.white54),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                            _sharedSection(Icons.photo_album, "Event Bin",
                                "share pics."),
                            const SizedBox(height: 8),
                            _sharedSection(Icons.music_note, "Playlist",
                                "Share music."),
                            const SizedBox(height: 16),
                            // Extra spacing to ensure the button does not overlap content
                            const SizedBox(height: 50),
                          ],
                        ),
                        const SizedBox(height: 30),
                        Positioned(
                          bottom: 5,
                          right: 10,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black.withOpacity(0.75),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(40),
                              ),
                            ),
                            onPressed:  
                              showInviteBuddiesOverlay,
                            child: const Text(
                              'Invite Buddies',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
void dispose() {
  _titleController.dispose();
  _locationController.dispose();
  _descriptionController.dispose();
  super.dispose();
}

  Widget _sharedSection(IconData icon, String title, String subtitle) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold)),
                Text(subtitle,
                    style:
                        const TextStyle(color: Colors.white70, fontSize: 13)),
              ],
            ),
          )
        ],
      ),
    );
  }

  String _monthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return months[month - 1];
  }
}
