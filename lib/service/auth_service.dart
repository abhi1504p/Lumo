import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  // instance
  final FirebaseAuth _auth = FirebaseAuth.instance;

  //sign
  Future<UserCredential> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw Exception(e);
    }
  }
  //register
  Future<UserCredential>signUpWithEmailAndPassword( String email, String password) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw Exception(e);
    }
  }

Future<void>Signout() async {
    try {
    await _auth.signOut();
  } catch (e) {
    throw Exception(e);
  }
}
}
