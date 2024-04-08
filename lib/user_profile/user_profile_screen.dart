import 'dart:io';
import 'package:bazapp/firebase/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  _UserProfilePageState createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfileScreen> {
  Future<void> _changeProfilePicture(BZAuthProvider authProvider) async {
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

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<BZAuthProvider>(context);
    final user = authProvider.user;

    if (user == null) {
      // Show a loading indicator while fetching the URL
      return const Text("An Unknown Error Occurred");
    } else {
      // Once the URL is fetched successfully, use it to display the profile picture
      final url = user.icon; // Use empty string if URL is null
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              GestureDetector(
                onTap: () {
                  // Handle tapping the profile picture to change it
                  _changeProfilePicture(authProvider);
                },
                child: ClipOval(
                  child: CircleAvatar(
                    radius: 80,
                    backgroundImage: url.isEmpty ? null : NetworkImage(url),
                    backgroundColor:
                        Colors.grey, // Use a default background color
                  ),
                ),
              ),
              SizedBox(height: 20),
              Container(
                child: Text(
                  user.displayName,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              Container(
                child: Text(
                  user.email,
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ),
              SizedBox(height: 30),
              TextButton(
                onPressed: () {
                  Provider.of<BZAuthProvider>(context, listen: false)
                      .resetPassword(user.email);
                  Fluttertoast.showToast(
                    msg: 'Password Reset Email Sent!',
                    toastLength: Toast.LENGTH_SHORT,
                  );
                },
                child: const Text(
                  'Reset Password',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.normal),
                ),
              ),
              TextButton(
                onPressed: () {
                  Provider.of<BZAuthProvider>(context, listen: false).signOut();
                },
                child: const Text(
                  'Sign Out',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.normal),
                ),
              ),
            ],
          ),
        ),
      );
    }
  }
}
