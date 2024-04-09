import 'package:bazapp/user_profile/user_profile_small.dart';
import 'package:bazapp/messages/chat_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fire;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../firebase/auth_provider.dart';

class MessagesScreen extends StatefulWidget {
  final User user; // Accept user information
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
    return StreamBuilder<List<String>>(
      stream: getUsersByDisplayName(
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
          List<String> users = snapshot.data!;
          return Container(
            height: 160, // Limit the height to show at most 4 users
            child: ListView.builder(
              itemCount: users.length > 4 ? 4 : users.length,
              itemBuilder: (context, index) {
                String userName = users[index];
                return GestureDetector(
                  onTap: () async {
                    String? userId = getCurrentUserId();
                    String? otherUserId =
                        await getUserIdByDisplayName(userName);

                    _openChatWith(userId!, otherUserId!);
                  },
                  child: Card(
                    margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: ListTile(
                      title: Text(userName),
                    ),
                  ),
                );
              },
            ),
          );
        }
      },
    );
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

        chatButtons.add(
          TextButton(
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => ChatScreen(recipientUid: otherUserId),
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

  void _openChatWith(String userId, String otherUserId) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ChatScreen(recipientUid: otherUserId),
      ),
    );
  }
}
