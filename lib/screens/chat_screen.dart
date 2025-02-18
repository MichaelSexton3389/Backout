import 'package:flutter/material.dart';
import 'package:BackOut/services/socket_service.dart';
import 'package:intl/intl.dart'; // For formatting timestamps
import 'package:http/http.dart' as http;
import 'package:BackOut/services/socket_service.dart';
import 'dart:convert';

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
    Future<void> fetchMessages() async {
        try {
            final response = await http.get(Uri.parse(
                'http://localhost:3000/messages/${widget.currentUser}/${widget.receiverUser}'));

            if (response.statusCode == 200) {
            List<dynamic> messagesJson = json.decode(response.body);
            setState(() {
                messages = messagesJson.map((msg) => {
                    'sender': msg['sender'].toString(),
                    'message': msg['message'].toString(),
                    'timestamp': msg['timestamp'].toString(),
                    }).toList();
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
  @override
  void initState() {
    super.initState();
    fetchMessages();
    if (!_socketService.isConnected) {
      _socketService.connect();
    }

    // Fetch existing messages (simulating a delay for loading)
    Future.delayed(Duration(seconds: 1), () {
      setState(() {
        _isLoading = false;
      });
    });



    _socketService.socket.on('receiveMessage', (data) {
      if (mounted) {
    bool isDuplicate = messages.any((msg) => msg['message'] == data['message'] && msg['sender'] == data['sender']);
    if (!isDuplicate) { // ✅ Prevent duplicate messages
      setState(() {
        messages.add({
          'sender': data['sender'],
          'message': data['message'],
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

  void sendMessage() {
    if (_messageController.text.isNotEmpty) {
      _socketService.sendMessage(widget.currentUser, widget.receiverUser, _messageController.text);
      setState(() {
        // messages.add({
        //   'sender': widget.currentUser,
        //   'message': _messageController.text,
        //   'timestamp': DateTime.now().toIso8601String(),
        // });
        _canSendMessage = false;
      });
      _messageController.clear();
    }
  }

  @override
  void dispose() {
    print("🚀 ChatScreen dispose() called!");
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
                ? Center(child: CircularProgressIndicator()) // Show loading indicator
                : ListView.builder(
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      bool isMe = messages[index]['sender'] == widget.currentUser;
                      return Row(
                        mainAxisAlignment:
                            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
                        children: [
                          if (!isMe) // Show initials for received messages
                            CircleAvatar(
                              backgroundColor: Colors.blueGrey,
                              child: Text(
                                messages[index]['sender']![0].toUpperCase(),
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          SizedBox(width: isMe ? 0 : 6), // Spacing for received messages
                          Container(
                            margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isMe ? Colors.blueAccent : Colors.grey[300],
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(12),
                                topRight: Radius.circular(12),
                                bottomLeft: isMe ? Radius.circular(12) : Radius.zero,
                                bottomRight: isMe ? Radius.zero : Radius.circular(12),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  messages[index]['message']!,
                                  style: TextStyle(
                                    color: isMe ? Colors.white : Colors.black,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  DateFormat('h:mm a').format(
                                    DateTime.parse(messages[index]['timestamp']!),
                                  ), // Format time to "10:30 AM"
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: isMe ? Colors.white70 : Colors.black54,
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
          if (_isTyping) // Show "User is typing..." indicator
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
          Expanded(
            child: TextField(
              controller: _messageController,
              onChanged: (text) {
                setState(() {
                  _canSendMessage = text.isNotEmpty;
                });
              },
              decoration: InputDecoration(
                hintText: "Enter message...",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[200],
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              ),
            ),
          ),
          
          SizedBox(width: 8),
          IconButton(
            icon: Icon(Icons.send,
                color: _canSendMessage ? Colors.blueAccent : Colors.grey),
            onPressed: _canSendMessage ? sendMessage : null,
          ),
        ],
      ),
    );
  }
}