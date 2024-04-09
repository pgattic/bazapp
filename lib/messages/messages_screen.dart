import 'package:bazapp/user_profile/user_profile_small.dart';
import 'package:bazapp/messages/chat_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fire;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../firebase/auth_provider.dart';

class MessagesScreen extends StatefulWidget {
  final BZUser user; // Accept user information
  MessagesScreen({Key? key, required this.user}) : super(key: key);

  @override
  _MessagesScreenState createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController searchController = TextEditingController();
  bool isSearchBarFocused = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(
            child: _buildRecentChats(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SearchAnchor.bar(
        barHintText: "Search all users",
        suggestionsBuilder: (BuildContext context, SearchController controller) async {
          return searchUsersByDisplayName(controller.text);
        },
      ),
    );
  }

  Future<List<Widget>> searchUsersByDisplayName(String searchTerm) async {
    if (searchTerm.isEmpty) {
      // Return all users when searchTerm is empty
      return _firestore.collection('users').limit(20).get().then((snapshot) {
        return snapshot.docs.map((doc) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 4.0),
            child: UserProfileSmall(
              userId: doc.id,
              viewerId: getCurrentUserId(),
            ),
          );
        }).toList();
      });
    } else {
      // Return filtered users based on searchTerm
      return _firestore
          .collection('users')
          .where('displayName', isGreaterThanOrEqualTo: searchTerm)
          .where('displayName', isLessThan: searchTerm + 'z')
          .limit(20)
          .get()
          .then((snapshot) {
        return snapshot.docs.map((doc) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: UserProfileSmall(
              userId: doc.id,
              viewerId: getCurrentUserId(),
            ),
          );
        }).toList();
      });
    }
  }

  String? getCurrentUserId() {
    final user = fire.FirebaseAuth.instance.currentUser;
    return user?.uid;
  }

  List<Widget> chatButtons = [];
  Set<String> uniqueUserIds = Set(); // Store unique user IDs

  Future<void> _fetchChatButtons(BZAuthProvider authProvider) async {
    final user = authProvider.user;

    // Clear the existing chatButtons and uniqueUserIds when fetching
    chatButtons.clear();
    uniqueUserIds.clear();

    final chatDocs = await FirebaseFirestore.instance
        .collection('messages')
        .where('recipientId', isEqualTo: user?.uid)
        .get();

    for (final chat in chatDocs.docs) {
      final otherUserId = chat['senderId'];

      // Only add unique users
      if (!uniqueUserIds.contains(otherUserId)) {
        uniqueUserIds.add(otherUserId);
        BZUser otherUser = await Provider.of<BZAuthProvider>(context, listen: false).getUserById(otherUserId);

        chatButtons.add(
          TextButton(
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => ChatScreen(recipient: otherUser),
              ));
            },
            style: ButtonStyle(
              shape: MaterialStateProperty.all(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(0.0), // Set radius to 0.0 for no rounded corners
                ),
              ),
              padding: MaterialStateProperty.all(
                const EdgeInsets.symmetric(vertical: 4.0, horizontal: 0.0), // Adjust the padding values as needed
              ),
            ),
            child: ListTile(
              title: UserProfileSmall(userId: otherUserId),
            ),
          ),
        );
      }
    }
    if (mounted) {
      setState(() {}); // Trigger a rebuild to display the chat buttons.
    }
  }

  @override
  void initState() {
    final authProvider = Provider.of<BZAuthProvider>(context, listen: false);
    _fetchChatButtons(authProvider);
    super.initState();
  }

  Widget _buildRecentChats() {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
            child: Text(
              'Your past chats:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: ListView(
              children: chatButtons.toList(),
            ),
          ),
        ],
      ),
    );
  }
}
