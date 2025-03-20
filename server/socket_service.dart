import 'dart:io';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../lib/services/gcs_services.dart';
class SocketService {
  static final SocketService _instance = SocketService._internal();
  late IO.Socket socket;
  bool _isConnected = false;

  SocketService._internal();
  factory SocketService() {
    return _instance;
  }

  bool get isConnected => _isConnected;

  void connect() {
    if (_isConnected) return;

    socket = IO.io('http://localhost:3000', <String, dynamic>{
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
    });

    socket.onDisconnect((_) {
      print('Disconnected from server');
      _isConnected = false;
    });
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
