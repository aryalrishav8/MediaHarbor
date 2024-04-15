import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
// import 'package:mediaharbor/ui/profile_screen.dart';

class PostOperations {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> deletePost(
      String postId, String postImageUrl, BuildContext context) async {
    try {
      // Delete post image/audio from Firebase storage
      await FirebaseStorage.instance.refFromURL(postImageUrl).delete();
      // Remove post instance from posts collection
      await _firestore.collection('posts').doc(postId).delete();
    } catch (e) {
      print('Error deleting post: $e');
      // Handle error accordingly
    }
  }
}
