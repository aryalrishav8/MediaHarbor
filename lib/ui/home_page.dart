import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';
import 'package:mediaharbor/ui/recommend_page.dart';
import 'login_page.dart';
import 'profile_screen.dart';
import 'package:mediaharbor/widgets/bottomnavbar.dart';
import 'package:mediaharbor/widgets/uploadoptions.dart';
import 'search_screen.dart';
import 'package:mediaharbor/helper/audio_play.dart';
import 'current_conversation.dart';
import 'dart:async';
import 'comment_screen.dart';
import 'navigate_profile.dart';
import 'navigatepost.dart';
import 'package:mediaharbor/helper/submitreport.dart';

class UserProfile {
  final String username;
  final String profilePictureUrl;

  UserProfile({required this.username, required this.profilePictureUrl});
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late User? _currentUser;
  List<String> _followingIds = [];
  TextEditingController _reportReasonController = TextEditingController();
  StreamSubscription<List<String>>? _followingStreamSubscription;

  @override
  void initState() {
    super.initState();
    _getCurrentUser();
  }

  @override
  void dispose() {
    super.dispose();
    // Cancel the following stream subscription when the widget is disposed
    _followingStreamSubscription?.cancel();
  }

  // Future<void> _getCurrentUser() async {
  //   _currentUser = _auth.currentUser;
  //   if (_currentUser != null) {
  //     await _getFollowingUsers();
  //   } else {
  //     // Handle the case where the user is not authenticated
  //   }
  // }

  Future<void> _getCurrentUser() async {
    _currentUser = _auth.currentUser;
    if (_currentUser != null) {
      // Start listening to changes in following list
      _followingStreamSubscription =
          _getFollowingUsers().listen((followingIds) {
        setState(() {
          _followingIds = followingIds;
        });
      });
    } else {
      // Handle the case where the user is not authenticated
    }
  }

  Stream<Map<String, dynamic>> getLikeStream(DocumentReference postRef) {
    return postRef.snapshots().map((snapshot) {
      List<dynamic> likes = snapshot['likes'] ?? [];
      String currentUserUid = _currentUser!.uid;
      bool isLiked = likes.contains(currentUserUid);
      return {'isLiked': isLiked};
    });
  }

  // Future<void> _getFollowingUsers() async {
  //   DocumentSnapshot userSnapshot =
  //       await _firestore.collection('users').doc(_currentUser!.uid).get();
  //   if (userSnapshot.exists) {
  //     Map<String, dynamic> userData =
  //         userSnapshot.data() as Map<String, dynamic>;
  //     List<dynamic> followingList = userData['following'] ?? [];
  //     setState(() {
  //       _followingIds = followingList.cast<String>();
  //     });
  //   }
  // }

  Stream<List<String>> _getFollowingUsers() {
    // Listen to changes in the following list for the current user
    return _firestore
        .collection('users')
        .doc(_currentUser!.uid)
        .snapshots()
        .map((userSnapshot) {
      List<dynamic> followingList = userSnapshot['following'] ?? [];
      return followingList.cast<String>();
    });
  }

  // Future<List<Map<String, dynamic>>> _getPosts() async {
  //   if (_followingIds.isEmpty) {
  //     return [];
  //   }
  //   QuerySnapshot postSnapshot = await _firestore
  //       .collection('posts')
  //       .where('senderId', whereIn: _followingIds)
  //       .orderBy('date', descending: true)
  //       .get();

  //   // Fetch the profile picture URLs for each post's sender
  //   List<Future<DocumentSnapshot>> profilePictureFutures = [];
  //   postSnapshot.docs.forEach((postDoc) {
  //     String senderId = postDoc['senderId'];
  //     profilePictureFutures
  //         .add(_firestore.collection('users').doc(senderId).get());
  //   });
  //   List<DocumentSnapshot> profilePictureDocs =
  //       await Future.wait(profilePictureFutures);

  //   // Replace the 'profilePic' field with 'profilePictureUrl' from the user's collection
  //   List<Map<String, dynamic>> posts = [];
  //   for (int i = 0; i < postSnapshot.docs.length; i++) {
  //     DocumentSnapshot postDoc = postSnapshot.docs[i];
  //     DocumentSnapshot profilePicDoc = profilePictureDocs[i];
  //     String postImageUrl = postDoc['path'];
  //     String postCaption = postDoc['caption'] ?? '';
  //     DateTime postDate = (postDoc['date'] as Timestamp).toDate();
  //     String postId = postDoc.id;
  //     String type = postDoc['type'];

