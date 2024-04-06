import 'dart:io';
import 'package:bazapp/firebase/auth_provider.dart' as auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fire;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

class UserProfileScreen extends StatefulWidget {
  @override
  _UserProfilePageState createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfileScreen> {
  
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> _changeProfilePicture(auth.BZAuthProvider authProvider) async {
    final picker = ImagePicker();

    try {
      // Pick an image from the gallery
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        // Get the file and its path
        File imageFile = File(pickedFile.path);

        // Compress the image
        File compressedImage = await compressImage(imageFile);

        // Upload the compressed image to your server or storage
        // For example, you can use Firebase Storage for this purpose
        String profilePictureUrl =
            await authProvider.uploadProfilePicture(compressedImage);

        // Perform other tasks if needed, such as updating the user's profile with the new picture
        await authProvider.updateUserProfile(profilePictureUrl);

        // Update the UI if necessary
        setState(() {
          // Update the UI with the new profile picture
          // e.g., authProvider.user.profilePictureUrl = profilePictureUrl;
        });
      }
    } catch (e) {
      print('Error picking image: $e');
      // Handle errors if any
    }
  }

  Future<File> compressImage(File imageFile) async {
    // Compress the image using flutter_image_compress
    
    List<int> compressedBytes = await FlutterImageCompress.compressWithList(
      imageFile.readAsBytesSync(),
      minHeight: 1920,
      minWidth: 1080,
      quality: 94,
    );

    // Save the compressed image to a new file
    File compressedImage = File(imageFile.path)
      ..writeAsBytesSync(compressedBytes);

    return compressedImage;
  }

  Future<String?> getURLByUserID(String displayName) async {
  try {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('displayName', isEqualTo: displayName)
        .limit(1)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      // Assuming the field containing the URL is named 'profileUrl'
      final url = querySnapshot.docs.first.get('icon') as String?;
      return url;
    } else {
      return null;
    }
  } catch (e) {
    print('Error getting URL by UID: $e');
    return null;
  }
}


 @override
Widget build(BuildContext context) {
  final authProvider = Provider.of<auth.BZAuthProvider>(context);
  final user = authProvider.user;

  return FutureBuilder<String?>(
    future: getURLByUserID(user!.displayName),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        // Show a loading indicator while fetching the URL
        return CircularProgressIndicator();
      } else if (snapshot.hasError) {
        // Show an error message if fetching the URL fails
        return Text('Error: ${snapshot.error}');
      } else {
        // Once the URL is fetched successfully, use it to display the profile picture
        final url = snapshot.data ?? ''; // Use empty string if URL is null
        return Scaffold(
          appBar: AppBar(
            title: Text('User Profile'),
          ),
          body: Center(
            child: Column(
              children: <Widget>[
                Padding(
  padding: const EdgeInsets.all(16.0),
  child: GestureDetector(
    onTap: () {
      // Handle tapping the profile picture to change it
      _changeProfilePicture(authProvider);
    },
    child: ClipOval(
      child: CircleAvatar(
        radius: 60,
        backgroundImage: url.isEmpty ? null : NetworkImage(url),
        backgroundColor: Colors.grey, // Use a default background color
      ),
    ),
  ),
),
                ElevatedButton(
                  onPressed: () {
                    Provider.of<auth.BZAuthProvider>(context, listen: false).signOut();
                  },
                  child: const Text(
                    'Sign Out',
                    style: TextStyle(fontSize: 20, color: Colors.black),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(15),
                    ),
                    padding: EdgeInsets.all(10),
                    child: Text(
                      'Display Name: ${user.displayName ?? 'Loading...'}',
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(15),
                    ),
                    padding: EdgeInsets.all(10),
                    child: Text(
                      'Email: ${user.email ?? 'Loading...'}',
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }
    },
  );
}
}