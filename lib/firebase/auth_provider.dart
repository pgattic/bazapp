import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  User? _user;

  User? get user => _user;

  // Sign-up function
  // Updated signUp function
  Future<void> signUp(
      {required String email,
      required String password,
      required String displayName}) async {
    try {
      final authResult = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      final user = authResult.user;

      if (user != null) {
        // Update user display name
        await user.updateDisplayName(displayName);

        // Assign a generic example icon URL
        const String genericIconUrl = 'https://example.com/generic-icon.png';

        // Create a user document in Firestore with the generic icon URL
        await _firestore.collection('users').doc(user.uid).set({
          'email': email,
          'displayName': displayName,
          'icon': genericIconUrl,
        });

        _user = User(
            uid: user.uid,
            email: email,
            displayName: displayName,
            icon: genericIconUrl,
            eventIds: []); // Assign the generic icon URL
        notifyListeners();
      }
    } catch (e) {
      // Handle sign-up errors
      // ignore: avoid_print
      print(e);
    }
  }

  // Sign out function
  Future<void> signOut() async {
    await _auth.signOut();
    _user = null;
    notifyListeners();
  }

  Future<void> login({required String email, required String password}) async {
    try {
      final authResult = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      final user = authResult.user;

      if (user != null) {
        _user = User(
          uid: user.uid,
          email: email,
          displayName:
              user.displayName ?? '', // You can handle null display name
          icon: '', // You can assign an icon if needed
          eventIds: [], // You can assign event IDs if needed
        );
        notifyListeners();
        print('Login successful');
      }
    } catch (e) {
      // Handle login errors based on Firebase Auth error codes
      if (e is FirebaseAuthException) {
        if (e.code == 'user-not-found') {
          print('No user found with this email');
          // You can show a corresponding error message
        } else if (e.code == 'wrong-password') {
          print('Incorrect password');
          // You can show a corresponding error message
        } else {
          print('Login error: ${e.code}');
          // Handle other error scenarios
        }
      } else {
        print('Login error: $e');
        // Handle other types of exceptions
      }
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      // Password reset email sent successfully
    } catch (e) {
      throw e; // Handle or rethrow the error as needed
    }
  }

  void setUserIconURL(String iconURL, context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;
    user?.icon = iconURL;
  }

  Future<bool> isLoggedIn() async {
    final user = FirebaseAuth.instance.currentUser;
    return user != null;
  }

  static of(BuildContext context) {}
}

class User {
  String uid;
  String email;
  String displayName;
  String icon;
  List<String> eventIds;

  User({
    required this.uid,
    required this.email,
    required this.displayName,
    required this.icon,
    required this.eventIds,
  });

  setEventIds(List<String> eventIds, {required String value}) {
    eventIds.add(value);
  }

  iconURL({required String newIconURL}) {
    icon = newIconURL;
  }
}

class Message {
  final String? senderId;
  final String? recipientId;
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
    List<String?> userIds = [userId1, userId2];
    userIds.sort();
    return userIds.join('_');
  }

  Future<void> markAsRead(String messageId) async {
    await _firestore.collection('messages').doc(messageId).update({
      'read': true,
    });
  }

  Future<void> sendMessage(Message message) async {
    String chatId = _generateChatId(message.senderId, message.recipientId);

    await _firestore.collection('messages').add({
      'chatId': chatId, // Use the generated chat ID
      'senderId': message.senderId,
      'recipientId': message.recipientId,
      'text': message.text,
      'timestamp': message.timestamp,
      'read': false,
    });
  }

  Stream<List<Message>> getChatMessages(String? chatId, String? otherUserId) {
    return _firestore
        .collection('messages')
        .where('chatId', isEqualTo: chatId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Message(
          senderId: doc['senderId'] as String,
          recipientId: doc['recipientId'] as String,
          text: doc['text'] as String,
          timestamp: (doc['timestamp'] as Timestamp).toDate(),
          read: doc['read'] as bool,
        );
      }).toList();
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
        .where('chatId',
            isGreaterThanOrEqualTo: userId) // Use >= for the chatId
        .where('chatId', isLessThan: userId! + 'z') // Use < for the chatId
        .snapshots()
        .map((snapshot) {
      List<String> recentChats = [];

      for (QueryDocumentSnapshot chat in snapshot.docs) {
        String chatId = chat['chatId'] as String;

        // Extract the other user ID from the chatId
        String otherUserId = chatId.replaceAll(userId!, '');

        // Fetch and add the display name of the other user
        MessageService()
            .getDisplayNameByUserId(otherUserId)
            .then((displayName) {
          recentChats.add(displayName!);
        });
      }

      return recentChats;
    });
  }
}

class Event {
  final String eventId;
  final String title;
  final DateTime dateTime;
  final String description;
  final String eventType;
  final double latitude;
  final double longitude;
  final String userId;

  Event({
    required this.eventId,
    required this.title,
    required this.dateTime,
    required this.description,
    required this.eventType,
    required this.latitude,
    required this.longitude,
    required this.userId,
  });

  // Convert Event to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'eventId': eventId,
      'title': title,
      'dateTime': dateTime,
      'description': description,
      'latitude': latitude,
      'longitude': longitude,
      'eventType': eventType,
      'userId': userId,
    };
  }
}

String _formatDateTime(DateTime dateTime) {
  final formattedDate = DateFormat.yMMMMd(dateTime);
  return formattedDate;
}

class DateFormat {
  static String yMMMMd(DateTime dateTime) {
    final months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    final day = dateTime.day;
    final month = months[dateTime.month - 1];
    final year = dateTime.year;
    final hour = dateTime.hour;
    final minute = dateTime.minute;

    return '$month $day, $year at $hour:$minute';
  }
}
