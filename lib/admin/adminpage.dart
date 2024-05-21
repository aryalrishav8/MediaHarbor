import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:mediaharbor/admin/deletepost.dart';
import 'package:mediaharbor/helper/post_operations.dart';
import 'package:mediaharbor/ui/login_page.dart';

// ignore: must_be_immutable
class AdminPage extends StatelessWidget {
  PostOperations postOperations = new PostOperations();
  ScaffoldMessengerState? _scaffoldMessengerState;

  AdminPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 235, 228, 207),
        automaticallyImplyLeading: false,
        title: const Text('Admin Page'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              _signOut(context);
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () {
                // Navigate to delete post page
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => DeletePostPage()),
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Color.fromARGB(255, 235, 228, 207),
                ),
                width: 175,
                height: 175,
                alignment: Alignment.center,
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.delete,
                      size: 80,
                      color: Color.fromARGB(255, 90, 90, 90),
                    ),
                    Text(
                      'Delete Post',
                      style: TextStyle(
                        fontSize: 18,
                        color: Color.fromARGB(255, 90, 90, 90),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () {
                // Navigator.push(
                //   context,
                //   MaterialPageRoute(builder: (context) => DeleteUserPage()),
                // );
                _showEmailDialog(context);
              },
              child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Color.fromARGB(255, 235, 228, 207),
                  ),
                  width: 175,
                  height: 175,
                  alignment: Alignment.center,
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.supervised_user_circle_outlined,
                        size: 80,
                        color: Color.fromARGB(255, 90, 90, 90),
                      ),
                      Text(
                        'Delete User',
                        style: TextStyle(
                          fontSize: 18,
                          color: Color.fromARGB(255, 90, 90, 90),
                        ),
                      ),
                    ],
                  )),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _signOut(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }

  Future<void> _showEmailDialog(BuildContext context) async {
    TextEditingController emailController = TextEditingController();

    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Enter User Email'),
          content: TextField(
            controller: emailController,
            decoration: InputDecoration(hintText: 'Email'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                String email = emailController.text.trim();
                Navigator.pop(context);
                if (email.isNotEmpty) {
                  _showConfirmationDialog(context, email);
                }
              },
              child: Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showConfirmationDialog(
      BuildContext context, String email) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Deletion'),
          content: Text('Are you sure you want to delete this user?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the confirmation dialog
                _deleteUser(context, email); // Proceed with user deletion
              },
              child: Text('Yes'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the confirmation dialog
              },
              child: Text('No'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteUser(BuildContext context, String email) async {
    try {
      // Get the user data from Firestore
      QuerySnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: email)
          .get();
      if (userSnapshot.size == 1) {
        // Get the UID of the user to be deleted
        String uid = userSnapshot.docs.first.id;

        // Delete user data from Firestore
        await FirebaseFirestore.instance.collection('users').doc(uid).delete();

        // Delete posts associated with the user
        await FirebaseFirestore.instance
            .collection('posts')
            .where('senderId', isEqualTo: uid)
            .get()
            .then((querySnapshot) {
          querySnapshot.docs.forEach((doc) {
            String postId = doc.id;
            String path = doc['path'];
            postOperations.deletePost(
                postId, path, context); // Call deletePost function
          });
        });

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content:
                Text('User data and associated posts deleted successfully'),
          ),
        );
      } else {
        // Show error message for user not found
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'User not found or multiple users found with the same email'),
          ),
        );
      }
    } catch (e) {
      print('Error deleting user data: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error deleting user data'),
        ),
      );
    }
  }
}
