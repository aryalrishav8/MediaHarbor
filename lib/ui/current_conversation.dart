import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mediaharbor/helper/conversation_service.dart';
import 'message_screen.dart';

class LatestConversationsScreen extends StatefulWidget {
  final String currentUserId;

  const LatestConversationsScreen({Key? key, required this.currentUserId})
      : super(key: key);

  @override
  _LatestConversationsScreenState createState() =>
      _LatestConversationsScreenState();
}

class _LatestConversationsScreenState extends State<LatestConversationsScreen> {
  final ConversationService _conversationService = ConversationService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _conversationService.loadLatestMessagesForUser(widget.currentUserId);
  }

  Future<String> _getProfilePicture(String userId) async {
    try {
      DocumentSnapshot userData =
          await _firestore.collection('users').doc(userId).get();
      if (userData.exists) {
        String profilePictureUrl = userData['profilePictureUrl'] ?? '';
        return profilePictureUrl;
      } else {
        return ''; // Return empty string if user data not found
      }
    } catch (e) {
      print('Error getting profile picture: $e');
      return ''; // Return empty string in case of error
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Latest Conversations'),
      ),
      body: StreamBuilder<List<Conversation>>(
        stream: _conversationService.conversationStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            List<Conversation> conversations = snapshot.data ?? [];
            if (conversations.isEmpty) {
              return const Center(child: Text('No conversations found.'));
            }
            // return ListView.builder(
            //   itemCount: conversations.length,
            //   itemBuilder: (context, index) {
            //     Conversation conversation = conversations[index];
            //     String username = conversation.senderId == widget.currentUserId
            //         ? conversation.receiverUsername
            //         : conversation.senderUsername;
            //     String currUserName =
            //         conversation.senderId == widget.currentUserId
            //             ? conversation.senderUsername
            //             : conversation.receiverUsername;
            //     String recId = conversation.senderId == widget.currentUserId
            //         ? conversation.receiverId
            //         : conversation.senderId;
            //     String time =
            //         '${conversation.timestamp.hour}:${conversation.timestamp.minute}';
            //     String latestMessage = conversation.lastMessage;

            //     return InkWell(
            //       onTap: () {
            //         _navigateToMessageScreen(
            //           // conversation.senderId,
            //           widget.currentUserId,
            //           currUserName,
            //           // conversation.receiverId,
            //           recId,
            //           username,
            //         );
            //       },
            //       child: Padding(
            //         padding:
            //             const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            //         child: ListTile(
            //           tileColor: Colors.grey[200],
            //           shape: RoundedRectangleBorder(
            //             borderRadius: BorderRadius.circular(12),
            //           ),
            //           contentPadding:
            //               EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            //           title: Row(
            //             crossAxisAlignment: CrossAxisAlignment.start,
            //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //             children: [
            //               Text(
            //                 username,
            //                 style: TextStyle(fontSize: 22),
            //               ),
            //               Text('$time'),
            //             ],
            //           ),
            //           subtitle: Text(latestMessage),
            //         ),
            //       ),
            //     );
            //   },
            // );
            return ListView.builder(
              itemCount: conversations.length,
              itemBuilder: (context, index) {
                Conversation conversation = conversations[index];
                String username = conversation.senderId == widget.currentUserId
                    ? conversation.receiverUsername
                    : conversation.senderUsername;
                String currUserName =
                    conversation.senderId == widget.currentUserId
                        ? conversation.senderUsername
                        : conversation.receiverUsername;
                String recId = conversation.senderId == widget.currentUserId
                    ? conversation.receiverId
                    : conversation.senderId;
                String time =
                    '${conversation.timestamp.hour}:${conversation.timestamp.minute}';
                String latestMessage = conversation.lastMessage;

                return FutureBuilder<String>(
                  future: _getProfilePicture(recId),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else {
                      String profilePictureUrl = snapshot.data ?? '';
                      return InkWell(
                        onTap: () {
                          _navigateToMessageScreen(
                            widget.currentUserId,
                            currUserName,
                            recId,
                            username,
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          child: ListTile(
                            tileColor: Colors.grey[200],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            leading: CircleAvatar(
                              backgroundImage: NetworkImage(profilePictureUrl),
                            ),
                            title: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  username,
                                  style: TextStyle(fontSize: 22),
                                ),
                                Text('$time'),
                              ],
                            ),
                            subtitle: Text(latestMessage),
                          ),
                        ),
                      );
                    }
                  },
                );
              },
            );
          }
        },
      ),
    );
  }

  void _navigateToMessageScreen(
    String senderId,
    String senderUsername,
    String receiverId,
    String receiverUsername,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MessageScreen(
          senderId: senderId,
          senderUsername: senderUsername,
          receiverId: receiverId,
          receiverUsername: receiverUsername,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _conversationService.dispose();
    super.dispose();
  }
}
