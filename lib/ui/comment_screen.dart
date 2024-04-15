import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CommentsScreen extends StatefulWidget {
  final String postId;

  CommentsScreen({required this.postId});

  @override
  _CommentsScreenState createState() => _CommentsScreenState();
}

class _CommentsScreenState extends State<CommentsScreen> {
  final TextEditingController _commentController = TextEditingController();
  late User _currentUser;

  @override
  void initState() {
    super.initState();
    _currentUser = FirebaseAuth.instance.currentUser!;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Comments'),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('comments')
                  .where('postId', isEqualTo: widget.postId)
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                List<DocumentSnapshot> commentDocs = snapshot.data!.docs;
                return ListView.builder(
                  itemCount: commentDocs.length,
                  itemBuilder: (context, index) {
                    String comment = commentDocs[index]['text'];
                    String userId = commentDocs[index]['userId'];
                    Timestamp timestamp = commentDocs[index]['timestamp'];

                    // Calculate time difference
                    Duration difference =
                        DateTime.now().difference(timestamp.toDate());

                    return FutureBuilder<DocumentSnapshot>(
                      future: FirebaseFirestore.instance
                          .collection('users')
                          .doc(userId)
                          .get(),
                      builder: (context, userSnapshot) {
                        if (userSnapshot.connectionState ==
                            ConnectionState.waiting) {
                          return CircularProgressIndicator();
                        }

                        if (userSnapshot.hasError) {
                          return Text('Error: ${userSnapshot.error}');
                        }

                        String username =
                            userSnapshot.data?['username'] ?? 'Unknown';
                        String profilePictureUrl =
                            userSnapshot.data?['profilePictureUrl'] ?? '';

                        return Card(
                          elevation: 3, // Add elevation for shadow
                          margin:
                              EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundImage: profilePictureUrl.isNotEmpty
                                  ? NetworkImage(profilePictureUrl)
                                  : AssetImage(
                                          'assets/default_profile_picture.png')
                                      as ImageProvider,
                            ),
                            title: Text(comment),
                            subtitle: Text(
                                'By: $username - ${_formatTimeDifference(difference)} ago'),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    decoration: InputDecoration(
                      hintText: 'Write a comment...',
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () {
                    String text = _commentController.text.trim();
                    if (text.isNotEmpty) {
                      _submitComment(text);
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimeDifference(Duration difference) {
    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'}';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'}';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'}';
    } else {
      return 'just now';
    }
  }

  void _submitComment(String text) async {
    try {
      CollectionReference commentsRef =
          FirebaseFirestore.instance.collection('comments');
      await commentsRef.add({
        'postId': widget.postId,
        'userId': _currentUser.uid,
        'text': text,
        'timestamp': Timestamp.now(),
      });
      _commentController.clear();
    } catch (e) {
      print('Error adding comment: $e');
      // Handle error
    }
  }
}
