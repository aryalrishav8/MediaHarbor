import 'package:flutter/material.dart';
import 'package:mediaharbor/helper/post_operations.dart';
import 'package:mediaharbor/ui/edit_post.dart';
import 'package:mediaharbor/ui/recommend_page.dart';
import 'package:mediaharbor/ui/search_screen.dart';
import 'package:mediaharbor/widgets/bottomnavbar.dart';
import 'package:mediaharbor/widgets/uploadoptions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'editprofile.dart';
import 'home_page.dart';
import 'login_page.dart';
import 'dart:async';
import 'package:mediaharbor/helper/audio_play.dart';
import 'package:mediaharbor/helper/user_stats.dart';
import 'navigatepost.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late String _username = '';
  String _profilePictureUrl = '';
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  String userId = '';

  @override
  void initState() {
    super.initState();
    fetchUserDataFromDatabase();
    getUserId();
  }

  void getUserId() {
    User? user = FirebaseAuth.instance.currentUser;
    String uid = user!.uid;
    setState(() {
      userId = uid;
    });
  }

  Stream<QuerySnapshot> getUserPostsStream() {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      return FirebaseFirestore.instance
          .collection('posts')
          .where('senderId', isEqualTo: user.uid)
          .orderBy('date', descending: true)
          .snapshots();
    } else {
      // Return an empty stream if user is not authenticated
      return Stream.empty();
    }
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
        if (userData != null && userData.containsKey('profilePictureUrl')) {
          setState(() {
            _username = userData['username'];
            _profilePictureUrl = userData['profilePictureUrl'];
          });
        } else {
          setState(() {
            _username = userData?['username'] ?? "Error";
            _profilePictureUrl = '';
          });
        }
      } else {
        setState(() {
          _username = "Error";
          _profilePictureUrl = '';
        });
      }
    }
  }

  String _getFormattedDate(DateTime postDate) {
    Duration difference = DateTime.now().difference(postDate);
    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text("Profile"),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => HomePage()),
            );
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              _signOut(context);
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  CircleAvatar(
                    radius: 60,
                    child: _profilePictureUrl.isNotEmpty
                        ? null
                        : Icon(Icons.person, size: 50),
                    backgroundImage: _profilePictureUrl.isNotEmpty
                        ? NetworkImage(_profilePictureUrl)
                        : null,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _username,
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                      const SizedBox(height: 8),
                      StreamBuilder<int>(
                        stream: UserStats.getPostCountStream(userId),
                        builder: (context, snapshot) {
                          return Row(
                            children: [
                              Text(snapshot.data?.toString() ?? '0',
                                  style: TextStyle(fontSize: 16)),
                              SizedBox(width: 8),
                              Text("Posts", style: TextStyle(fontSize: 16)),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 4),
                      StreamBuilder<int>(
                        stream: UserStats.getFollowersCountStream(userId),
                        builder: (context, snapshot) {
                          return Row(
                            children: [
                              Text(snapshot.data?.toString() ?? '0',
                                  style: TextStyle(fontSize: 16)),
                              SizedBox(width: 8),
                              Text("Followers", style: TextStyle(fontSize: 16)),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 4),
                      StreamBuilder<int>(
                        stream: UserStats.getFollowingCountStream(userId),
                        builder: (context, snapshot) {
                          return Row(
                            children: [
                              Text(snapshot.data?.toString() ?? '0',
                                  style: TextStyle(fontSize: 16)),
                              SizedBox(width: 8),
                              Text("Following", style: TextStyle(fontSize: 16)),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EditProfileScreen(
                                currentUsername: _username,
                                currentProfilePictureUrl: _profilePictureUrl,
                              ),
                            ),
                          ).then((newUsername) {
                            if (newUsername != null) {
                              setState(() {
                                _username = newUsername;
                              });
                            }
                          });
                        },
                        child: const Text("Edit Profile"),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                "Posts:",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              StreamBuilder<QuerySnapshot>(
                stream: getUserPostsStream(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else {
                    List<DocumentSnapshot> userPosts = snapshot.data!.docs;
                    if (userPosts.isEmpty) {
                      return Center(
                        child: Text('No posts available'),
                      );
                    }
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: userPosts
                          .map((post) {
                            String postId = post.id;
                            String postType = post['type'];
                            String postImageUrl = post['path'];
                            String postCaption = post['caption'] ?? '';
                            DateTime postDate =
                                (post['date'] as Timestamp).toDate();

                            double postHeight =
                                postType == 'Image' ? 300.0 : 150.0;
                            if (postType == 'Image') {
                              return Container(
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey),
                                  borderRadius: BorderRadius.circular(4.0),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: GestureDetector(
                                    onTap: () {
                                      navigateToPostScreen(postId);
                                    },
                                    onLongPress: () {
                                      showUpOrDelete(postId, postImageUrl,
                                          postCaption, postType);
                                    },
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        Image.network(
                                          postImageUrl,
                                          fit: BoxFit.cover,
                                          height: postHeight,
                                        ),
                                        const SizedBox(
                                          height: 8.0,
                                        ),
                                        Text(
                                          postCaption,
                                          style:
                                              const TextStyle(fontSize: 16.0),
                                        ),
                                        const SizedBox(
                                          height: 10,
                                        ),
                                        Text(
                                          _getFormattedDate(postDate),
                                          style: const TextStyle(
                                              color: Colors.grey),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            } else if (postType == 'Audio') {
                              return Container(
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey),
                                  borderRadius: BorderRadius.circular(4.0),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: GestureDetector(
                                    onTap: () {
                                      navigateToPostScreen(postId);
                                    },
                                    onLongPress: () {
                                      showUpOrDelete(postId, postImageUrl,
                                          postCaption, postType);
                                    },
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        SizedBox(
                                          child: AudioPlayerWidget(
                                            audioUrl: postImageUrl,
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 8.0,
                                        ),
                                        Text(
                                          postCaption,
                                          style:
                                              const TextStyle(fontSize: 16.0),
                                        ),
                                        const SizedBox(
                                          height: 10,
                                        ),
                                        Text(
                                          _getFormattedDate(postDate),
                                          style: const TextStyle(
                                              color: Colors.grey),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }
                            return Container();
                          })
                          .expand(
                              (widget) => [widget, const SizedBox(height: 10)])
                          .toList(), // Add SizedBox between each post
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: 4, // Set the index for Profile tab
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

  Future<void> _signOut(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }

  void navigateToPostScreen(String postId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SinglePostScreen(postId: postId),
      ),
    );
  }

  void showUpOrDelete(
      String postId, String postImageUrl, String caption, String postType) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Options'),
        content: Text('Choose an option:'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => EditPostScreen(
                        postId: postId,
                        imageUrl: postImageUrl,
                        caption: caption,
                        postType: postType)),
              );
            },
            child: Text('Edit Post'),
          ),
          TextButton(
            onPressed: () async {
              // Handle delete post action

              Navigator.pop(context); // Close dialog

              try {
                await showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Confirm Deletion'),
                    content: const Text(
                        'Are you sure you want to delete this post?'),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text('No'),
                      ),
                      TextButton(
                        onPressed: () async {
                          Navigator.pop(context); // Close confirmation dialog

                          final scaffoldMessenger =
                              ScaffoldMessenger.of(context);
                          await PostOperations()
                              .deletePost(postId, postImageUrl, context);

                          // Show SnackBar to indicate successful deletion

                          scaffoldMessenger.showSnackBar(
                            SnackBar(
                              content: Text('Post Deleted Successfully'),
                            ),
                          );

                          // Navigate to ProfilePage after deletion
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ProfilePage(),
                            ),
                          );
                        },
                        child: const Text('Yes'),
                      ),
                    ],
                  ),
                );
              } catch (e) {
                // Handle any errors during deletion
                final scaffoldMessenger = ScaffoldMessenger.of(context);
                scaffoldMessenger.showSnackBar(
                  SnackBar(
                    content: Text('Error deleting post: $e'),
                  ),
                );
              }
            },
            child: const Text('Delete Post'),
          ),
        ],
      ),
    );
  }
}
