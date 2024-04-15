import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mediaharbor/helper/post_operations.dart';

class DeleteUserPage extends StatelessWidget {
  PostOperations postOperations = new PostOperations();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Delete User'),
      ),
      body: Center(
        child: GestureDetector(
          onTap: () {
            _showEmailDialog(context);
          },
          child: Container(
            width: 150,
            height: 150,
            alignment: Alignment.center,
            color: Colors.blue,
            child: const Text(
              'Delete User',
              style: TextStyle(fontSize: 18, color: Colors.white),
            ),
          ),
        ),
      ),
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
      final scaffoldMessenger = ScaffoldMessenger.of(context);
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

        scaffoldMessenger.showSnackBar(
          const SnackBar(
            content:
                Text('User data and associated posts deleted successfully'),
          ),
        );
      } else {
        scaffoldMessenger.showSnackBar(
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
