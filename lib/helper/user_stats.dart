import 'package:cloud_firestore/cloud_firestore.dart';

class UserStats {
  static Stream<int> getPostCountStream(String userId) async* {
    yield* FirebaseFirestore.instance
        .collection('posts')
        .where('senderId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  static Stream<int> getFollowingCountStream(String userId) async* {
    DocumentSnapshot userSnapshot =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();
    Map<String, dynamic>? userData =
        userSnapshot.data() as Map<String, dynamic>?;
    List<dynamic>? followers = userData?['following'];
    yield followers?.length ?? 0;
  }

  static Stream<int> getFollowersCountStream(String userId) async* {
    QuerySnapshot followingSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('following', arrayContains: userId)
        .get();
    yield followingSnapshot.size;
  }
}
