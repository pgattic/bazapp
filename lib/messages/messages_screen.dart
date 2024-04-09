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
      appBar: AppBar(
        title: Text('Messages'),
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          isSearchBarFocused ? _buildUserDropDown() : Container(),
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
      child: TextField(
        controller: searchController,
        onTap: () {
          setState(() {
            isSearchBarFocused = true;
          });
        },
        onEditingComplete: () {
          setState(() {
            isSearchBarFocused = false;
          });
        },
        onChanged: (value) {
          setState(() {
            // Trigger rebuild on search bar text change
          });
        },
        decoration: InputDecoration(
          labelText: 'Search for users by display name',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }

  Widget _buildUserDropDown() {
    return StreamBuilder<List<BZUser>>(
      stream: searchUsersByDisplayName(
        searchController.text.isNotEmpty
            ? searchController.text
            : '', // Pass an empty string to get all users when the search is empty
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Text('Error fetching users');
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Container(); // No results, return an empty container
        } else {
          List<BZUser> users = snapshot.data!;
          return Container(
            height: 160, // Limit the height to show at most 4 users
            child: ListView.builder(
              itemCount: users.length > 4 ? 4 : users.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () async {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => ChatScreen(recipient: users[index]),
                      ),
                    );
                  },
                  child: Card(
                    margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: UserProfileSmall(userId: users[index].uid),
                  ),
                );
              },
            ),
          );
        }
      },
    );
  }

  Stream<List<BZUser>> searchUsersByDisplayName(String displayName) {
    if (displayName.isEmpty) {
      // Return all users when displayName is empty
      return _firestore.collection('users').snapshots().map((snapshot) {
        return snapshot.docs.map((doc) {
          return BZUser(
            uid: doc.id,
            displayName: doc['displayName'] as String,
            email: doc['email'] as String,
            icon: doc['photoURL'] as String,
          );
        }).toList();
      });
    } else {
      // Return filtered users based on displayName
      var query = _firestore
          .collection('users')
          .where('displayName', isGreaterThanOrEqualTo: displayName)
          .where('displayName', isLessThan: displayName + 'z')
          .snapshots();
      return query.map((snapshot) {
        return snapshot.docs.map((doc) {
          return BZUser(
            uid: doc.id,
            displayName: doc['displayName'] as String,
            email: doc['email'] as String,
            icon: doc['photoURL'] as String,
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
          Padding(
            padding: const EdgeInsets.all(8.0),
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
