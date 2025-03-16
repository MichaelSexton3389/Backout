import 'dart:io';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'gcs_services.dart';

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

  /// Send a text message
  void sendMessage(String sender, String receiver, String message) {
    if (!_isConnected) return;
    socket.emit('sendMessage', {
      'sender': sender,
      'receiver': receiver,
      'message': message,
      'imageUrl': null, // Text-only message
    });
  }

  /// Send an image message
  Future<void> sendImageMessage(String sender, String receiver, File imageFile) async {
    if (!_isConnected) return;

    String? imageUrl = await GCSService.uploadImageToGCS(imageFile);

    if (imageUrl != null) {
      socket.emit('sendMessage', {
        'sender': sender,
        'receiver': receiver,
        'message': null, // No text, just an image
        'imageUrl': imageUrl,
      });
    } else {
      print("Failed to upload image");
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
