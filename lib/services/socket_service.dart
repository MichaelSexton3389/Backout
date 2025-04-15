import 'dart:io';
import 'dart:convert';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:BackOut/services/notification_service.dart';
import 'package:BackOut/services/app_lifecycle_manager.dart';
import 'gcs_services.dart';

class SocketService {
  static final SocketService _instance = SocketService._internal();
  late IO.Socket socket;
  bool _isConnected = false;
  String? currentChatReceiverId; // Track which chat the user is currently viewing

  SocketService._internal();
  factory SocketService() {
    return _instance;
  }

  bool get isConnected => _isConnected;

  void connect() {
    if (_isConnected) return;

    socket = IO.io('https://my-backend-service-952120514384.us-central1.run.app', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });

    socket.connect();
    _isConnected = true;

    socket.onConnect((_) {
      print('Connected to Socket.IO server');
    });

    socket.on('receiveMessage', (data) {
      print('New message: $data');
      
      // Handle the message for notifications
      _handleIncomingMessage(data);
    });

    socket.onDisconnect((_) {
      print('Disconnected from server');
      _isConnected = false;
    });
  }

  // Set current chat when user opens a conversation
  void setCurrentChat(String receiverId) {
    currentChatReceiverId = receiverId;
  }

  // Clear current chat when user leaves a conversation
  void clearCurrentChat() {
    currentChatReceiverId = null;
  }

  // Handle incoming messages and show notifications when needed
  void _handleIncomingMessage(dynamic data) {
    // Extract message information
    final sender = data['sender']; // ID of message sender
    final receiver = data['receiver']; // ID of message receiver
    final message = data['message']; // Message text
    final imageUrl = data['imageUrl']; // Optional image URL
    final senderName = data['senderName'] ?? 'New message'; // Name of sender (if available)

    // Generate a unique message ID (if not provided by your backend)
    final messageId = DateTime.now().millisecondsSinceEpoch.toString();
    
    // Determine if we should show a notification:
    // 1. If app is in background, always show notification
    // 2. If the user is not viewing this chat, show notification
    bool shouldShowNotification = 
        !AppLifecycleManagerState.isAppInForeground || 
        currentChatReceiverId != sender;

    if (shouldShowNotification) {
      // Show notification
      NotificationService.showNotification(
        id: messageId.hashCode, // Create a unique notification ID
        title: senderName,
        body: imageUrl != null && imageUrl.isNotEmpty 
            ? 'Sent an image' 
            : message,
        payload: jsonEncode({
          'type': 'chat_message',
          'senderId': sender,
          'messageId': messageId,
        }),
      );
    }
  }

  Future<void> sendMessage(String sender, String receiver, String message, String? imageUrl) async {
    if (!_isConnected) return;

    // Emit the message with or without an image URL
    socket.emit('sendMessage', {
      'sender': sender,
      'receiver': receiver,
      'message': message,
      'imageUrl': imageUrl ?? '', // If no image, send empty string
    });

    print('Message sent: $message');
    if (imageUrl != null) {
      print('Image URL sent: $imageUrl');
    }
  }

  void removeListener() {
    socket.off('receiveMessage');
  }

  void disconnect() {
    if (_isConnected) {
      socket.disconnect();
      _isConnected = false;
    }
  }
}