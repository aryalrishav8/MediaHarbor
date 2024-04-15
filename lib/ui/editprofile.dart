import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'profile_screen.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class EditProfileScreen extends StatefulWidget {
  final String currentUsername;
  final String currentProfilePictureUrl;

  const EditProfileScreen({
    Key? key,
    required this.currentUsername,
    required this.currentProfilePictureUrl,
  }) : super(key: key);

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _usernameController;
  String _profilePictureUrl = '';
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController(text: widget.currentUsername);
    fetchUserDataFromDatabase();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  Future<void> fetchUserDataFromDatabase() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      if (userSnapshot.exists) {
        Map<String, dynamic>? userData =
            userSnapshot.data() as Map<String, dynamic>?;

        if (userData != null) {
          if (userData.containsKey('profilePictureUrl')) {
            setState(() {
              _profilePictureUrl = userData['profilePictureUrl'];
            });
          }

          String? username = userData['username'];
          if (username != null) {
            _usernameController.text = username;
          }
        }
      }
    }
  }

  void updateUsername(String newUsername) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .update({'username': newUsername});
      // Show Snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Username updated successfully'),
          duration: Duration(seconds: 2),
        ),
      );
      // Update TextField immediately
      _usernameController.text = newUsername;
    } catch (e) {
      print('Error updating username: $e');
      // Handle error accordingly
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => ProfilePage()),
            );
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            GestureDetector(
              child: CircleAvatar(
                radius: 130,
                child: _profilePictureUrl.isNotEmpty
                    ? null
                    : Icon(Icons.person, size: 50),
                backgroundImage: _profilePictureUrl.isNotEmpty
                    ? NetworkImage(_profilePictureUrl)
                    : null,
              ),
              onTap: () {
                editDP();
              },
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(
                labelText: 'Username',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Save changes logic here
                String newUsername = _usernameController.text;
                // Update the username in Firestore or wherever it's stored
                updateUsername(newUsername);
              },
              child: const Text('Save Changes'),
            ),
            const SizedBox(height: 20),
            if (_isUploading)
              Center(
                child: const SizedBox(
                  height: 70,
                  width: 70,
                  child: CircularProgressIndicator(
                    strokeWidth: 4,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> editDP() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 40,
    );
    if (pickedImage != null) {
      File imageFile = File(pickedImage.path);
      String newImageUrl = await uploadProfilePicture(imageFile);
      if (newImageUrl.isNotEmpty) {
        String oldImageUrl = _profilePictureUrl;

        try {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(FirebaseAuth.instance.currentUser!.uid)
              .update({'profilePictureUrl': newImageUrl});
          // Update UI with new profile picture
          setState(() {
            _profilePictureUrl = newImageUrl;
            _isUploading = false;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile picture updated successfully'),
              duration: Duration(seconds: 2),
            ),
          );
          // Delete the old profile picture from storage
          if (oldImageUrl.isNotEmpty) {
            try {
              Reference oldImageRef =
                  FirebaseStorage.instance.refFromURL(oldImageUrl);
              await oldImageRef.delete();
              print('Old profile picture deleted successfully');
            } catch (e) {
              print('Error deleting old profile picture: $e');
            }
          }
        } catch (e) {
          print('Error updating profile picture URL: $e');
        }
      }
    }
  }

  Future<String> uploadProfilePicture(File imageFile) async {
    try {
      setState(() {
        _isUploading = true;
      });
      FirebaseStorage storage = FirebaseStorage.instance;
      Reference ref =
          storage.ref().child("profilePictures/${DateTime.now()}.jpg");
      UploadTask uploadTask = ref.putFile(imageFile);
      TaskSnapshot taskSnapshot = await uploadTask;
      String imageUrl = await taskSnapshot.ref.getDownloadURL();
      return imageUrl;
    } catch (e) {
      print('Error uploading profile picture: $e');
      return '';
    }
  }
}
