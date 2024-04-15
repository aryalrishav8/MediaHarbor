import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ReportService {
  static Future<void> submitReport(
      BuildContext context, reportReason, String postId) async {
    if (reportReason.isNotEmpty) {
      try {
        final scaffoldMessenger = ScaffoldMessenger.of(context);
        String? userId = FirebaseAuth.instance.currentUser?.uid;

        // Get the current date and time
        DateTime now = DateTime.now();
        // Format the date and time
        String formattedDate = DateFormat('yyyy-MM-dd HH:mm:ss').format(now);

        // Save the report data to Firebase
        await FirebaseFirestore.instance.collection('reports').add({
          'userId': userId,
          'reason': reportReason,
          'date': formattedDate,
          'postId': postId
        });

        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text('Report submitted successfully'),
          ),
        );
      } catch (e) {
        // Handle any errors
        print('Error submitting report: $e');
      }
    }
  }
}
