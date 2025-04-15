import 'package:flutter/material.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_firebase_chat_core/flutter_firebase_chat_core.dart';
import 'package:uuid/uuid.dart';

class FirebaseChatScreen extends StatefulWidget {
  final types.User peerUser;

  const FirebaseChatScreen({Key? key, required this.peerUser}) : super(key: key);

  @override
  State<FirebaseChatScreen> createState() => _FirebaseChatScreenState();
}

class _FirebaseChatScreenState extends State<FirebaseChatScreen> {
  late types.Room room;
  late types.User currentUser;

  @override
  void initState() {
    super.initState();
    currentUser = types.User(
      id: FirebaseChatCore.instance.firebaseUser?.uid ?? '',
    );
    _createOrGetRoom();
  }

  Future<void> _createOrGetRoom() async {
    final createdRoom = await FirebaseChatCore.instance.createRoom(widget.peerUser);
    setState(() {
      room = createdRoom;
    });
  }

  void _handleSendPressed(types.PartialText message) {
    final textMessage = types.TextMessage(
      author: currentUser,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      id: const Uuid().v4(),
      text: message.text,
    );

    FirebaseChatCore.instance.sendMessage(textMessage, room.id);
  }

  @override
  Widget build(BuildContext context) {
    if (room == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.peerUser.firstName ?? 'Chat'),
      ),
      body: StreamBuilder<List<types.Message>>(
        stream: FirebaseChatCore.instance.messages(room),
        initialData: const [],
        builder: (context, snapshot) {
          return Chat(
            messages: snapshot.data ?? [],
            onSendPressed: _handleSendPressed,
            user: currentUser,
          );
        },
      ),
    );
  }
}
