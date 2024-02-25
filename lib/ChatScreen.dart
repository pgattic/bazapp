import 'package:flutter/material.dart';
import 'firebase/auth_provider.dart';
import 'firebase/message_service.dart' as messageService;

class ChatScreen extends StatefulWidget {
  final String otherUserId;

  ChatScreen({required this.otherUserId});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController messageController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.otherUserId), // Replace with user display name
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
      stream: messageService.MessageService().getChatMessages(
        AuthProvider.of(context).user?.uid,
        widget.otherUserId,
      ) as Stream<List<Message>>, // Explicitly cast to the correct type
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
      messageService.MessageService().sendMessage(
        Message(
          senderId: AuthProvider.of(context).user?.uid,
          recipientId: widget.otherUserId,
          text: messageText,
          timestamp: DateTime.now(),
        ) as messageService.Message,
      );
      messageController.clear();
    }
  }
}
