import 'dart:async';
import 'package:bazapp/firebase/auth_provider.dart';
import 'package:bazapp/messages/text_message.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class ChatScreen extends StatefulWidget {
  final BZUser recipient;

  const ChatScreen({super.key, required this.recipient});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _messageController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  String? chatId;
  final List<Map<String, dynamic>> _chatMessages = [];
  late StreamSubscription<QuerySnapshot<Map<String, dynamic>>> _messagesStream;

  @override
  void initState() {
    super.initState();
    final user = _auth.currentUser;
    if (user != null) {
      final currentUserUid = user.uid;
      chatId = currentUserUid.hashCode <= widget.recipient.uid.hashCode
          ? '$currentUserUid${widget.recipient.uid}'
          : '${widget.recipient.uid}$currentUserUid';

      // Start listening for new messages
      _messagesStream = _firestore
          .collection('messages')
          .where('chatId', isEqualTo: chatId)
          .orderBy('timestamp', descending: false)
          .snapshots()
          .listen((snapshot) {
        for (var change in snapshot.docChanges) {
          if (change.type == DocumentChangeType.added) {
            final message = change.doc.data()!;
            // Add the message to the list
            setState(() {
              _chatMessages.add(message);
              _chatMessages.sort((a, b) => b['timestamp']
                  .compareTo(a['timestamp'])); // Sort messages by timestamp
            });
            // Trigger a notification for the new message
            // _showNotification(message?['text'] as String);
          }
        }
      });
    }
  }

  @override
  void dispose() {
    _messagesStream.cancel(); // Cancel the stream subscription
    super.dispose();
  }

  Future<void> _sendMessage(String text) async {
    try {
      await _firestore.collection('messages').add({
        'senderId': _auth.currentUser!.uid,
        'recipientId': widget.recipient.uid,
        'text': text,
        'timestamp': DateTime.now(),
        'chatId': chatId,
        'read': false,
      });
    } catch (e) {
      print('Error sending message: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Chat with ${widget.recipient.displayName}"),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              reverse: true,
              itemCount: _chatMessages.length,
              itemBuilder: (context, index) {
                final message = _chatMessages[index];
                final previousMessage = index < (_chatMessages.length - 1)
                    ? _chatMessages[index + 1]
                    : null;
                final isCurrentUser =
                    message['senderId'] == _auth.currentUser!.uid;
                final GapType gapType = previousMessage == null ? GapType.showDate : GapType.getGapType(
                    (message['timestamp'] as Timestamp).toDate(),
                    (previousMessage['timestamp'] as Timestamp).toDate());
                return TextMessage(
                  message['text'] as String,
                  (message['timestamp'] as Timestamp).toDate(),
                  isCurrentUser,
                  gapType,
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 100),
                    child: TextField(
                      textCapitalization: TextCapitalization.sentences,
                      textInputAction: TextInputAction.send,
                      maxLines: null, // Limit to 5 lines
                      scrollPhysics: const BouncingScrollPhysics(),
                      controller: _messageController,
                      decoration: const InputDecoration(
                        hintText: 'Type a message',
                      ),
                      onSubmitted: (text) {
                        if (text.isNotEmpty) {
                          _sendMessage(text);
                          _messageController.clear();
                        }
                      },
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    final text = _messageController.text.trim();
                    if (text.isNotEmpty) {
                      _sendMessage(text);
                      _messageController.clear();
                    }
                  },
                  icon: Icon(Icons.send),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
