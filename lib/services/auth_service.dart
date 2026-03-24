import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<Map<String, dynamic>?> login(String correo, String password) async {
    try {
      UserCredential cred = await _auth.signInWithEmailAndPassword(
        email: correo,
        password: password,
      );

      String uid = cred.user!.uid;

      DocumentSnapshot userDoc = await _firestore
          .collection('usuarios')
          .doc(uid)
          .get();

      if (!userDoc.exists) {
        return null;
      }

      return userDoc.data() as Map<String, dynamic>;
    } on FirebaseAuthException catch (e) {
      print("Error login: ${e.message}");
      return null;
    }
  }

  User? usuarioActual() {
    return _auth.currentUser;
  }

  Future<void> logout() async {
    await _auth.signOut();
  }
}
