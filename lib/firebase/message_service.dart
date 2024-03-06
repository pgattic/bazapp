import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MessageService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> sendMessage(Message message) async {
    await _firestore.collection('messages').add({
      'senderId': message.senderId,
      'recipientId': message.recipientId,
      'text': message.text,
      'timestamp': message.timestamp,
      'read':
          false, // Add a 'read' field to track whether the message has been read
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

  Stream<List<Message>> getChatMessages(
      String currentUserId, String otherUserId) {
    String chatId = _generateChatId(currentUserId, otherUserId);

    return _firestore
        .collection('messages')
        .where('chatId', isEqualTo: chatId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .where((doc) =>
              doc['senderId'] != null &&
              doc['recipientId'] != null &&
              doc['text'] != null &&
              doc['timestamp'] != null)
          .map((doc) {
        return Message(
          senderId: doc['senderId'],
          recipientId: doc['recipientId'],
          text: doc['text'],
          timestamp: (doc['timestamp'] as Timestamp).toDate(),
          read: false,
        );
      }).toList();
    });
  }

  String _generateChatId(String userId1, String userId2) {
    List<String> userIds = [userId1, userId2];
    userIds.sort();
    return userIds.join('_');
  }

  Future<void> markAsRead(String messageId) async {
    await _firestore.collection('messages').doc(messageId).update({
      'read': true,
    });
  }

  Stream<List<String>> getRecentChats(String currentUserId) {
    return _firestore
        .collection('messages')
        .where('senderId', isEqualTo: currentUserId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      final recentChats = <String>[];
      for (final doc in snapshot.docs) {
        final recipientId = doc['recipientId'] as String;
        if (!recentChats.contains(recipientId)) {
          recentChats.add(recipientId);
        }
      }
      return recentChats;
    });
  }
}

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
