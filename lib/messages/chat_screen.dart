import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class Message {
  final String senderId;
  final String recipientId;
  final String text;
  final DateTime timestamp;
  final bool read; // Added 'read' field

  Message({
    required this.senderId,
    required this.recipientId,
    required this.text,
    required this.timestamp,
    required this.read,
  });
}

class MessageService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> sendMessage(Message message, String chatId) async {
    try {
      await _firestore.collection('messages').add({
        'senderId': message.senderId,
        'recipientId': message.recipientId,
        'text': message.text,
        'timestamp': message.timestamp,
        'chatId': chatId = _generateChatId(message.senderId, message.recipientId),
        'read': false,
      });
    } catch (e) {
      print('Error sending message: $e');
    }
  }

Stream<QuerySnapshot> getChatMessages(String chatId) {
  return _firestore
      .collection('messages')
      .where('chatId', isEqualTo: chatId) // Query messages by chatId
      .orderBy('timestamp', descending: false)
      .snapshots();
}

  String? getCurrentUserId() {
    final user = FirebaseAuth.instance.currentUser;
    return user?.uid;
  }

  Future<String?> getDisplayNameByUserId(String? userId) async {
    try {
      DocumentSnapshot userSnapshot =
          await _firestore.collection('users').doc(userId).get();

      if (userSnapshot.exists) {
        // Return the display name of the user with the given UID
        return userSnapshot['displayName'] as String?;
      } else {
        // Return null if no user is found with the given UID
        return null;
      }
    } catch (e) {
      // Handle errors, such as Firestore query errors
      print('Error getting display name by user ID: $e');
      return null;
    }
  }

  Future<String?> getUserIdByDisplayName(String displayName) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('users')
          .where('displayName', isEqualTo: displayName)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        // Return the UID of the first user found with the given display name
        return querySnapshot.docs.first.id;
      } else {
        // Return null if no user is found with the given display name
        return null;
      }
    } catch (e) {
      // Handle errors, such as Firestore query errors
      print('Error getting user ID by display name: $e');
      return null;
    }
  }

String _generateChatId(String? userId1, String? userId2) {
  // Sort user IDs alphabetically
  List<String?> userIds = [userId1, userId2];
  userIds.sort();

  // Concatenate sorted user IDs to generate chat ID
  return '${userIds[0]}${userIds[1]}';
}


  Future<void> markAsRead(String messageId) async {
    await _firestore.collection('messages').doc(messageId).update({
      'read': true,
    });
  }

  Future<void> _updateChatInfo(
      String? userId, String? otherUserId, String chatId) async {
    String otherUserDisplayName =
        await getDisplayNameByUserId(otherUserId) ?? 'Unknown User';

    // Update user's chats map
    await _firestore.collection('users').doc(userId).update({
      'chats.$otherUserId.chatId': chatId,
      'chats.$otherUserId.otherUserId': otherUserId,
    });
  }

  Stream<List<String>> getUsersByDisplayName([String? displayName]) {
    if (displayName == null || displayName.isEmpty) {
      // Return all users when displayName is null or empty
      return _firestore.collection('users').snapshots().map((snapshot) {
        return snapshot.docs.map((doc) {
          return doc['displayName'] as String;
        }).toList();
      });
    } else {
      // Return filtered users based on displayName
      return _firestore
          .collection('users')
          .where('displayName', isGreaterThanOrEqualTo: displayName)
          .where('displayName', isLessThan: displayName + 'z')
          .snapshots()
          .map((snapshot) {
        return snapshot.docs.map((doc) {
          return doc['displayName'] as String;
        }).toList();
      });
    }
  }

  Stream<List<String>> getRecentChats(String? userId) {
    return _firestore
        .collection('chats')
        .where('senderId', isGreaterThanOrEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      List<String> recentChats = [];

      for (QueryDocumentSnapshot chat in snapshot.docs) {
        String chatId = chat['chatId'] as String;

        // Extract the other user ID from the chatId
        String otherUserId = chatId.replaceAll(userId!, '');
        recentChats.add(otherUserId);
      }

      return recentChats;
    });
  }
}

