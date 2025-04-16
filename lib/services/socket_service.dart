import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketService {
    static final SocketService _instance = SocketService._internal();
    late IO.Socket socket;
    bool _isConnected= false;

    SocketService._internal();
    factory SocketService(){
        return _instance;
    }
    bool get isConnected => _isConnected;
  void connect() {
    if(_isConnected) return;
    socket = IO.io('http://localhost:3000', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });

    socket.connect();
    _isConnected= true;

    socket.onConnect((_) {
      print('Connected to Socket.IO server');
    });

    socket.on('receiveMessage', (data) {
        
      print('New message: $data');
    });

    socket.onDisconnect((_) {
         print('Disconnected from server');
        _isConnected=false ;
         });
    }

  void sendMessage(String sender, String receiver, String message, {bool isImage = false}) {
    if (socket != null) {
      socket.emit('message', {
        'sender': sender,
        'receiver': receiver,
        'message': message,
        'isImage': isImage,
      });
    }
  }

  void removeListener(){
    socket.off('recieveMessage');
  }

  void disconnect() {
    if (_isConnected){
    socket.disconnect();
    _isConnected=false;
    }
  }
}