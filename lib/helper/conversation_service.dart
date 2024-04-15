import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';

class Conversation {
  final String chatId;
  final String senderId;
  final String senderUsername;
  final String receiverId;
  final String receiverUsername;
  final String lastMessage;
  final DateTime timestamp;

  Conversation({
    required this.chatId,
    required this.senderId,
    required this.senderUsername,
    required this.receiverId,
    required this.receiverUsername,
    required this.lastMessage,
    required this.timestamp,
  });
}

class ConversationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final StreamController<List<Conversation>> _conversationStreamController =
      StreamController<List<Conversation>>();

  Stream<List<Conversation>> get conversationStream =>
      _conversationStreamController.stream;

  void dispose() {
    _conversationStreamController.close();
  }

  // Future<void> loadLatestMessagesForUser(String userId) async {
  //   try {
  //     QuerySnapshot chatRoomsSnapshot = await _firestore
  //         .collection('chatroom')
  //         .where('users', arrayContains: userId)
  //         .get();

  //     Map<String, Map<String, dynamic>> latestMessagesMap = {};

  //     for (QueryDocumentSnapshot chatRoom in chatRoomsSnapshot.docs) {
  //       String chatId = chatRoom['chatId'];
  //       String senderId = chatRoom['senderId'];
  //       String senderUsername = chatRoom['senderUsername'];
  //       String receiverId = chatRoom['receiverId'];
  //       String receiverUsername = chatRoom['receiverUsername'];
  //       String lastMessage = chatRoom['message'];
  //       DateTime timestamp = (chatRoom['timestamp'] as Timestamp).toDate();

  //       if (!latestMessagesMap.containsKey(chatId) ||
  //           latestMessagesMap[chatId]!['timestamp'].isBefore(timestamp)) {
  //         latestMessagesMap[chatId] = {
  //           'senderId': senderId,
  //           'senderUsername': senderUsername,
  //           'receiverId': receiverId,
  //           'receiverUsername': receiverUsername,
  //           'lastMessage': lastMessage,
  //           'timestamp': timestamp,
  //         };
  //       }
  //     }

  //     List<Conversation> conversations = latestMessagesMap.entries.map((entry) {
  //       String chatId = entry.key;
  //       Map<String, dynamic> data = entry.value;
  //       return Conversation(
  //         chatId: chatId,
  //         senderId: data['senderId'],
  //         senderUsername: data['senderUsername'],
  //         receiverId: data['receiverId'],
  //         receiverUsername: data['receiverUsername'],
  //         lastMessage: data['lastMessage'],
  //         timestamp: data['timestamp'],
  //       );
  //     }).toList();

  //     conversations.sort((a, b) => b.timestamp.compareTo(a.timestamp));
  //     _conversationStreamController.sink.add(conversations);
  //   } catch (e) {
  //     print('Error fetching latest messages: $e');
  //     _conversationStreamController.sink.addError(e.toString());
  //   }
  // }
  Future<void> loadLatestMessagesForUser(String userId) async {
  try {
    // Create a stream to listen for changes in the chatroom collection
    FirebaseFirestore.instance
        .collection('chatroom')
        .where('users', arrayContains: userId)
        .snapshots()
        .listen((querySnapshot) {
      // Handle the incoming snapshot to update conversations
      _handleSnapshot(querySnapshot);
    });
  } catch (e) {
    print('Error fetching latest messages: $e');
    _conversationStreamController.sink.addError(e.toString());
  }
}

void _handleSnapshot(QuerySnapshot querySnapshot) {
  Map<String, Map<String, dynamic>> latestMessagesMap = {};

  for (QueryDocumentSnapshot chatRoom in querySnapshot.docs) {
    String chatId = chatRoom['chatId'];
    String senderId = chatRoom['senderId'];
    String senderUsername = chatRoom['senderUsername'];
    String receiverId = chatRoom['receiverId'];
    String receiverUsername = chatRoom['receiverUsername'];
    String lastMessage = chatRoom['message'];
    DateTime timestamp = (chatRoom['timestamp'] as Timestamp).toDate();

    if (!latestMessagesMap.containsKey(chatId) ||
        latestMessagesMap[chatId]!['timestamp'].isBefore(timestamp)) {
      latestMessagesMap[chatId] = {
        'senderId': senderId,
        'senderUsername': senderUsername,
        'receiverId': receiverId,
        'receiverUsername': receiverUsername,
        'lastMessage': lastMessage,
        'timestamp': timestamp,
      };
    }
  }

  List<Conversation> conversations = latestMessagesMap.entries.map((entry) {
    String chatId = entry.key;
    Map<String, dynamic> data = entry.value;
    return Conversation(
      chatId: chatId,
      senderId: data['senderId'],
      senderUsername: data['senderUsername'],
      receiverId: data['receiverId'],
      receiverUsername: data['receiverUsername'],
      lastMessage: data['lastMessage'],
      timestamp: data['timestamp'],
    );
  }).toList();

  conversations.sort((a, b) => b.timestamp.compareTo(a.timestamp));
  _conversationStreamController.sink.add(conversations);
}


  void updateConversations(List<Conversation> conversations) {
    _conversationStreamController.add(conversations);
  }
}
