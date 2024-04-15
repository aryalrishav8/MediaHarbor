import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:mediaharbor/admin/deletepost.dart';
import 'package:mediaharbor/admin/deleteuser.dart';
import 'package:mediaharbor/ui/login_page.dart';

class AdminPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
                width: 150,
                height: 150,
                alignment: Alignment.center,
                color: Colors.red,
                child: const Text(
                  'Delete Post',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () {
                // Navigate to delete user page
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => DeleteUserPage()),
                );
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
}
