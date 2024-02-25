import 'package:bazapp/ChatScreen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'firebase/auth_provider.dart';
import 'firebase/message_service.dart' as messageService;

class MessagesScreen extends StatefulWidget {
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
          _buildRecentChats(),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        controller: searchController,
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
      // Assuming you have a method in MessageService to get users by display name
      stream: MessageService().getUsersByDisplayName(searchController.text),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Error fetching users');
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Container(); // No results, return an empty container
        } else {
          List<String> users = snapshot.data!;
          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              String userName = users[index];
              return GestureDetector(
                onTap: () {
                  // Handle user selection, for example, open a chat with the selected user
                  _openChatWith(userName);
                },
                child: Card(
                  margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: ListTile(
                    title: Text(userName),
                  ),
                ),
              );
            },
          );
        }
      },
    );
  }

  Widget _buildRecentChats() {
    return Expanded(
      child: StreamBuilder<List<String>>(
        // Use StreamBuilder instead of FutureBuilder
        stream: messageService.MessageService().getRecentChats(
          Provider.of<AuthProvider>(context).user!.uid,
        ),
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
                String userId = snapshot.data![index];
                return GestureDetector(
                  onTap: () => _openChatWith(userId),
                  child: Card(
                    margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: ListTile(
                      title: Text(userId), // Replace with user display name
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }

  void _openChatWith(String userId) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ChatScreen(otherUserId: userId),
      ),
    );
  }
}
