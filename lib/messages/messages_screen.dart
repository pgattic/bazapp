import 'package:bazapp/user_profile/user_profile_small.dart';
import 'package:bazapp/messages/chat_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
      stream: MessageService().getUsersByDisplayName(
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
                    String? userId = await MessageService().getCurrentUserId();
                    String? otherUserId =
                        await MessageService().getUserIdByDisplayName(userName);

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

  List<Widget> chatButtons = [];
  Set<String> uniqueUserIds = Set(); // Store unique user IDs

  Future<void> _fetchChatButtons(AuthProvider authProvider) async {
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
            child: ListTile(
              title: UserProfileSmall(userId: otherUserId),
            ),
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => ChatScreen(recipientUid: otherUserId),
              ));
            },
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
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
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
              children: chatButtons
                  .map((chatButton) => Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        child: chatButton,
                      ))
                  .toList(),
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
