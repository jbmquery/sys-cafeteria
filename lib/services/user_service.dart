import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String?> crearUsuario({
    required String nombres,
    required String correo,
    required String password,
    String tipoUsuario = "mozo",
  }) async {
    try {
      UserCredential cred = await _auth.createUserWithEmailAndPassword(
        email: correo,
        password: password,
      );

      String uid = cred.user!.uid;

      await _firestore.collection('usuarios').doc(uid).set({
        'id_usuario': uid,
        'nombres': nombres,
        'correo': correo,
        'tipo_usuario': tipoUsuario,
        'estado': true,
        'fecha_creacion': Timestamp.now(),
      });

      return uid;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        print("Correo ya registrado");
        return "correo_existente";
      }

      print("Error FirebaseAuth: ${e.message}");
      return null;
    } catch (e) {
      print("Error general: $e");
      return null;
    }
  }

  Stream<QuerySnapshot> obtenerUsuarios() {
    return _firestore.collection('usuarios').snapshots();
  }
}
