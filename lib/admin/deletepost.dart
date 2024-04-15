import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mediaharbor/helper/post_operations.dart';

class DeletePostPage extends StatefulWidget {
  @override
  _DeletePostPageState createState() => _DeletePostPageState();
}

class _DeletePostPageState extends State<DeletePostPage> {
  late Stream<List<Map<String, dynamic>>> _postsStream;
  final PostOperations _postOperations = PostOperations();

  @override
  void initState() {
    super.initState();
    _fetchPosts();
  }

  Stream<List<Map<String, dynamic>>> _fetchPosts() async* {
    yield await FirebaseFirestore.instance
        .collection('reports')
        .get()
        .then((snapshot) async {
      List<Map<String, dynamic>> postData = [];

      for (QueryDocumentSnapshot report in snapshot.docs) {
        String postId = report['postId'];
        String reason = report['reason'];

        // Fetch post details from the posts collection using postId
        DocumentSnapshot postSnapshot = await FirebaseFirestore.instance
            .collection('posts')
            .doc(postId)
            .get();

        if (postSnapshot.exists) {
          String path = postSnapshot['path'];
          String senderId = postSnapshot['senderId'];
          String caption = postSnapshot['caption'];

          // Fetch username from the users collection using senderId
          DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
              .collection('users')
              .doc(senderId)
              .get();
          String username = userSnapshot['username'] ??
              ''; // Default value if username is not found

          postData.add({
            'reason': reason,
            'postId': postId,
            'path': path,
            'username': username,
            'caption': caption
          });
        }
      }

      return postData;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Delete Post'),
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _fetchPosts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            List<Map<String, dynamic>> postData = snapshot.data ?? [];
            return ListView.builder(
              itemCount: postData.length,
              itemBuilder: (context, index) {
                String reason = postData[index]['reason'];
                String username = postData[index]['username'];
                String path = postData[index]['path'];
                String postId = postData[index]['postId'];
                String caption = postData[index]['caption'];

                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Card(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16.0, vertical: 8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Reason: $reason'),
                              Text('Uploaded by: $username'),
                            ],
                          ),
                        ),
                        Center(
                          child: Container(
                            width: double.infinity, // Take full width
                            height: 200, // Set height for the image container
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image:
                                    NetworkImage(path), // Load image from URL
                                fit: BoxFit.cover, // Cover the container
                              ),
                            ),
                          ),
                        ),
                        Text("Caption: $caption"),
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment
                                .spaceEvenly, // Center buttons horizontally
                            children: [
                              ElevatedButton(
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: Text('Confirm Deletion'),
                                        content: Text(
                                            'Are you sure you want to delete this post?'),
                                        actions: [
                                          TextButton(
                                            onPressed: () {
                                              Navigator.pop(
                                                  context); // Close the AlertDialog
                                              try {
                                                _deletePost(postId, path);
                                              } catch (e) {
                                                print(
                                                    'Error deleting post: $e');
                                              }
                                            },
                                            child: Text('Yes'),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              Navigator.pop(
                                                  context); // Close the AlertDialog
                                              // Do nothing if "No" is pressed
                                            },
                                            child: Text('No'),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                                child: Text('Delete Post'),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  // Cancel delete post action
                                  Navigator.pop(context);
                                },
                                child: Text('Cancel'),
                              ),
                            ],
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
    );
  }

  Future<void> _deletePost(String postId, String imgUrl) async {
    try {
      final scaffoldMessenger = ScaffoldMessenger.of(context);
      await _postOperations.deletePost(postId, imgUrl, context);
      setState(() {});
      scaffoldMessenger.showSnackBar(
        const SnackBar(
          content: Text('Post deleted successfully'),
        ),
      );
    } catch (e) {
      print('Error deleting post: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error deleting post'),
        ),
      );
    }
  }
}
