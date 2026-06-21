//lib/services/marcar_asistencia/asistencia_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class AsistenciaService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<DocumentSnapshot?> getAsistenciaHoy({
    required String uidUsuario,
    required String fechaKey,
    required String uidTurno,
  }) async {
    final snap = await _db
        .collection('usuarios')
        .doc(uidUsuario)
        .collection('asistencia')
        .where('fecha_key', isEqualTo: fechaKey)
        .where('uid_turno', isEqualTo: uidTurno)
        .limit(1)
        .get();

    if (snap.docs.isEmpty) return null;
    return snap.docs.first;
  }

  Future<void> marcarEntrada({
    required String uidUsuario,
    required Map<String, dynamic> data,
  }) async {
    await _db
        .collection('usuarios')
        .doc(uidUsuario)
        .collection('asistencia')
        .add(data);
  }

  Future<void> marcarSalida({
    required String uidUsuario,
    required String docId,
    required DateTime horaSalida,
    required int segundosTardanza,
    required String estado,
  }) async {
    await _db
        .collection('usuarios')
        .doc(uidUsuario)
        .collection('asistencia')
        .doc(docId)
        .update({
          'hora_fin_marcado': Timestamp.fromDate(horaSalida),
          'estado': estado,
          'tiempo_tardanza': segundosTardanza,
        });
  }
}