  //     // Build the post data with the updated profile picture URL
  //     posts.add({
  //       'postImageUrl': postImageUrl,
  //       'postCaption': postCaption,
  //       'postDate': postDate,
  //       'postId': postId,
  //       'type': type,
  //       'senderId': postDoc['senderId'],
  //       'senderProfilePictureUrl': profilePicDoc['profilePictureUrl'] ?? '',
  //     });
  //   }

  //   return posts;
  // }

  Stream<List<Map<String, dynamic>>> _getPostsStream() {
    if (_followingIds.isEmpty) {
      return Stream.value([]);
    }
    return _firestore
        .collection('posts')
        .where('senderId', whereIn: _followingIds)
        .orderBy('date', descending: true)
        .snapshots()
        .asyncMap((snapshot) async {
      List<Map<String, dynamic>> posts = [];
      for (final postDoc in snapshot.docs) {
        String senderId = postDoc['senderId'];
        DocumentSnapshot profilePicDoc =
            await _firestore.collection('users').doc(senderId).get();
        String postImageUrl = postDoc['path'];
        String postCaption = postDoc['caption'] ?? '';
        DateTime postDate = (postDoc['date'] as Timestamp).toDate();
        String postId = postDoc.id;
        String type = postDoc['type'];

        posts.add({
          'postImageUrl': postImageUrl,
          'postCaption': postCaption,
          'postDate': postDate,
          'postId': postId,
          'type': type,
          'senderId': senderId,
          'senderProfilePictureUrl': profilePicDoc['profilePictureUrl'] ?? '',
        });
      }
      return posts;
    });
  }

