//lib/models/marcar_asistencia/turno_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class TurnoModel {
  final String uidTurno;
  final String nombreTurno;
  final String nombreSede;
  final String horaInicio;
  final String horaFin;
  final int toleranciaMinutos;
  final bool estado;

  TurnoModel({
    required this.uidTurno,
    required this.nombreTurno,
    required this.nombreSede,
    required this.horaInicio,
    required this.horaFin,
    required this.toleranciaMinutos,
    required this.estado,
  });

  factory TurnoModel.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return TurnoModel(
      uidTurno: doc.id,
      nombreTurno: data['nombre_turno'] ?? '',
      nombreSede: data['nombre_sede'] ?? '',
      horaInicio: data['hora_inicio'] ?? '',
      horaFin: data['hora_fin'] ?? '',
      toleranciaMinutos: data['tolerancia_minutos'] ?? 0,
      estado: data['estado'] ?? false,
    );
  }
}
