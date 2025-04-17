import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:BackOut/services/socket_service.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
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

  Future<void> fetchMessages() async {
    try {
      final response = await http.get(
        Uri.parse('${Constants.uri}/messages/${widget.currentUser}/${widget.receiverUser}'),
      );

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

    Future.delayed(Duration(seconds: 1), () {
      setState(() {
        _isLoading = false;
      });
    });

    _socketService.socket.on('receiveMessage', (data) {
      if (mounted) {
        bool isDuplicate = messages.any((msg) =>
            msg['message'] == data['message'] && msg['sender'] == data['sender']);
        if (!isDuplicate) {
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

  Future<void> _pickAndSendImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      final bytes = await File(image.path).readAsBytes();
      final base64Image = base64Encode(bytes);

      sendMessage(isImage: true);

      setState(() {
        messages.add({
          'sender': widget.currentUser,
          'message': base64Image,
          'timestamp': DateTime.now().toIso8601String(),
          'isImage': 'true',
        });
      });
    }
  }

  void sendMessage({bool isImage = false}) {
    if (_messageController.text.isNotEmpty || isImage) {
      _socketService.sendMessage(
        widget.currentUser,
        widget.receiverUser,
        _messageController.text,
        isImage: isImage,
      );
      setState(() {
        messages.add({
          'sender': widget.currentUser,
          'message': _messageController.text,
          'timestamp': DateTime.now().toIso8601String(),
          'isImage': isImage.toString(),
        });
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
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF6A1B1A), // Deep red
            Color(0xFF0D3B4C), // Dark bluish
          ],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.white24,
                radius: 18,
                child: Text(
                  widget.receiverUser[0].toUpperCase(),
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(width: 10),
              Text(
                widget.receiverUser,
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
              ),
            ],
          ),
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.more_vert, color: Colors.white),
              onPressed: () {},
            ),
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: _isLoading
                  ? Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : ListView.builder(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        bool isMe = messages[index]['sender'] == widget.currentUser;
                        bool isImage = messages[index]['isImage'] == 'true';
                        
                        return Padding(
                          padding: EdgeInsets.only(bottom: 16),
                          child: Row(
                            mainAxisAlignment: isMe
                                ? MainAxisAlignment.end
                                : MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              if (!isMe)
                                CircleAvatar(
                                  backgroundColor: Colors.white24,
                                  radius: 16,
                                  child: Text(
                                    messages[index]['sender']![0].toUpperCase(),
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              if (!isMe) SizedBox(width: 8),
                              
                              // Message bubble
                              Flexible(
                                child: Container(
                                  constraints: BoxConstraints(
                                    maxWidth: MediaQuery.of(context).size.width * 0.75,
                                  ),
                                  padding: isImage
                                      ? EdgeInsets.all(4)
                                      : EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 12,
                                        ),
                                  decoration: BoxDecoration(
                                    color: isMe
                                        ? Colors.white.withOpacity(0.2)
                                        : Colors.white.withOpacity(0.1),
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(18),
                                      topRight: Radius.circular(18),
                                      bottomLeft: isMe
                                          ? Radius.circular(18)
                                          : Radius.circular(4),
                                      bottomRight: isMe
                                          ? Radius.circular(4)
                                          : Radius.circular(18),
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.05),
                                        blurRadius: 5,
                                        offset: Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: isImage
                                      ? ClipRRect(
                                          borderRadius: BorderRadius.circular(14),
                                          child: Image.memory(
                                            base64Decode(messages[index]['message']!),
                                            fit: BoxFit.cover,
                                          ),
                                        )
                                      : Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              messages[index]['message']!,
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 15,
                                              ),
                                            ),
                                            SizedBox(height: 4),
                                            Text(
                                              DateFormat('h:mm a').format(
                                                DateTime.parse(
                                                  messages[index]['timestamp']!,
                                                ),
                                              ),
                                              style: TextStyle(
                                                fontSize: 10,
                                                color: Colors.white70,
                                              ),
                                            ),
                                          ],
                                        ),
                                ),
                              ),
                              
                              if (isMe) SizedBox(width: 8),
                              if (isMe)
                                CircleAvatar(
                                  backgroundColor: Colors.white24,
                                  radius: 16,
                                  child: Text(
                                    messages[index]['sender']![0].toUpperCase(),
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
            
            // Typing indicator
            if (_isTyping)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                alignment: Alignment.centerLeft,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white10,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 36,
                        child: Stack(
                          children: [
                            _buildDot(0, 1.0),
                            _buildDot(12, 1.5),
                            _buildDot(24, 1.0),
                          ],
                        ),
                      ),
                      Text(
                        "typing...",
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            
            // Message input
            Container(
              margin: EdgeInsets.all(12),
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.image_outlined, color: Colors.white70),
                    onPressed: _pickAndSendImage,
                  ),
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      onChanged: (text) {
                        setState(() {
                          _canSendMessage = text.isNotEmpty;
                        });
                      },
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: "Type a message...",
                        hintStyle: TextStyle(color: Colors.white54),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 12),
                      ),
                    ),
                  ),
                  SizedBox(width: 4),
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: _canSendMessage ? Colors.white24 : Colors.transparent,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: Icon(
                        Icons.send_rounded,
                        size: 20,
                        color: _canSendMessage ? Colors.white : Colors.white38,
                      ),
                      onPressed: _canSendMessage ? () => sendMessage() : null,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildDot(double leftPosition, double scale) {
    return Positioned(
      left: leftPosition,
      child: Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(
          color: Colors.white70,
          shape: BoxShape.circle,
        ),
        child: AnimatedScale(
          scale: scale,
          duration: Duration(milliseconds: 600),
          curve: Curves.easeInOut,
        ),
      ),
    );
  }
}