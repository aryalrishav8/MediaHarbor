import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mediaharbor/ui/navigatepost.dart';
import 'package:mediaharbor/ui/profile_screen.dart';
import 'package:mediaharbor/ui/recommend_page.dart';
import 'navigate_profile.dart';
import 'package:mediaharbor/widgets/bottomnavbar.dart';
import 'home_page.dart';
import 'package:mediaharbor/widgets/uploadoptions.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  late TextEditingController _searchController;
  List<Map<String, dynamic>> _searchResults = [];
  String currUserId = '';

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    getUserId();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> searchUsersandPosts(String query) async {
    if (query.isNotEmpty) {
      List<Map<String, dynamic>> results = [];
      setState(() {
        _searchResults = [];
      });

      QuerySnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .orderBy('username')
          .startAt([query]).endAt([query + '\uf8ff']).get();

      if (userSnapshot.docs.isNotEmpty) {
        userSnapshot.docs.forEach((doc) {
          Map<String, dynamic> userData = doc.data() as Map<String, dynamic>;
          results.add({
            'type': 'user',
            'username': userData['username'],
            'profilePictureUrl': userData['profilePictureUrl'] ?? '',
            'userId': doc.id,
          });
        });
      }

      QuerySnapshot postSnapshot = await FirebaseFirestore.instance
          .collection('posts')
          .where('caption', isGreaterThanOrEqualTo: query)
          .where('caption', isLessThanOrEqualTo: query + '\uf8ff')
          .get();

      if (postSnapshot.docs.isNotEmpty) {
        postSnapshot.docs.forEach((doc) {
          Map<String, dynamic> postData = doc.data() as Map<String, dynamic>;
          results.add({
            'type': 'post',
            'postId': doc.id,
            'caption': postData['caption'],
            'imageUrl': postData['path'] ?? '',
            'userId': postData['senderId'],
            'postType': postData['type']
          });
        });
      }
      setState(() {
        _searchResults = results;
      });
    } else {
      setState(() {
        _searchResults = [];
      });
    }
  }

  void getUserId() {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? user = auth.currentUser;
    if (user != null) {
      setState(() {
        currUserId = user.uid;
      });
    } else {
      print("++++++++++++++++++++++No User found++++++++++++++++++++++");
    }
  }

  void navigateToProfile(String userId) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => UserProfileScreen(
                userId: userId,
                currentUserId: currUserId,
              )),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Users & Posts'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  labelText: 'Search by username or post caption',
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.search),
                ),
                onChanged: (value) {
                  if (value.isEmpty) {
                    setState(() {
                      // _searchResults.clear(); // Clear the search results
                      _searchResults = [];
                    });
                  } else {
                    setState(() {
                      _searchResults = []; // Clear the search results
                    });
                    searchUsersandPosts(value);
                  }
                },
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Users:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _searchResults.length,
                itemBuilder: (context, index) {
                  // Display search results based on type (user or post)
                  if (_searchResults[index]['type'] == 'user') {
                    return GestureDetector(
                      onTap: () {
                        navigateToProfile(_searchResults[index]['userId']);
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: SizedBox(
                          width: double.infinity,
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 24,
                                backgroundImage: _searchResults[index]
                                            ['profilePictureUrl']
                                        .isEmpty
                                    ? null
                                    : NetworkImage(_searchResults[index]
                                        ['profilePictureUrl']),
                                child: _searchResults[index]
                                            ['profilePictureUrl']
                                        .isEmpty
                                    ? Icon(Icons.person)
                                    : null,
                              ),
                              const SizedBox(width: 16),
                              Text(_searchResults[index]['username']),
                            ],
                          ),
                        ),
                      ),
                    );
                  } else {
                    return const SizedBox
                        .shrink(); // Hide posts in the user section
                  }
                },
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Posts:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _searchResults.length,
                itemBuilder: (context, index) {
                  // Display search results for posts
                  if (_searchResults[index]['type'] == 'post') {
                    return GestureDetector(
                      onTap: () {
                        // Navigate to post details page or implement desired action
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: SizedBox(
                          width: double.infinity,
                          child: GestureDetector(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 24,
                                      backgroundImage: _searchResults[index]
                                                  .containsKey('postType') &&
                                              _searchResults[index]
                                                      ['postType'] ==
                                                  'Audio'
                                          ? const AssetImage('assets/audio.png')
                                              as ImageProvider<Object>
                                          : NetworkImage(
                                              _searchResults[index]['imageUrl'],
                                            ),
                                    ),
                                    const SizedBox(width: 16),
                                    Text(_searchResults[index]['caption']),
                                  ],
                                ),
                                const SizedBox(
                                    height:
                                        8), // Add spacing between caption and username
                                FutureBuilder<DocumentSnapshot>(
                                  future: FirebaseFirestore.instance
                                      .collection('users')
                                      .doc(_searchResults[index]['userId'])
                                      .get(),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return Text(
                                          'Loading...'); // Placeholder for loading state
                                    } else if (snapshot.hasError) {
                                      return Text('Error: ${snapshot.error}');
                                    } else {
                                      String username =
                                          snapshot.data!['username'] ??
                                              'Unknown User';
                                      return Text('Posted by: $username');
                                    }
                                  },
                                ),
                              ],
                            ),
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => SinglePostScreen(
                                          postId: _searchResults[index]
                                              ['postId'])));
                            },
                          ),
                        ),
                      ),
                    );
                  } else {
                    return const SizedBox
                        .shrink(); // Hide users in the post section
                  }
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: 1, // Set the index for Profile tab
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