  Future<String> getUsernameAndDp(String senderId) async {
    try {
      DocumentSnapshot userData =
          await _firestore.collection('users').doc(senderId).get();
      if (userData.exists) {
        String username = userData['username'] ?? '';
        return username;
      } else {
        return '';
      }
    } catch (e) {
      print('Error getting username: $e');
      return ''; // Return empty strings in case of error
    }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MediaHarbor'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
              icon: const Icon(Icons.messenger),
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => LatestConversationsScreen(
                            currentUserId: _currentUser!.uid)));
              }),
        ],
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _getPostsStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            List<Map<String, dynamic>> posts = snapshot.data!;
            if (posts.isEmpty) {
              return const Center(child: Text("No Posts yet"));
            }
            return ListView.builder(
              itemCount: posts.length,
              itemBuilder: (context, index) {
                Map<String, dynamic> post = posts[index];
                String senderId = post['senderId'];
                String postImageUrl = post['postImageUrl'];
                String postCaption = post['postCaption'] ?? '';
                DateTime postDate = post['postDate'];
                String postId = post['postId'];
                String senderProfilePictureUrl =
                    post['senderProfilePictureUrl'];
                String postType = post['type'];

                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12.0, vertical: 4.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              GestureDetector(
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 16,
                                      backgroundImage:
                                          senderProfilePictureUrl.isNotEmpty
                                              ? NetworkImage(
                                                  senderProfilePictureUrl)
                                              : const AssetImage(
                                                      'assets/person_icon.png')
                                                  as ImageProvider,
                                    ),
                                    const SizedBox(width: 8),
                                    FutureBuilder<String>(
                                      future: getUsernameAndDp(senderId),
                                      builder: (context, snapshot) {
                                        if (snapshot.connectionState ==
                                            ConnectionState.waiting) {
                                          return const CircularProgressIndicator();
                                        } else if (snapshot.hasError) {
                                          return Text(
                                              'Error: ${snapshot.error}');
                                        } else {
                                          String username = snapshot.data ??
                                              ''; // Get username
                                          return Text(
                                            username.isNotEmpty
                                                ? username
                                                : 'Username',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          );
                                        }
                                      },
                                    ),
                                  ],
                                ),
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              UserProfileScreen(
                                                  userId: senderId,
                                                  currentUserId: FirebaseAuth
                                                          .instance
                                                          .currentUser
                                                          ?.uid ??
                                                      '')));
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.more_vert),
                                onPressed: () {
                                  // Show options dialog
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text('More Options'),
                                      content: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          ElevatedButton(
                                            onPressed: () {
                                              // Handle report user
                                              Navigator.pop(
                                                  context); // Close the options dialog

                                              showDialog(
                                                context: context,
                                                builder: (context) =>
                                                    AlertDialog(
                                                  title:
                                                      const Text('Report Post'),
                                                  content: TextField(
                                                    controller:
                                                        _reportReasonController,
                                                    decoration:
                                                        const InputDecoration(
                                                      hintText:
                                                          'Enter the reason to report the Post',
                                                    ),
                                                    maxLines: null,
                                                    keyboardType:
                                                        TextInputType.multiline,
                                                  ),
                                                  actions: [
                                                    TextButton(
                                                      onPressed: () {
                                                        _reportReasonController
                                                            .clear();
                                                        Navigator.pop(
                                                            context); // Close the report form dialog
                                                      },
                                                      child:
                                                          const Text('Cancel'),
                                                    ),
                                                    ElevatedButton(
                                                      onPressed: () {
                                                        String reportReason =
                                                            _reportReasonController
                                                                .text;
                                                        ReportService
                                                            .submitReport(
                                                                context,
                                                                reportReason,
                                                                postId);
                                                        _reportReasonController
                                                            .clear();
                                                        Navigator.pop(
                                                            context); // Close the report form dialog
                                                      },
                                                      child:
                                                          const Text('Submit'),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            },
                                            child: const Text('Report User'),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                        // Padding(
                        //   padding: const EdgeInsets.all(8.0),
                        //   child: Center(
                        //     child: GestureDetector(
                        //       child: Container(
                        //         height: postType == 'Image' ? 300 : 100,
                        //         decoration: const BoxDecoration(
                        //           borderRadius: BorderRadius.vertical(
                        //             top: Radius.circular(12),
                        //           ),
                        //         ),
                        //         child: postType == 'Image'
                        //             ? Image.network(
                        //                 postImageUrl,
                        //                 fit: BoxFit.cover,
                        //               )
                        //             : AudioPlayerWidget(audioUrl: postImageUrl),
                        //       ),
                        //       onTap: () {
                        //         Navigator.push(
                        //           context,
                        //           MaterialPageRoute(
                        //             builder: (context) =>
                        //                 SinglePostScreen(postId: postId),
                        //           ),
                        //         );
                        //       },
                        //     ),
                        //   ),
                        // ),
                        Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Center(
                            child: GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        SinglePostScreen(postId: postId),
                                  ),
                                );
                              },
                              child: Container(
                                height: postType == 'Image' ? 300 : 100,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.vertical(
                                      top: Radius.circular(4),
                                      bottom: Radius.circular(4)),
                                  color: postType == 'Image'
                                      ? Color.fromARGB(255, 56, 54, 54)
                                      : Colors.white,
                                ),
                                child: Center(
                                  child: postType == 'Image'
                                      ? Image.network(
                                          postImageUrl,
                                          fit: BoxFit.cover,
                                        )
                                      : AudioPlayerWidget(
                                          audioUrl: postImageUrl),
                                ),
                              ),
                            ),
                          ),
                        ),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            StreamBuilder<Map<String, dynamic>>(
                              stream: getLikeStream(
                                  _firestore.collection('posts').doc(postId)),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const CircularProgressIndicator();
                                } else if (snapshot.hasError) {
                                  return Text('Error: ${snapshot.error}');
                                } else {
                                  bool isLiked =
                                      snapshot.data?['isLiked'] ?? false;
                                  return IconButton(
                                    icon: const Icon(Icons.favorite),
                                    color: isLiked ? Colors.red : null,
                                    onPressed: () {
                                      _toggleLike(_firestore
                                          .collection('posts')
                                          .doc(postId));
                                    },
                                  );
                                }
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.comment),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        CommentsScreen(postId: postId),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12.0, vertical: 4.0),
                          child: StreamBuilder<DocumentSnapshot>(
                            stream: _firestore
                                .collection('posts')
                                .doc(postId)
                                .snapshots(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const CircularProgressIndicator();
                              } else if (snapshot.hasError) {
                                return Text('Error: ${snapshot.error}');
                              } else {
                                List<dynamic> likes =
                                    (snapshot.data!.data() as Map)['likes'] ??
                                        [];
                                int likesCount = likes.length;
                                return Text('$likesCount Likes');
                              }
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12.0, vertical: 4.0),
                          child: Text(
                            postCaption,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12.0, vertical: 4.0),
                          child: Text(
                            _getFormattedDate(postDate),
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: 0, // Set the index for Home tab
        onTabSelected: (int index) {
          if (index == 2) {
            showUploadOptions(context);
          } else if (index == 4) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ProfilePage()),
            );
          } else if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SearchScreen()),
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
