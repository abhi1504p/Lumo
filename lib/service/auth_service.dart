import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  // instance
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  User ?getCurrentUser(){
    return _auth.currentUser;
  }

  //sign
  Future<UserCredential> signInWithEmailAndPassword(String email,
      String password,) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      _firebaseFirestore.collection("User").doc(userCredential.user!.uid).set({
        'uid': userCredential.user!.uid,
        'email': email,
      }
      ) ;

      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw Exception(e);
    }
  }

  //register
  Future<UserCredential> signUpWithEmailAndPassword(String email,
      String password) async {
    try {
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      _firebaseFirestore.collection("User").doc(userCredential.user!.uid).set({
        'uid': userCredential.user!.uid,
        'email': email,
      }
      ) ;return userCredential;
    } on FirebaseAuthException catch (e) {
      throw Exception(e);
    }
  }

  Future<void> Signout() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw Exception(e);
    }
  }

  // Complete user data deletion
  Future<void> _deleteAllUserData(String userId, String email) async {
    try {
      // 1. Delete all storage files
      try {
        final storageRef = _storage.ref().child('user_files/$userId');
        final ListResult result = await storageRef.listAll();
        for (var item in result.items) {
          await item.delete();
        }
      } catch (e) {
        print('Storage deletion error: ${e.toString()}');
      }

      // 2. Delete all chat rooms and messages
      final chatRooms = await _firebaseFirestore
          .collection("Chats_room")
          .where("participants", arrayContains: userId)
          .get();

      final batch = _firebaseFirestore.batch();

      for (var room in chatRooms.docs) {
        // Delete all messages in the chat room
        final messages = await room.reference.collection("messages").get();
        for (var message in messages.docs) {
          batch.delete(message.reference);
        }
        // Delete the chat room itself
        batch.delete(room.reference);
      }

      // 3. Delete user document and any related collections
      batch.delete(_firebaseFirestore.collection("User").doc(userId));

      // 4. Clear any user-specific collections
      final userSpecificCollections = [
        "user_settings/$userId",
        "user_profiles/$userId",
        "user_preferences/$userId",
      ];

      for (var path in userSpecificCollections) {
        try {
          final doc = await _firebaseFirestore.doc(path).get();
          if (doc.exists) {
            batch.delete(doc.reference);
          }
        } catch (e) {
          print('Error deleting ${path}: ${e.toString()}');
        }
      }

      // Execute all Firestore deletions
      await batch.commit();

      // 5. Clear local storage
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      print('Successfully deleted all user data for $email');
    } catch (e) {
      throw Exception('Error during complete data deletion: ${e.toString()}');
    }
  }

  // Delete user account and all associated data
  Future<void> deleteUserAccount() async {
    try {
      final User? currentUser = _auth.currentUser;
      if (currentUser == null) throw Exception('No user logged in');

      final String userId = currentUser.uid;
      final String email = currentUser.email ?? '';

      // Delete all user data first
      await _deleteAllUserData(userId, email);

      // Delete authentication account
      await currentUser.delete();

      // Sign out
      await Signout();
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        throw Exception('Please re-authenticate before deleting your account');
      }
      throw Exception(e.message);
    } catch (e) {
      throw Exception('Failed to delete account: ${e.toString()}');
    }
  }

  // Check if current user is admin
  bool isAdmin() {
    final currentUser = _auth.currentUser;
    return currentUser?.email == "admin@admin.com";
  }

  // Re-authenticate user (needed for sensitive operations)
  Future<void> reAuthenticateUser(String password) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null || currentUser.email == null) {
        throw Exception('No user logged in');
      }

      final credential = EmailAuthProvider.credential(
        email: currentUser.email!,
        password: password,
      );

      await currentUser.reauthenticateWithCredential(credential);
    } catch (e) {
      throw Exception('Re-authentication failed: ${e.toString()}');
    }
  }

  // Delete another user's account by email (admin only)
  Future<void> deleteUserByEmail(String targetEmail) async {
    try {
      // Check if current user is admin
      if (!isAdmin()) {
        throw Exception('Only admin users can delete other accounts');
      }

      // Get the user data from Firestore
      final userQuery = await _firebaseFirestore
          .collection("User")
          .where("email", isEqualTo: targetEmail)
          .get();

      if (userQuery.docs.isEmpty) {
        throw Exception('User not found');
      }

      final userDoc = userQuery.docs.first;
      final userId = userDoc.get('uid');

      // Prevent admin from being deleted
      if (targetEmail == "admin@admin.com") {
        throw Exception('Admin account cannot be deleted');
      }

      // Delete all user data
      await _deleteAllUserData(userId, targetEmail);

      // Record deletion in audit log
      await _firebaseFirestore
          .collection("DeletedUsers")
          .doc(userId)
          .set({
        'email': targetEmail,
        'deletedAt': FieldValue.serverTimestamp(),
        'deletedBy': _auth.currentUser?.email,
        'dataCleanupComplete': true,
      });

      print('Successfully deleted all user data for $targetEmail');
    } catch (e) {
      throw Exception('Failed to delete user: ${e.toString()}');
    }
  }

  // Function to handle the re-authentication process
  Future<void> reAuthenticateAndDeleteUser(String email, String password) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw Exception('No user logged in');
      }

      // Create credentials
      AuthCredential credential = EmailAuthProvider.credential(
        email: email,
        password: password
      );

      // Re-authenticate
      await currentUser.reauthenticateWithCredential(credential);

      // Now try to delete the user again
      await deleteUserByEmail(email);
    } catch (e) {
      throw Exception('Re-authentication failed: ${e.toString()}');
    }
  }

  // Get a list of deleted users (admin only)
  Future<List<Map<String, dynamic>>> getDeletedUsers() async {
    try {
      if (!isAdmin()) {
        throw Exception('Only admin users can view deleted users');
      }

      final deletedUsers = await _firebaseFirestore
          .collection("DeletedUsers")
          .orderBy('deletedAt', descending: true)
          .get();

      return deletedUsers.docs
          .map((doc) => {
                ...doc.data(),
                'id': doc.id,
              })
          .toList();
    } catch (e) {
      throw Exception('Failed to get deleted users: ${e.toString()}');
    }
  }
}
