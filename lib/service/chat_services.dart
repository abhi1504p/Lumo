import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatServices {
  // instance
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // user stream
  Stream<List<Map<String, dynamic>>> getUserStream() {
    return _firebaseFirestore.collection("User").snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        // go through indiviual user
        final user = doc.data();
        // return the user
        return user;
      }).toList();
    });
  }

  //send message

  Future<void> sendMessage(String reciverId, message) async {
    final String currentUserId = _auth.currentUser!.uid;
    final String currentUserEmail = _auth.currentUser!.email!;
    final Timestamp timestamp = Timestamp.now();
  }

  //get message
}
