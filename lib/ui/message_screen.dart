import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MessageScreen extends StatefulWidget {
  final String senderId;
  final String senderUsername;
  final String receiverId;
  final String receiverUsername;

  const MessageScreen({
    Key? key,
    required this.senderId,
    required this.senderUsername,
    required this.receiverId,
    required this.receiverUsername,
  }) : super(key: key);

  @override
  _MessageScreenState createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen> {
  TextEditingController messageController = TextEditingController();

  String getChatId(String senderId, String receiverId) {
    List<String> userIds = [senderId, receiverId];
    userIds.sort();
    return userIds.join('_'); // Concatenate sorted user IDs
  }

  @override
  Widget build(BuildContext context) {
    String chatId = getChatId(widget.senderId, widget.receiverId);

    String updatedMessage = '';

    return Scaffold(
      appBar: AppBar(
        title: Text('Chat: ${widget.receiverUsername}'),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('chatroom')
                  .where('chatId', isEqualTo: chatId)
                  .orderBy('timestamp')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else {
                  List<QueryDocumentSnapshot> messages = snapshot.data!.docs;
                  return ListView.builder(
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      String senderId = messages[index]['senderId'];
                      String messageText = messages[index]['message'];
                      // Determine alignment based on sender
                      bool isSentBySender = senderId == widget.senderId;
                      return GestureDetector(
                        onLongPress: () {
                          if (isSentBySender) {
                            // Show options for messages sent by the current user
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Message Options'),
                                content: const Text('Choose an option:'),
                                contentPadding: const EdgeInsets.fromLTRB(
                                    24.0, 20.0, 24.0, 0.0),
                                actions: [
                                  Center(
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        TextButton(
                                          onPressed: () async {
                                            Navigator.pop(context);
                                            showDialog(
                                              context: context,
                                              builder: (context) {
                                                String textFieldValue =
                                                    messages[index]
                                                            ['message'] ??
                                                        '';
                                                TextEditingController
                                                    editController =
                                                    TextEditingController(
                                                        text: textFieldValue);
                                                return StatefulBuilder(
                                                  builder: (context, setState) {
                                                    return AlertDialog(
                                                      title:
                                                          Text('Edit Message'),
                                                      content: TextField(
                                                        controller:
                                                            editController,
                                                        decoration:
                                                            const InputDecoration(
                                                          hintText:
                                                              'Enter your updated message',
                                                        ),
                                                      ),
                                                      actions: [
                                                        TextButton(
                                                          onPressed: () {
                                                            Navigator.pop(
                                                                context);
                                                          },
                                                          child: Text('Cancel'),
                                                        ),
                                                        ElevatedButton(
                                                          onPressed: () async {
                                                            setState(
                                                              () {
                                                                updatedMessage =
                                                                    editController
                                                                        .text;
                                                              },
                                                            );
                                                            editMessage(
                                                                messages[index]
                                                                    .id,
                                                                updatedMessage);
                                                            Navigator.pop(
                                                                context);
                                                          },
                                                          child: Text('Save'),
                                                        ),
                                                      ],
                                                    );
                                                  },
                                                );
                                              },
                                            );
                                          },
                                          child: const Text(
                                            'Edit Message',
                                            style: TextStyle(fontSize: 12),
                                          ),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            // Delete message functionality
                                            Navigator.pop(context);
                                            deleteMessage(messages[index].id);
                                          },
                                          child: const Text(
                                            'Delete Message',
                                            style: TextStyle(fontSize: 12),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }
                        },
                        child: ListTile(
                          title: Align(
                            alignment: isSentBySender
                                ? Alignment.centerRight
                                : Alignment.centerLeft,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color:
                                    isSentBySender ? Colors.blue : Colors.grey,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                messageText,
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: messageController,
                    decoration: const InputDecoration(
                      hintText: 'Type your message...',
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () {
                    sendMessage(chatId);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void sendMessage(String chatId) {
    String messageText = messageController.text.trim();
    if (messageText.isNotEmpty) {
      FirebaseFirestore.instance.collection('chatroom').add({
        'chatId': chatId,
        'senderId': widget.senderId,
        'senderUsername': widget.senderUsername,
        'receiverId': widget.receiverId,
        'receiverUsername': widget.receiverUsername,
        'message': messageText,
        'timestamp': FieldValue.serverTimestamp(),
        'users': [widget.senderId, widget.receiverId],
      });
      messageController.clear();
    }
  }

  Future<void> editMessage(String messageId, String? updatedMessage) async {
    if (updatedMessage != null) {
      try {
        await FirebaseFirestore.instance
            .collection('chatroom')
            .doc(messageId)
            .update({'message': updatedMessage});
        // Handle success
      } catch (e) {
        print('Error updating message: $e');
        // Handle error
      }
    } else {}
  }

  void deleteMessage(String messageId) async {
    try {
      // Reference the specific message document using its ID
      DocumentReference messageRef =
          FirebaseFirestore.instance.collection('chatroom').doc(messageId);

      // Delete the message document
      await messageRef.delete();

      // Show a SnackBar to confirm successful deletion
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Message deleted'),
          duration: Duration(seconds: 2), // Optional: set the duration
        ),
      );
    } catch (e) {
      print('Error deleting message: $e');
      // Handle the error as needed, such as showing an error message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error deleting message'),
          duration: Duration(seconds: 2), // Optional: set the duration
        ),
      );
    }
  }
}
