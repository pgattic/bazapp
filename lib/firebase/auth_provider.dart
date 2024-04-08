import 'dart:io';
import 'package:bazapp/event/event.dart';
import 'package:bazapp/event/event_type.dart';
import 'package:bazapp/planner/planner_view.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:firebase_storage/firebase_storage.dart';

class BZAuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  User? _user;
  UserPreferences? _userPreferences;

  User? get user => _user;
  UserPreferences? get userPreferences => _userPreferences;
  Future<String?> getuser() async{
    return FirebaseAuth.instance.currentUser?.uid;
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
          'photoURL': genericIconUrl,
        });

        // Add user-prefs to Firestore
        await _firestore.collection('user-prefs').doc(user.uid).set({
          'is-dark-mode': false,
          'calendar-view': 'day',
        });

        _user = User(
          uid: user.uid,
          email: email,
          displayName: displayName,
          icon: genericIconUrl,
        );
        
        _userPreferences = UserPreferences(
          isDarkMode: false,
          calendarViewType: CalendarViewType.day,
        );
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
    _userPreferences = null;
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
          icon: user.photoURL ?? '', // You can assign an icon if needed
        );
        final doc = await _firestore.collection('user-prefs').doc(user.uid).get();
        _userPreferences = UserPreferences(
          calendarViewType: CalendarViewType.fromString(doc['calendar-view'] as String),
          isDarkMode: doc['is-dark-mode'] as bool
        );
        notifyListeners();
        print('Login successful');
      }
    } catch (e) {
      // Handle login errors based on Firebase Auth error codes
      if (e is FirebaseAuthException) {
        if (e.code == 'invalid-email') {
          Fluttertoast.showToast(msg: 'No user found with this email');
          // You can show a corresponding error message
        } else if (e.code == 'invalid-credential') {
          Fluttertoast.showToast(msg: 'Incorrect password');
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
        'photoURL': downloadUrl,
      });

      // Update local user object
      _user?.icon = downloadUrl;
      notifyListeners();

      return downloadUrl;
    } catch (e) {
      throw e;
    }
  }

  Future<void> updateUserPrefs(UserPreferences userPrefs) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('User not logged in');
      }
      await _firestore.collection('user-prefs').doc(user.uid).update({
        'calendar-view': userPrefs.calendarViewType.toString(),
        'is-dark-mode': userPrefs.isDarkMode
      });
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
    final authProvider = Provider.of<BZAuthProvider>(context);
    final user = authProvider.user;
    user?.icon = iconURL;
  }

  Future<bool> isLoggedIn() async {
    final user = FirebaseAuth.instance.currentUser;
    return user != null;
  }

  // EVENT-RELATED FUNCTIONS

  Future<void> addEvent(CustomEvent event) async {
    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        throw Exception('User not logged in');
      }
      final eventToAdd = event.toDBEvent(userId: user.uid);

      // Add event to Firestore
      await FirebaseFirestore.instance.collection('events').add(eventToAdd.toMap());

      notifyListeners();
    } catch (e) {
      throw e;
    }
  }

  Future<void> removeEvent(String eventId) async {
    try {
      // Remove the event
      await _firestore.collection('events').doc(eventId).delete();
      
      // Also remove event subscriptions tied to the event
      await FirebaseFirestore.instance
          .collection('event-subscriptions')
          .where('event-id', isEqualTo: eventId)
          .get()
          .then((QuerySnapshot querySnapshot) {
            for (var doc in querySnapshot.docs) {
              doc.reference.delete();
            }
          });
      
      notifyListeners();
    } catch (e) {
      throw e;
    }
  }

  Future<List<CustomEvent>> getAllEvents() async {
    try {
      QuerySnapshot<Map<String, dynamic>> snapshot =
          await _firestore.collection('events').get();

      List<CustomEvent> events = [];

      for (var doc in snapshot.docs) {
        Map<String, dynamic> data = doc.data();
        String eventId = doc.id;
        final Timestamp timestamp = data['dateTime'];

        CustomEvent event = CustomEvent(
          LatLng(data['latitude']?? 0.0, data['longitude']?? 0.0),
          timestamp.toDate(),
          data['title'] ?? '',
          data['description'] ?? '',
          EventType.fromString(data['eventType']??''),
          eventId,
          data['userId'],
        );

        events.add(event);
      }

      return events;
    } catch (e) {
      throw e;
    }
  }

  Future<List<CustomEvent>> getOwnedEvents() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('User not logged in');
      }
      QuerySnapshot<Map<String, dynamic>> snapshot = await _firestore
          .collection('events')
          .where('userId', isEqualTo: user.uid)
          .get();

      List<CustomEvent> events = [];

      for (var doc in snapshot.docs) {
        Map<String, dynamic> data = doc.data();
        String eventId = doc.id;
        final Timestamp timestamp = data['dateTime'];

        CustomEvent event = CustomEvent(
          LatLng(data['latitude']?? 0.0, data['longitude']?? 0.0),
          timestamp.toDate(),
          data['title'] ?? '',
          data['description'] ?? '',
          EventType.fromString(data['eventType']??''),
          eventId,
          data['userId'],
        );
        events.add(event);
      }
      return events;
    } catch (e) {
      throw e;
    }
  }

  Future<List<CustomEvent>> getFeedEvents() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('User not logged in');
      }
      final subbedEvents = await getSubscribedEventsByUserId(user.uid);
      final userEvents = await getOwnedEvents();
      // merge subbed events and user events
      final result = subbedEvents + userEvents;
      // sort by date
      result.sort((a, b) => a.dateTime.compareTo(b.dateTime));
      // remove events that are yesterday or before
      result.removeWhere((event) => event.dateTime.isBefore(DateTime.now().subtract(Duration(days: 1))));
      
      return result;
    } catch (e) {
      throw e;
    }
  }

  Future<List<CustomEvent>> getCalendarEvents() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('User not logged in');
      }
      final subbedEvents = await getSubscribedEventsByUserId(user.uid);
      final userEvents = await getOwnedEvents();
      // merge subbed events and user events
      final result = subbedEvents + userEvents;
      return result;
    } catch (e) {
      throw e;
    }
  }

  Future<void> subscribeToEvent(String userId, String eventId) async {
    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        throw Exception('User not logged in');
      }

      final Map<String, dynamic> subscription = {
        'user-id': userId,
        'event-id': eventId,
      };

      // Add event to Firestore
      await FirebaseFirestore.instance.collection('event-subscriptions').add(subscription);

      notifyListeners();
    } catch (e) {
      throw e;
    }
  }

  Future<void> unsubscribeFromEvent(String userId, String eventId) async {
    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        throw Exception('User not logged in');
      }

      // Remove subscriptions from Firestore
      await FirebaseFirestore.instance
          .collection('event-subscriptions')
          .where('user-id', isEqualTo: userId)
          .where('event-id', isEqualTo: eventId)
          .get()
          .then((QuerySnapshot querySnapshot) {
            for (var doc in querySnapshot.docs) {
              doc.reference.delete();
            }
          });

      notifyListeners();
    } catch (e) {
      throw e;
    }
  }

  Future<List<EventSubscription>> getEventSubscriptionsByUserId(String userId) async {
    try {
      QuerySnapshot<Map<String, dynamic>> snapshot = await _firestore
          .collection('event-subscriptions')
          .where("user-id", isEqualTo: userId)
          .get();

      List<EventSubscription> subs = [];

      for (var doc in snapshot.docs) {
        Map<String, dynamic> data = doc.data();
        String subscriptionId = doc.id;

        EventSubscription sub = EventSubscription(
          id: subscriptionId,
          eventId: data['event-id'] ?? '',
          userId: data['user-id'] ?? '',
        );
        subs.add(sub);
      }
      return subs;
    } catch (e) {
      rethrow;
    }
  }

  Future<List<EventSubscription>> getEventSubscriptionsByEventId(String eventId) async {
    try {
      QuerySnapshot<Map<String, dynamic>> snapshot = await _firestore
          .collection('event-subscriptions')
          .where("event-id", isEqualTo: eventId)
          .get();

      List<EventSubscription> subs = [];

      for (var doc in snapshot.docs) {
        Map<String, dynamic> data = doc.data();
        String subscriptionId = doc.id;

        EventSubscription sub = EventSubscription(
          id: subscriptionId,
          eventId: data['event-id'] ?? '',
          userId: data['user-id'] ?? '',
        );
        subs.add(sub);
      }
      return subs;
    } catch (e) {
      rethrow;
    }
  }

  Future<List<CustomEvent>> getSubscribedEventsByUserId(String userId) async {
    try {
      List<CustomEvent> events = [];
      var subs = await getEventSubscriptionsByUserId(userId);
      for (var sub in subs) {
        CustomEvent? event = await _getEventById(sub.eventId);
        if (event != null) {
          events.add(event);
        }
      }
      return events;
    } catch (e) {
      rethrow;
    }
  }

  Future<CustomEvent?> _getEventById(String eventId) async {
    try {
      DocumentSnapshot<Map<String, dynamic>> snapshot =
          await _firestore.collection('events').doc(eventId).get();

      if (!snapshot.exists) {
        return null;
      }
      if (snapshot.data() != null) {
        Map<String, dynamic> data = snapshot.data()!;
        String eventId = snapshot.id;

        CustomEvent event = CustomEvent(
          LatLng(data['latitude']?? 0.0, data['longitude']?? 0.0),
          data['dateTime'].toDate(),
          data['title'] ?? '',
          data['description'] ?? '',
          EventType.fromString(data['eventType']??''),
          eventId,
          data['userId'],
        );
        return event;
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  Future<int?> getEventSubscriptionCount(String eventId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('event-subscriptions')
          .where('event-id', isEqualTo: eventId)
          .get();

      return snapshot.size;
    } catch (e) {
      return null;
    }
  }

  Future<bool?> getEventSubscriptionStatus(String userId, String eventId) async {
    try {
      QuerySnapshot<Map<String, dynamic>> snapshot = await _firestore
          .collection('event-subscriptions')
          .where("user-id", isEqualTo: userId)
          .where("event-id", isEqualTo: eventId)
          .get();

      if (snapshot.docs.isNotEmpty) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return null;
    }
  }

  static of(BuildContext context) {}

}

class User {
  String uid;
  String email;
  String displayName;
  String icon;

  User({
    required this.uid,
    required this.email,
    required this.displayName,
    required this.icon,
  });

  iconURL({required String newIconURL}) {
    icon = newIconURL;
  }
}

class UserPreferences {
  bool isDarkMode = false;
  CalendarViewType calendarViewType = CalendarViewType.day;

  UserPreferences({required this.isDarkMode, required this.calendarViewType});
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
  final String title;
  final DateTime dateTime;
  final String description;
  final String eventType;
  final double latitude;
  final double longitude;
  final String userId;

  Event({
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

class EventSubscription {
  final String id;
  final String eventId;
  final String userId;

  EventSubscription({
    required this.id,
    required this.eventId,
    required this.userId,
  });

  Map<String, dynamic> toMap() {
    return {
      'eventId': eventId,
      'userId': userId,
    };
  }
}
