import 'package:flutter/material.dart';
import 'firebase/auth_provider.dart';

class ChatScreen extends StatefulWidget {
  final String? userId;
  final String? otherUserId;

  ChatScreen({required this.userId, required this.otherUserId});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController messageController = TextEditingController();
  late Future<String?> displayNameFuture;

  @override
  void initState() {
    super.initState();
    displayNameFuture =
        MessageService().getDisplayNameByUserId(widget.otherUserId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: FutureBuilder<String?>(
          future: displayNameFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            } else if (snapshot.hasError || snapshot.data == null) {
              return Text('Error fetching display name');
            } else {
              return Text(snapshot.data!);
            }
          },
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: _buildChatMessages(),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildChatMessages() {
    return StreamBuilder<List<Message>>(
      stream: MessageService().getChatMessages(
        widget.userId,
        widget.otherUserId,
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error fetching messages'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('No messages yet'));
        } else {
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              Message message = snapshot.data![index];
              return ListTile(
                title: Text(message.text),
              );
            },
          );
        }
      },
    );
  }

  Widget _buildMessageInput() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: messageController,
              decoration: InputDecoration(
                labelText: 'Type a message...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.send),
            onPressed: () {
              _sendMessage();
            },
          ),
        ],
      ),
    );
  }

  void _sendMessage() {
    String messageText = messageController.text.trim();

    if (messageText.isNotEmpty) {
      MessageService().sendMessage(
        Message(
          senderId: widget.userId,
          recipientId: widget.otherUserId,
          text: messageText,
          timestamp: DateTime.now(),
          read: false,
        ),
      );
      messageController.clear();
    }
  }
}
