import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';

class PostUploadPage extends StatefulWidget {
  PostUploadPage({Key? key}) : super(key: key);

  @override
  _PostUploadPageState createState() => _PostUploadPageState();
}

class _PostUploadPageState extends State<PostUploadPage> {
  TextEditingController captionController = TextEditingController();
  String caption = '';
  bool isUploading = false;

  Future<String> uploadPic(File imageFile) async {
    setState(() {
      isUploading = true;
    });
    try {
      FirebaseStorage storage = FirebaseStorage.instance;
      Reference ref = storage.ref().child("images/${DateTime.now()}.jpg");
      UploadTask uploadTask = ref.putFile(imageFile);
      TaskSnapshot taskSnapshot = await uploadTask;
      String imagUrl = await taskSnapshot.ref.getDownloadURL();
      String imageUrl = imagUrl.toString();
      return imageUrl;
    } catch (e) {
      print('Error uploading image: $e');
      return ''; // Return empty string in case of error
    } finally {
      setState(() {
        isUploading = false;
      });
    }
  }

  Future<void> addImageToFirebase(BuildContext context) async {
    try {
      final ImagePicker picker = ImagePicker();
      final pickedImage =
          await picker.pickImage(source: ImageSource.gallery, imageQuality: 40);

      if (pickedImage != null) {
        File imageFile = File(pickedImage.path);
        String imageUrl = await uploadPic(imageFile);

        if (imageUrl.isNotEmpty) {
          final User? user = FirebaseAuth.instance.currentUser;
          if (user != null) {
            DocumentSnapshot userDataSnapshot = await FirebaseFirestore.instance
                .collection('users')
                .doc(user.uid)
                .get();
            if (userDataSnapshot.exists) {
              await showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text("Upload caption"),
                  content: TextField(
                    controller: captionController,
                    decoration:
                        const InputDecoration(hintText: "Enter Caption..."),
                  ),
                  actions: [
                    ElevatedButton(
                      onPressed: () async {
                        setState(() {
                          caption = captionController.text;
                        });
                        Navigator.pop(context);
                      },
                      child: const Text("Save"),
                    ),
                  ],
                ),
              );
              String profilePicUrl =
                  userDataSnapshot['profilePictureUrl'] ?? '';
              final CollectionReference postsRef =
                  FirebaseFirestore.instance.collection('posts');
              await postsRef.add({
                'senderId': user.uid,
                'path': imageUrl,
                'likes': [],
                'comments': [],
                'profilePic':
                    profilePicUrl, // Use profile picture URL from user data
                'date': DateTime.now(),
                'type': 'Image',
                'caption': caption
              });

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Image uploaded successfully!')),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('User data not found.')),
              );
            }
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('User not authenticated.')),
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content:
                    Text('Error uploading image. Please try again later.')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No image selected.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error uploading image: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Upload Image'),
        ),
        body: Center(
          child: isUploading
              ? const CircularProgressIndicator()
              : GestureDetector(
                  onTap: () => addImageToFirebase(context),
                  child: Container(
                    height: 175,
                    width: 175,
                    padding: const EdgeInsets.symmetric(
                        vertical: 12.0, horizontal: 24.0),
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 235, 228, 207),
                      borderRadius:
                          BorderRadius.circular(8.0), // Rounded corners
                    ),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.upload,
                          size: 80,
                          color: Color.fromARGB(255, 90, 90, 90),
                        ),
                        Text(
                          'Upload Image',
                          style: TextStyle(
                            color:
                                Color.fromARGB(255, 90, 90, 90), // Text color
                            fontSize: 18.0, // Text size
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
        ));
  }
}
