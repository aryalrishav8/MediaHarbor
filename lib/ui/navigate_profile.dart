import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';
import 'package:mediaharbor/ui/message_screen.dart';
import 'package:mediaharbor/helper/audio_play.dart';
import 'package:mediaharbor/helper/user_stats.dart';
import 'navigatepost.dart';

class UserProfileScreen extends StatefulWidget {
  final String userId;
  final String currentUserId;

  const UserProfileScreen({
    Key? key,
    required this.userId,
    required this.currentUserId,
  }) : super(key: key);

  @override
  _UserProfileScreenState createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  late Future<Map<String, dynamic>> _userDataFuture;
  bool _isFollowing = false;
  late String username;
  late String currUname;

  @override
  void initState() {
    super.initState();
    _userDataFuture = fetchUserData(widget.userId);
    checkIfFollowingUser();
    getCurrUserName();
  }

  Future<void> followUser(String followedUserId) async {
    if (widget.currentUserId == followedUserId) {
      return;
    }
    try {
      DocumentReference currentUserRef = FirebaseFirestore.instance
          .collection('users')
          .doc(widget.currentUserId);
      await currentUserRef.update({
        'following': FieldValue.arrayUnion([followedUserId]),
      });
    } catch (e) {
      print('Error following user: $e');
    }
  }

  Future<List<DocumentSnapshot>> fetchUserPosts() async {
    QuerySnapshot postSnapshot = await FirebaseFirestore.instance
        .collection('posts')
        .where('senderId', isEqualTo: widget.userId)
        .orderBy('date', descending: true)
        .get();
    return postSnapshot.docs;
  }

  Future<void> unfollowUser(String followedUserId) async {
    try {
      DocumentReference currentUserRef = FirebaseFirestore.instance
          .collection('users')
          .doc(widget.currentUserId);
      await currentUserRef.update({
        'following': FieldValue.arrayRemove([followedUserId]),
      });
    } catch (e) {
      print('Error unfollowing user: $e');
    }
  }

  Future<void> checkIfFollowingUser() async {
    try {
      DocumentReference currentUserRef = FirebaseFirestore.instance
          .collection('users')
          .doc(widget.currentUserId);
      DocumentSnapshot currentUserSnapshot = await currentUserRef.get();
      if (currentUserSnapshot.exists) {
        Map<String, dynamic>? userData =
            currentUserSnapshot.data() as Map<String, dynamic>?;

        if (userData != null && userData.containsKey('following')) {
          List<dynamic> followingList = userData['following'];
          setState(() {
            _isFollowing = followingList.contains(widget.userId);
          });
        }
      }
    } catch (e) {
      print('Error checking if following user: $e');
    }
  }

  Future<Map<String, dynamic>> fetchUserData(String userId) async {
    try {
      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();
      if (userSnapshot.exists) {
        Map<String, dynamic> userData =
            userSnapshot.data() as Map<String, dynamic>;
        return userData;
      } else {
        return {};
      }
    } catch (e) {
      print('Error fetching user data: $e');
      return {};
    }
  }

  Future<void> getCurrUserName() async {
    DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.currentUserId)
        .get();
    if (userSnapshot.exists) {
      Map<String, dynamic> userData =
          userSnapshot.data() as Map<String, dynamic>;
      currUname = userData['username'];
    }
  }

  void sendMessage() {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => MessageScreen(
                senderId: widget.currentUserId,
                senderUsername: currUname,
                receiverId: widget.userId,
                receiverUsername: username)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: FutureBuilder<Map<String, dynamic>>(
          future: _userDataFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Text('Loading...');
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else {
              String username = snapshot.data!['username'] ?? '';
              return Text(username);
            }
          },
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FutureBuilder<Map<String, dynamic>>(
            future: _userDataFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else {
                username = snapshot.data!['username'] ?? '';
                String profilePictureUrl =
                    snapshot.data!['profilePictureUrl'] ?? '';
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Center(
                        child: CircleAvatar(
                          radius: 60,
                          backgroundImage: profilePictureUrl.isNotEmpty
                              ? NetworkImage(profilePictureUrl)
                              : null,
                          child: profilePictureUrl.isEmpty
                              ? const Icon(Icons.person)
                              : null,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          StreamBuilder<int>(
                            stream: UserStats.getPostCountStream(widget.userId),
                            builder: (context, postCountSnapshot) {
                              return Column(
                                children: [
                                  Text(
                                    postCountSnapshot.hasData
                                        ? postCountSnapshot.data.toString()
                                        : 'Loading...', // Placeholder for loading state
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20),
                                  ),
                                  const Text(
                                    'Posts',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ],
                              );
                            },
                          ),
                          const SizedBox(width: 16),
                          StreamBuilder<int>(
                            stream: UserStats.getFollowersCountStream(
                                widget.userId),
                            builder: (context, followersCountSnapshot) {
                              return Column(
                                children: [
                                  Text(
                                    followersCountSnapshot.hasData
                                        ? followersCountSnapshot.data.toString()
                                        : 'Loading...', // Placeholder for loading state
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20),
                                  ),
                                  const Text(
                                    'Followers',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ],
                              );
                            },
                          ),
                          const SizedBox(width: 16),
                          StreamBuilder<int>(
                            stream: UserStats.getFollowingCountStream(
                                widget.userId),
                            builder: (context, followingCountSnapshot) {
                              return Column(
                                children: [
                                  Text(
                                    followingCountSnapshot.hasData
                                        ? followingCountSnapshot.data.toString()
                                        : 'Loading...', // Placeholder for loading state
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20),
                                  ),
                                  const SizedBox(width: 6),
                                  const Text(
                                    'Following',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ],
                              );
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton(
                            onPressed: () async {
                              if (_isFollowing) {
                                await unfollowUser(widget.userId);
                              } else {
                                await followUser(widget.userId);
                              }
                              setState(() {
                                _isFollowing = !_isFollowing;
                              });
                            },
                            child: Text(
                              _isFollowing ? 'Following' : 'Follow',
                            ),
                          ),
                          ElevatedButton(
                            onPressed: sendMessage,
                            child: const Text('Message'),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }
            },
          ),
          Expanded(
            child: FutureBuilder<List<DocumentSnapshot>>(
              future: fetchUserPosts(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No posts available'));
                } else {
                  return ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      DocumentSnapshot document = snapshot.data![index];
                      String postType = document['type'];
                      String postPath = document['path'] ?? '';
                      String postCaption = document['caption'] ?? '';
                      String postId = document.id; // Accessing the document ID

                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: GestureDetector(
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                postType == 'Audio'
                                    ? AudioPlayerWidget(audioUrl: postPath)
                                    : postType == 'Image'
                                        ? Image.network(
                                            postPath,
                                            fit: BoxFit.cover,
                                          )
                                        : Container(), // Empty container if type is neither Audio nor Image
                                const SizedBox(height: 8),
                                Center(
                                  child: Text(
                                    postCaption,
                                    style: TextStyle(fontSize: 16),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        SinglePostScreen(postId: postId)));
                          },
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
