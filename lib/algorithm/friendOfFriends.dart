// import 'package:cloud_firestore/cloud_firestore.dart';

// Future<List<Map<String, dynamic>>> recommendUsers(
//     String userId, int maxRecommendations) async {
//   List<String> following = [];

//   // Get the list of users the current user is following
//   DocumentSnapshot<Map<String, dynamic>> userSnapshot =
//       await FirebaseFirestore.instance.collection('users').doc(userId).get();
//   if (userSnapshot.exists) {
//     following = List<String>.from(userSnapshot.data()!['following'] ?? []);
//     if (following.isNotEmpty) {
//       print("Following List");
//       following
//           .forEach((id) => print(id)); // Print each id in the following list
//     }
//   }

//   // Initialize a map to store recommended users and their scores
//   Map<String, int> recommendedUsers = {};

//   for (String followedUserId in following) {
//     //list of users the followed user is following
//     print("Followed User: $followedUserId");
//     QuerySnapshot<Map<String, dynamic>> followedUserSnapshot =
//         await FirebaseFirestore.instance
//             .collection('users')
//             .where('id', isEqualTo: followedUserId)
//             .get();
//     List<dynamic> followedUserFollowing = followedUserSnapshot.docs
//         .map((doc) => doc.data()['following'])
//         .toList();

//     if (followedUserFollowing.isNotEmpty) {
//       print("Followed User's Following List is not empty");
//       print(followedUserFollowing); // Print the followed user's following list
//     }

//     // Iterate over each user the followed user is following
//     for (dynamic potentialFriendId in followedUserFollowing) {
//       if (potentialFriendId is String) {
//         // Check if the potential friend is not already followed by the current user and is not the current user
//         if (!following.contains(potentialFriendId) &&
//             potentialFriendId != userId) {
//           // Increment the score of the potential friend based on the number of mutual connections
//           recommendedUsers[potentialFriendId] =
//               (recommendedUsers[potentialFriendId] ?? 0) + 1;
//           print("Count");
//         }
//       }
//     }
//   }

//   // Sort the recommended users based on their scores in descending order
//   List<MapEntry<String, int>> sortedRecommendedUsers =
//       recommendedUsers.entries.toList();
//   sortedRecommendedUsers.sort((a, b) => b.value.compareTo(a.value));
//   if (sortedRecommendedUsers.isNotEmpty) {
//     print("Sorted Recommended Users not Empty");
//   }

//   // Limit the number of recommendations
//   sortedRecommendedUsers =
//       sortedRecommendedUsers.take(maxRecommendations).toList();
//   if (sortedRecommendedUsers.isNotEmpty) {
//     print("Sorted Users is not empty");
//   }

//   // Get the user data for the recommended users
//   List<Map<String, dynamic>> recommendedUsersData = [];
//   for (MapEntry<String, int> entry in sortedRecommendedUsers) {
//     QuerySnapshot<Map<String, dynamic>> userSnapshot = await FirebaseFirestore
//         .instance
//         .collection('users')
//         .where('id', isEqualTo: entry.key)
//         .get();
//     if (userSnapshot.docs.isNotEmpty) {
//       QueryDocumentSnapshot<Map<String, dynamic>> userData =
//           userSnapshot.docs.first;
//       recommendedUsersData.add(userData.data());
//     }
//   }

//   return recommendedUsersData;
// }

import 'package:cloud_firestore/cloud_firestore.dart';

Future<List<Map<String, dynamic>>> recommendUsers(
    String userId, int maxRecommendations) async {
  List<String> following = [];

  // Get the list of users the current user is following
  DocumentSnapshot<Map<String, dynamic>> userSnapshot =
      await FirebaseFirestore.instance.collection('users').doc(userId).get();
  if (userSnapshot.exists) {
    following = List<String>.from(userSnapshot.data()!['following'] ?? []);
    if (following.isNotEmpty) {
      print("Following List");
      following
          .forEach((id) => print(id)); // Print each id in the following list
    }
  }

  // Initialize a map to store recommended users and their scores
  Map<String, int> recommendedUsers = {};

  for (String followedUserId in following) {
    // Get the list of users the followed user is following
    print("Followed User: $followedUserId");
    QuerySnapshot<Map<String, dynamic>> followedUserSnapshot =
        await FirebaseFirestore.instance
            .collection('users')
            .where('id', isEqualTo: followedUserId)
            .get();
    List<dynamic> followedUserFollowing = followedUserSnapshot.docs
        .map((doc) => List<dynamic>.from(doc.data()['following'] ?? []))
        .expand((list) => list)
        .toList();

    if (followedUserFollowing.isNotEmpty) {
      print("Followed User's Following List is not empty");
      print(followedUserFollowing); // Print the followed user's following list
    }

    // Iterate over each user the followed user is following
    for (dynamic potentialFriendId in followedUserFollowing) {
      if (potentialFriendId is String) {
        // Check if the potential friend is not already followed by the current user and is not the current user
        if (!following.contains(potentialFriendId) &&
            potentialFriendId != userId) {
          // Increment the score of the potential friend based on the number of mutual connections
          recommendedUsers[potentialFriendId] =
              (recommendedUsers[potentialFriendId] ?? 0) + 1;
          print("Count");
        }
      }
    }
  }

  // Sort the recommended users based on their scores in descending order
  List<MapEntry<String, int>> sortedRecommendedUsers =
      recommendedUsers.entries.toList();
  sortedRecommendedUsers.sort((a, b) => b.value.compareTo(a.value));
  if (sortedRecommendedUsers.isNotEmpty) {
    print("Sorted Recommended Users not Empty");
  }

  // Limit the number of recommendations
  sortedRecommendedUsers =
      sortedRecommendedUsers.take(maxRecommendations).toList();
  if (sortedRecommendedUsers.isNotEmpty) {
    print("Sorted Users is not empty");
  }

  // Get the user data for the recommended users
  List<Map<String, dynamic>> recommendedUsersData = [];
  for (MapEntry<String, int> entry in sortedRecommendedUsers) {
    QuerySnapshot<Map<String, dynamic>> userSnapshot = await FirebaseFirestore
        .instance
        .collection('users')
        .where('id', isEqualTo: entry.key)
        .get();
    if (userSnapshot.docs.isNotEmpty) {
      QueryDocumentSnapshot<Map<String, dynamic>> userData =
          userSnapshot.docs.first;
      recommendedUsersData.add(userData.data());
    }
  }

  return recommendedUsersData;
}
