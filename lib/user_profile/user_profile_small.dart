import 'package:bazapp/firebase/auth_provider.dart';
import 'package:bazapp/messages/chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class UserProfileSmall extends StatelessWidget {
  final String userId;
  final String? viewerId;

  const UserProfileSmall({Key? key, required this.userId, this.viewerId})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<BZUser>(
      future: Provider.of<BZAuthProvider>(context, listen: false).getUserById(userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }

        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }

        if (!snapshot.hasData || snapshot.data == null) {
          return const Text('User not found');
        }

        final BZUser user = snapshot.data!;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage(user.icon),
              radius: 25,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          user.displayName + (viewerId == userId ? ' (you)' : ''),
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Spacer(),
                    ],
                  ),
                  Text(
                    user.email,
                    style: const TextStyle(color: Colors.grey, fontSize: 16),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (viewerId != userId)
              IconButton(
                onPressed: () => {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => ChatScreen(recipient: user),
                  ))
                },
                icon: Icon(Icons.chat),
              ),
          ],
        );
      },
    );
  }
}