class ChatScreen extends StatefulWidget {
  final String recipientUid;

  ChatScreen({
    required this.recipientUid,
  });

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late ScrollController _scrollController;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _messageController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  String? chatId;
  List<Map<String, dynamic>> _chatMessages = [];
  late StreamSubscription<QuerySnapshot<Map<String, dynamic>>> _messagesStream;

  @override
  void initState() {
    super.initState();
    final user = _auth.currentUser;
    _scrollController = ScrollController();
    if (user != null) {
      final currentUserUid = user.uid;
      chatId = currentUserUid.hashCode <= widget.recipientUid.hashCode
          ? '$currentUserUid${widget.recipientUid}'
          : '${widget.recipientUid}$currentUserUid';

      // Start listening for new messages
      _messagesStream = _firestore
          .collection('messages')
          .where('chatId', isEqualTo: chatId)
          .orderBy('timestamp', descending: false)
          .snapshots()
          .listen((snapshot) {
        snapshot.docChanges.forEach((change) {
          if (change.type == DocumentChangeType.added) {
            final message = change.doc.data();
            // Add the message to the list
            setState(() {
              _chatMessages.add(message!);
            });
            // Trigger a notification for the new message
            _showNotification(message?['text'] as String);
          }
        });
        WidgetsBinding.instance.addPostFrameCallback((_) { // Scroll to the bottom of the conversation on ever update and at the beginning
          _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
        });
      });
    }
  }




  @override
  void dispose() {
    _scrollController.dispose();
    _messagesStream.cancel(); // Cancel the stream subscription
    super.dispose();
  }

  void _showNotification(String message) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'your channel id',
      'your channel name',
      importance: Importance.max,
      priority: Priority.high,
    );
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
      0,
      'New Message',
      message,
      platformChannelSpecifics,
      payload: 'item x',
    );
  }

  Future<void> _sendMessage(String text) async {
    try {
      await _firestore.collection('messages').add({
        'senderId': _auth.currentUser!.uid,
        'recipientId': widget.recipientUid,
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
        title: Text('Chat Screen'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: _chatMessages.length,
              itemBuilder: (context, index) {
                final message = _chatMessages[index];
                final isCurrentUser =
                    message['senderId'] == _auth.currentUser!.uid;
                final [bubbleColor, textColor] =
                  isCurrentUser ? [
                    Colors.blue,
                    Colors.white,
                  ] : [
                    const Color(0xFFDDDDDD),
                    Colors.black,
                  ];
                final padding = isCurrentUser ? const EdgeInsets.fromLTRB(72.0, 1.0, 8.0, 1.0) : const EdgeInsets.fromLTRB(8.0, 1.0, 72.0, 1.0);

                return Align(
                  alignment: isCurrentUser
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Padding(
                    padding: padding,
                    child: Container(
                      decoration: BoxDecoration(
                        color: bubbleColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                      child: Text(
                        message['text'] as String,
                        style: TextStyle(fontSize: 16, color: textColor),
                      ),
                    ),
                  ),
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
                    constraints: BoxConstraints(maxHeight: 100),
                    child: TextField(
                      textInputAction: TextInputAction.send,
                      maxLines: null, // Limit to 5 lines
                      scrollPhysics: BouncingScrollPhysics(),
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: 'Type a message',
                      ),
                      onSubmitted: (text) {
                        if (text.isNotEmpty) {
                          _sendMessage(text);
                          _messageController.clear();
                        }
                      },
                      onTap: () async {
                        await Future.delayed(const Duration(milliseconds: 400));
                        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
                      },
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    final text = _messageController.text.trim();
                    if (text.isNotEmpty) {
                      _sendMessage(text);
                      _messageController.clear();
                    }
                  },
                  child: Text('Send'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
