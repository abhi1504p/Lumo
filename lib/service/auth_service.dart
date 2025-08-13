import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  // instance
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
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
}
