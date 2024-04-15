import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mediaharbor/helper/audio_play.dart';
import 'package:mediaharbor/ui/navigate_profile.dart';
import 'comment_screen.dart';
import 'package:mediaharbor/helper/post_operations.dart';
import 'profile_screen.dart';

class SinglePostScreen extends StatefulWidget {
  final String postId;

  const SinglePostScreen({Key? key, required this.postId}) : super(key: key);

  @override
  _SinglePostScreenState createState() => _SinglePostScreenState();
}

class UserProfile {
  final String username;
  final String profilePictureUrl;

  UserProfile({required this.username, required this.profilePictureUrl});
}

class _SinglePostScreenState extends State<SinglePostScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late User? _currentUser;
  // late Future<DocumentSnapshot<Map<String, dynamic>>> _postFuture;

  @override
  void initState() {
    super.initState();
    _getCurrentUser();
  }

  Future<void> _getCurrentUser() async {
    _currentUser = FirebaseAuth.instance.currentUser;
  }

  Future<UserProfile> _getUserProfile(String userId) async {
    try {
      DocumentSnapshot userData = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();
      if (userData.exists) {
        String username = userData['username'] ?? '';
        String profilePictureUrl = userData['profilePictureUrl'] ?? '';
        return UserProfile(
            username: username, profilePictureUrl: profilePictureUrl);
      } else {
        return UserProfile(username: '', profilePictureUrl: '');
      }
    } catch (e) {
      print('Error getting user profile: $e');
      return UserProfile(
          username: '',
          profilePictureUrl: ''); // Return empty data in case of error
    }
  }

  Future<List<Map<String, dynamic>>> _getPosts() async {
    // Fetch posts data from Firestore
    DocumentSnapshot postSnapshot =
        await _firestore.collection('posts').doc(widget.postId).get();

    // Fetch the sender's profile picture URL
    UserProfile userProfile = await _getUserProfile(postSnapshot['senderId']);

    // Build post data with sender's profile picture URL
    List<Map<String, dynamic>> posts = [];
    // Existing post data...
    posts.add({
      'postImageUrl': postSnapshot['path'],
      'postCaption': postSnapshot['caption'] ?? '',
      'postDate': (postSnapshot['date'] as Timestamp).toDate(),
      'postId': postSnapshot.id,
      'type': postSnapshot['type'],
      'senderId': postSnapshot['senderId'],
      'senderProfilePictureUrl': userProfile.profilePictureUrl,
    });

    return posts;
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> _getPostData() async {
    return _firestore.collection('posts').doc(widget.postId).get();
  }

  void _toggleLike(DocumentReference postRef) async {
    DocumentSnapshot postSnapshot = await postRef.get();
    List<dynamic> likes =
        postSnapshot['likes'] ?? []; // Get the current likes list
    String currentUserUid = _currentUser!.uid;
    if (likes.contains(currentUserUid)) {
      likes.remove(
          currentUserUid); // Remove the current user's ID if already liked
    } else {
      likes.add(currentUserUid); // Add the current user's ID if not liked
    }
    await postRef.update({'likes': likes}); // Update likes list in Firestore
  }

  Stream<Map<String, dynamic>> getLikeStream(DocumentReference postRef) {
    return postRef.snapshots().map((snapshot) {
      List<dynamic> likes = snapshot['likes'] ?? [];
      String currentUserUid = _currentUser!.uid;
      bool isLiked = likes.contains(currentUserUid);
      return {'isLiked': isLiked};
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Post Details'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _getPosts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.data!.isEmpty) {
            return const Center(child: Text('Post not found'));
          } else {
            Map<String, dynamic> postData = snapshot.data!.first;
            String senderId = postData['senderId'];
            String postType = postData['type'];
            String postImageUrl = postData['postImageUrl'];
            String postCaption = postData['postCaption'];
            DateTime postDate = postData['postDate'];
            String senderProfilePictureUrl =
                postData['senderProfilePictureUrl'];

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Row(
                          children: [
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => UserProfileScreen(
                                      userId: senderId,
                                      currentUserId: FirebaseAuth
                                              .instance.currentUser?.uid ??
                                          '',
                                    ),
                                  ),
                                );
                              },
                              child: FutureBuilder<String>(
                                future:
                                    _getUserProfile(postData['senderId']).then(
                                  (value) => value.username,
                                ),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return CircularProgressIndicator();
                                  } else if (snapshot.hasError) {
                                    return Text('Error: ${snapshot.error}');
                                  } else {
                                    return Row(
                                      children: [
                                        CircleAvatar(
                                          backgroundImage: NetworkImage(
                                            senderProfilePictureUrl,
                                          ),
                                        ),
                                        const SizedBox(width: 8.0),
                                        Text(
                                          snapshot.data ?? '', // Show username
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    );
                                  }
                                },
                              ),
                            ),
                            
                            
                          ],
                        ),
                      ),
                      if (postType == 'Image')
                        Image.network(
                          postImageUrl,
                          fit: BoxFit.cover,
                        )
                      else if (postType == 'Audio')
                        AudioPlayerWidget(audioUrl: postImageUrl),
                      const SizedBox(height: 16.0),
                      Text(
                        postCaption,
                        style: const TextStyle(fontSize: 18.0),
                      ),
                      const SizedBox(height: 16.0),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: StreamBuilder<DocumentSnapshot>(
                          stream: _firestore
                              .collection('posts')
                              .doc(widget.postId)
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return CircularProgressIndicator();
                            } else if (snapshot.hasError) {
                              return Text('Error: ${snapshot.error}');
                            } else {
                              List<dynamic> likes =
                                  (snapshot.data!.data() as Map)['likes'] ?? [];
                              int likesCount = likes.length;
                              return Text('$likesCount Likes');
                            }
                          },
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          StreamBuilder<Map<String, dynamic>>(
                            stream: getLikeStream(_firestore
                                .collection('posts')
                                .doc(widget.postId)),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return CircularProgressIndicator();
                              } else if (snapshot.hasError) {
                                return Text('Error: ${snapshot.error}');
                              } else {
                                bool isLiked =
                                    snapshot.data?['isLiked'] ?? false;
                                return IconButton(
                                  icon: Icon(Icons.favorite),
                                  color: isLiked ? Colors.red : null,
                                  onPressed: () {
                                    _toggleLike(_firestore
                                        .collection('posts')
                                        .doc(widget.postId));
                                  },
                                );
                              }
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.comment),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      CommentsScreen(postId: widget.postId),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text(
                          _getFormattedDate(postDate),
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }
        },
      ),
      // bottomNavigationBar: BottomNavBar(
      //   currentIndex: 4,
      //   onTabSelected: (int index) {
      //     if (index == 2) {
      //       showUploadOptions(context);
      //     } else if (index == 4) {
      //       Navigator.push(
      //         context,
      //         MaterialPageRoute(builder: (context) => ProfilePage()),
      //       );
      //     } else if (index == 1) {
      //       Navigator.push(
      //         context,
      //         MaterialPageRoute(builder: (context) => SearchScreen()),
      //       );
      //     } else if (index == 0) {
      //       Navigator.pushReplacement(
      //         context,
      //         MaterialPageRoute(builder: (context) => HomePage()),
      //       );
      //     }
      //   },
      // ),
    );
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
}
