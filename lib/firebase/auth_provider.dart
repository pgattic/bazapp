import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_storage/firebase_storage.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  User? _user;

  User? get user => _user;

  Future<void> addEvent(Event event) async {
    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        throw Exception('User not logged in');
      }

      // Add event to Firestore
      await FirebaseFirestore.instance.collection('events').add(event.toMap());

      // Add event ID to user's eventIds list
      _user?.eventIds.add(event.eventId);
      notifyListeners();
    } catch (e) {
      throw e;
    }
  }

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
            eventIds: [], // Assign the generic icon URL
            chats: []);
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
            chats: []);
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

  Future<String> uploadProfilePicture(File imageFile) async {
    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        throw Exception('User not logged in');
      }

      final storageRef = FirebaseStorage.instance
          .ref()
          .child('profile_pictures/${user.uid}.jpg');
      await storageRef.putFile(imageFile);
      final downloadUrl = await storageRef.getDownloadURL();

      // Update user's icon in Firestore
      await _firestore.collection('users').doc(user.uid).update({
        'icon': downloadUrl,
      });

      // Update local user object
      _user?.icon = downloadUrl;
      notifyListeners();

      return downloadUrl;
    } catch (e) {
      throw e;
    }
  }

  // Update user profile information
  Future<void> updateUserProfile(String profilePictureUrl) async {
    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        throw Exception('User not logged in');
      }

      // Update user's display name and profile picture URL
      await user.updateDisplayName(
          _user?.displayName ?? ''); // You can pass the display name
      await user.updatePhotoURL(profilePictureUrl);

      // Update user document in Firestore
      await _firestore.collection('users').doc(user.uid).update({
        'displayName': _user?.displayName ?? '',
        'icon': profilePictureUrl,
      });

      // Update local user object
      _user?.displayName = _user?.displayName ?? '';
      _user?.icon = profilePictureUrl;
      notifyListeners();
    } catch (e) {
      throw e;
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
  List<String> chats; // Change this to a List<String>

  User({
    required this.uid,
    required this.email,
    required this.displayName,
    required this.icon,
    required this.eventIds,
    List<String>? chats, // Change the type here
  }) : chats = chats ?? [];

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

class Event {
  final String eventId;
  final String title;
  final DateTime dateTime;
  final String description;
  final String eventType;
  final double latitude;
  final double longitude;
  final String userId;
  final String color;
  final String createdFlag;
  final String followedFlag;

  Event({
    required this.eventId,
    required this.title,
    required this.dateTime,
    required this.description,
    required this.eventType,
    required this.latitude,
    required this.longitude,
    required this.userId,
    required this.color,
    required this.createdFlag,
    required this.followedFlag,
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
      'color': color,
      'createdFlag': createdFlag,
      'followedFlag': followedFlag
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
