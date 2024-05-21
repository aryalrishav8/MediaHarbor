import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mediaharbor/algorithm/friendOfFriends.dart';
import 'package:mediaharbor/ui/home_page.dart';
import 'package:mediaharbor/ui/navigate_profile.dart';
import 'package:mediaharbor/ui/profile_screen.dart';
import 'package:mediaharbor/ui/search_screen.dart';
import 'package:mediaharbor/widgets/bottomnavbar.dart';
import 'package:mediaharbor/widgets/uploadoptions.dart';

class RecommendationScreen extends StatefulWidget {
  @override
  _RecommendationScreenState createState() => _RecommendationScreenState();
}

class _RecommendationScreenState extends State<RecommendationScreen> {
  final int maxRecommendations = 5;
  late Future<List<Map<String, dynamic>>> _recommendations;

  @override
  void initState() {
    super.initState();
    _recommendations = _getRecommendations();
  }

  Future<List<Map<String, dynamic>>> _getRecommendations() async {
    String currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';
    print(currentUserId);
    if (currentUserId.isEmpty) {
      throw Exception('User not authenticated.');
    }

    return recommendUsers(currentUserId, maxRecommendations);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Possible Connections'),
      ),
      body: FutureBuilder(
        future: _recommendations,
        builder: (context, AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
          print(snapshot);
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error.toString()}'));
          } else if (snapshot.data == null || snapshot.data!.isEmpty) {
            return Center(child: Text('No recommended users found.'));
          } else {
            List<Map<String, dynamic>> recommendedUsers = snapshot.data ?? [];
            return ListView.builder(
              itemCount: recommendedUsers.length,
              itemBuilder: (context, index) {
                Map<String, dynamic> user = recommendedUsers[index];
                String username = user['username'] ?? 'N/A';
                String senderId = user['id'];
                String profilePicUrl = user['profilePicUrl'] ?? '';
                Widget leadingWidget = profilePicUrl.isEmpty
                    ? CircleAvatar(
                        backgroundImage: AssetImage('assets/person_icon.png'),
                      )
                    : CircleAvatar(
                        backgroundImage: NetworkImage(profilePicUrl),
                      );
                return Card(
                  elevation: 4,
                  margin:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: ListTile(
                    leading: leadingWidget,
                    title: Text(username),
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => UserProfileScreen(
                                  userId: senderId,
                                  currentUserId:
                                      FirebaseAuth.instance.currentUser?.uid ??
                                          '')));
                    },
                  ),
                );
              },
            );
          }
        },
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: 3, // Set the index for Profile tab
        onTabSelected: (int index) {
          if (index == 2) {
            showUploadOptions(context);
          } else if (index == 0) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => HomePage()),
            ); // Navigate back to the previous screen
          } else if (index == 4) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ProfilePage()),
            );
          } else if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => SearchScreen()),
            );
          } else if (index == 3) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => RecommendationScreen()),
            );
          }
        },
      ),
    );
  }
}
