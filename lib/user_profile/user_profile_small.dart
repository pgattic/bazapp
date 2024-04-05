import 'package:bazapp/messages/chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfileSmall extends StatelessWidget {
  final String userId;
  final String? viewerId;

  const UserProfileSmall({Key? key, required this.userId, this.viewerId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('users').doc(userId).get(),
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

        final userData = snapshot.data!.data() as Map<String, dynamic>;
        final String displayName = userData['displayName'];
        final String email = userData['email'];
        final String iconUrl = userData['icon'];

        return Row(
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage(iconUrl),
              radius: 20,
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      displayName,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    if (viewerId == userId) const Text(' (you)', style: TextStyle(color: Colors.grey)),
                  ],
                ),
                Text(
                  email,
                  style: const TextStyle(color: Colors.grey),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
            Spacer(),
            if (viewerId != userId) IconButton(
              onPressed: () => {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) =>
                      ChatScreen(recipientUid: userId),
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
