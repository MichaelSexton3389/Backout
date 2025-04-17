import 'dart:io';
import 'package:flutter/material.dart';
import 'package:BackOut/services/socket_service.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:BackOut/services/gcs_services.dart';
import 'dart:convert';
import 'package:BackOut/utils/constants.dart';

class ChatScreen extends StatefulWidget {
  final String currentUser;
  final String receiverUser;

  ChatScreen({required this.currentUser, required this.receiverUser});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final SocketService _socketService = SocketService();
  final TextEditingController _messageController = TextEditingController();
  List<Map<String, String>> messages = [];
  bool _isTyping = false;
  bool _canSendMessage = false;
  bool _isLoading = true;
  File? _selectedImage;

  @override
  void initState() {
    super.initState();
    fetchMessages();
    if (!_socketService.isConnected) {
      _socketService.connect();
    }

    _socketService.socket.on('receiveMessage', (data) {
      if (mounted) {
        bool isDuplicate = messages.any((msg) =>
            msg['message'] == data['message'] &&
            msg['sender'] == data['sender']);
        if (!isDuplicate) {
          setState(() {
            messages.add({
              'sender': data['sender'],
              'message': data['message'] ?? "",
              'imageUrl': data['imageUrl'] ?? "",
              'timestamp': DateTime.now().toIso8601String(),
            });
          });
        }
      }
    });

    _socketService.socket.on('typing', (_) {
      if (mounted) setState(() => _isTyping = true);
    });

    _socketService.socket.on('stopTyping', (_) {
      if (mounted) setState(() => _isTyping = false);
    });
  }

  // Function to fetch messages
  Future<void> fetchMessages() async {
    try {
      final response = await http.get(Uri.parse(
          '${Constants.uri}${widget.currentUser}/${widget.receiverUser}'));

      if (response.statusCode == 200) {
        List<dynamic> messagesJson = json.decode(response.body);
        setState(() {
          messages = messagesJson
              .map((msg) => {
                    'sender': msg['sender'].toString(),
                    'message': msg['message'].toString(),
                    'imageUrl': msg['imageUrl']?.toString() ?? "",
                    'timestamp': msg['timestamp'].toString(),
                  })
              .toList();
          _isLoading = false;
        });
      } else {
        throw Exception("Failed to load messages");
      }
    } catch (e) {
      print("Error fetching messages: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> pickAndUploadImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      File selectedImage = File(pickedFile.path);

      setState(() {
        _selectedImage = selectedImage; // Show selected image in the UI
      });

      try {
        // Upload the image to Google Cloud Storage and get the image URL
        String? imageUrl = await GCSService.uploadImageToGCS(selectedImage);

        if (imageUrl != null) {
          print("Image uploaded successfully: $imageUrl");
          // Send the image message after image is uploaded
          sendMessage(
            widget.currentUser,
            widget.receiverUser,
            '', // Empty text, as this is just an image
            imageUrl, // Pass the image URL here
          );
        } else {
          print("Image upload failed");
        }
      } catch (e) {
        print("Error uploading image: $e");
      }
    }
  }

  Future<void> sendMessage(
      String sender, String receiver, String message, String? imageUrl) async {
    String textMessage = message.trim();

    if (textMessage.isNotEmpty || imageUrl != null) {
      setState(() {
        _isLoading =
            true; // Show loading spinner while the message is being sent
      });

      try {
        // Send the message along with the image URL (which is a String?)
        await _socketService.sendMessage(
          sender,
          receiver,
          textMessage,
          imageUrl, // Pass the image URL here (String?)
        );

        setState(() {
          // After sending, update the messages list and reset the UI
          messages.add({
            'sender': sender,
            'message': textMessage,
            'imageUrl':
                imageUrl ?? '', // If imageUrl is null, send an empty string
            'timestamp': DateTime.now().toIso8601String(),
          });
          _messageController.clear();
          _selectedImage = null;
          _isLoading = false;
          _canSendMessage = false;
        });
      } catch (e) {
        print("Error sending message: $e");
        setState(() {
          _isLoading = false; // Stop loading if there's an error
        });
      }
    }
  }

  @override
  void dispose() {
    _socketService.socket.off('receiveMessage');
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Chat")),
      body: Column(
        children: [
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      bool isMe =
                          messages[index]['sender'] == widget.currentUser;
                      bool hasImage = messages[index]['imageUrl'] != "";

                      return Row(
                        mainAxisAlignment: isMe
                            ? MainAxisAlignment.end
                            : MainAxisAlignment.start,
                        children: [
                          if (!isMe)
                            CircleAvatar(
                              backgroundColor: Colors.blueGrey,
                              child: Text(
                                messages[index]['sender']![0].toUpperCase(),
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          SizedBox(width: isMe ? 0 : 6),
                          Container(
                            margin: EdgeInsets.symmetric(
                                vertical: 4, horizontal: 8),
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color:
                                  isMe ? Colors.blueAccent : Colors.grey[300],
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(12),
                                topRight: Radius.circular(12),
                                bottomLeft:
                                    isMe ? Radius.circular(12) : Radius.zero,
                                bottomRight:
                                    isMe ? Radius.zero : Radius.circular(12),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (hasImage)
                                  Padding(
                                    padding: EdgeInsets.only(bottom: 8),
                                    child: Image.network(
                                      messages[index]['imageUrl']!,
                                      width: 200,
                                      height: 200,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                if (messages[index]['message']!.isNotEmpty)
                                  Text(
                                    messages[index]['message']!,
                                    style: TextStyle(
                                      color: isMe ? Colors.white : Colors.black,
                                    ),
                                  ),
                                SizedBox(height: 4),
                                Text(
                                  DateFormat('h:mm a').format(
                                    DateTime.parse(
                                        messages[index]['timestamp']!),
                                  ),
                                  style: TextStyle(
                                    fontSize: 10,
                                    color:
                                        isMe ? Colors.white70 : Colors.black54,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
          ),
          if (_isTyping)
            Padding(
              padding: EdgeInsets.only(left: 16, bottom: 4),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text("User is typing...",
                    style: TextStyle(fontSize: 12, color: Colors.grey)),
              ),
            ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Padding(
      padding: EdgeInsets.all(8.0),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.image, color: Colors.blueAccent),
            onPressed: pickAndUploadImage,
          ),
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: "Type a message",
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 16),
              ),
              onChanged: (value) {
                setState(() {
                  _canSendMessage =
                      value.trim().isNotEmpty || _selectedImage != null;
                });
              },
            ),
          ),
          IconButton(
            icon: Icon(Icons.send,
                color: _canSendMessage ? Colors.blueAccent : Colors.grey),
            onPressed: _canSendMessage
                ? () async {
                    String textMessage = _messageController.text.trim();

                    // If there's an image, upload it first and get the URL
                    String? imageUrl;
                    if (_selectedImage != null) {
                      imageUrl =
                          await GCSService.uploadImageToGCS(_selectedImage!);
                    }

                    // Send the message with the image URL or just the text message
                    sendMessage(widget.currentUser, widget.receiverUser,
                        textMessage, imageUrl);
                  }
                : null,
          )
        ],
      ),
    );
  }
}