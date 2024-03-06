import 'package:bazapp/ChatScreen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'firebase/auth_provider.dart';
import 'firebase/message_service.dart' as messageService;

class MessagesScreen extends StatefulWidget {
  final User user; // Accept user information
  MessagesScreen({Key? key, required this.user}) : super(key: key);

  @override
  _MessagesScreenState createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  final TextEditingController searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Messages'),
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildUserDropDown(),
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
            : '', // Pass an empty string to get all users when search is empty
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

                    _openChatWith(userId, otherUserId);
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

  Widget _buildRecentChats() {
    return Column(
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
          child: StreamBuilder<List<String>>(
            stream: MessageService().getRecentChats(widget.user.uid),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error fetching recent chats'));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(child: Text('No recent chats'));
              } else {
                return ListView.builder(
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    String displayName = snapshot.data![index];
                    return GestureDetector(
                      onTap: () => _openChatWith(
                          MessageService().getCurrentUserId(), displayName),
                      child: Card(
                        margin:
                            EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        child: ListTile(
                          title: Text('Chat with $displayName'),
                        ),
                      ),
                    );
                  },
                );
              }
            },
          ),
        ),
      ],
    );
  }

  void _openChatWith(String? userId, String? otherUserId) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) =>
            ChatScreen(userId: userId, otherUserId: otherUserId),
      ),
    );
  }
}
