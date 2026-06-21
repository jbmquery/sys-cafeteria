//lib/pages/marcar_asistencia_page.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../services/marcar_asistencia/asistencia_service.dart';
import '../models/marcar_asistencia/turno_model.dart';
import '../widgets/app_sidebar.dart';
import '../widgets/app_navbar.dart';

class MarcarAsistenciaPage extends StatefulWidget {
  const MarcarAsistenciaPage({super.key});

  @override
  State<MarcarAsistenciaPage> createState() => _MarcarAsistenciaPageState();
}

class _MarcarAsistenciaPageState extends State<MarcarAsistenciaPage>
    with SingleTickerProviderStateMixin {
  final _service = AsistenciaService();
  final uid = FirebaseAuth.instance.currentUser!.uid;

  Position? _position;
  String? _sedeActual;
  String? _uidSede;
  bool _enRango = false;

  TurnoModel? _turnoSeleccionado;
  String? _uidTurnoSeleccionado;

  late AnimationController _controller;
  late Animation<double> _glowAnim;

  @override
  void initState() {
    super.initState();
    _initLocation();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);

    _glowAnim = Tween(
      begin: 20.0,
      end: 40.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  Future<void> _initLocation() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever) return;

    final pos = await Geolocator.getCurrentPosition();
    _position = pos;

    await _verificarSede(pos);
  }

  double _distanceMeters(GeoPoint a, double lat, double lng) {
    return Geolocator.distanceBetween(a.latitude, a.longitude, lat, lng);
  }

  Future<void> _verificarSede(Position pos) async {
    final sedes = await FirebaseFirestore.instance.collection('sedes').get();

    for (final doc in sedes.docs) {
      final data = doc.data();
      final geo = data['ubicacion'] as GeoPoint;

      final dist = _distanceMeters(geo, pos.latitude, pos.longitude);

      if (dist <= 30) {
        setState(() {
          _enRango = true;
          _sedeActual = data['nombre_sede'];
          _uidSede = doc.id;

          _turnoSeleccionado = null;
          _uidTurnoSeleccionado = null;
        });

        return;
      }
    }

    setState(() {
      _enRango = false;
      _sedeActual = "Fuera de rango";
      _uidSede = null;

      _turnoSeleccionado = null;
      _uidTurnoSeleccionado = null;
    });
  }

  String _fechaKey() {
    final now = DateTime.now();
    return "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
  }

  String _hora(DateTime t) =>
      "${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}";

  int _parseHora(String h) {
    final p = h.split(':');
    return int.parse(p[0]) * 60 + int.parse(p[1]);
  }

  String _estadoAsistencia(TurnoModel t, DateTime now) {
    final inicio = _parseHora(t.horaInicio);
    final actual = now.hour * 60 + now.minute;

    final limite = inicio + t.toleranciaMinutos;

    return actual > limite ? "tarde" : "puntual";
  }

  int _tardanzaSegundos(TurnoModel t, DateTime now) {
    final inicio = _parseHora(t.horaInicio);
    final actual = now.hour * 60 + now.minute;

    final limite = inicio + t.toleranciaMinutos;

    if (actual <= limite) return 0;

    return (actual - limite) * 60;
  }

  void _toast(String msg) {
    final overlay = Overlay.of(context);
    late OverlayEntry entry;

    entry = OverlayEntry(
      builder: (_) => Positioned(
        top: 60,
        left: 20,
        right: 20,
        child: Material(
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Colors.redAccent, Colors.deepOrange],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(msg),
          ),
        ),
      ),
    );

    overlay.insert(entry);
    Future.delayed(const Duration(seconds: 1), () => entry.remove());
  }

  Future<void> _marcar() async {
    if (!_enRango || _turnoSeleccionado == null) {
      _toast("Selecciona turno o verifica ubicación");
      return;
    }

    final now = DateTime.now();

    final existente = await _service.getAsistenciaHoy(
      uidUsuario: uid,
      fechaKey: _fechaKey(),
      uidTurno: _turnoSeleccionado!.uidTurno,
    );

    if (existente == null) {
      await _service.marcarEntrada(
        uidUsuario: uid,
        data: {
          'nombre_sede': _sedeActual,
          'uid_sede': _uidSede,
          'nombre_turno': _turnoSeleccionado!.nombreTurno,
          'uid_turno': _turnoSeleccionado!.uidTurno,
          'fecha': Timestamp.fromDate(now),
          'fecha_key': _fechaKey(),
          'hora_inicio_marcado': Timestamp.fromDate(now),
          'hora_fin_marcado': null,
          'hora_inicio': _turnoSeleccionado!.horaInicio,
          'hora_fin': _turnoSeleccionado!.horaFin,
          'estado': _estadoAsistencia(_turnoSeleccionado!, now),
          'tiempo_tardanza': _tardanzaSegundos(_turnoSeleccionado!, now),
        },
      );

      _toast("Entrada registrada");
    } else {
      final data = existente.data() as Map<String, dynamic>;

      if (data['hora_fin_marcado'] != null) {
        _toast("Turno ya cerrado");
        return;
      }

      final entrada = (data['hora_inicio_marcado'] as Timestamp).toDate();

      if (now.difference(entrada).inMinutes < 5) {
        _toast("Debes esperar 5 min");
        return;
      }

      await _service.marcarSalida(
        uidUsuario: uid,
        docId: existente.id,
        horaSalida: now,
        segundosTardanza: 0,
        estado: "cerrado",
      );

      _toast("Salida registrada");
    }

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();

    return Scaffold(
      drawer: const AppSidebar(),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0B0F1A), Color(0xFF111827), Color(0xFF1E293B)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const AppNavbar(),

              const SizedBox(height: 40),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),

                decoration: BoxDecoration(
                  color: _enRango
                      ? Colors.green.withOpacity(0.15)
                      : Colors.orange.withOpacity(0.15),

                  borderRadius: BorderRadius.circular(25),

                  border: Border.all(
                    color: _enRango ? Colors.greenAccent : Colors.orangeAccent,
                  ),
                ),

                child: Text(
                  _sedeActual ?? "Buscando sede...",

                  style: TextStyle(
                    color: _enRango ? Colors.greenAccent : Colors.orangeAccent,

                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),

              const SizedBox(height: 30),

              GestureDetector(
                onTap: _enRango ? _marcar : null,

                child: AnimatedBuilder(
                  animation: _controller,

                  builder: (_, __) {
                    return Container(
                      width: 210,
                      height: 210,

                      decoration: BoxDecoration(
                        shape: BoxShape.circle,

                        color: const Color(0xFF0F172A),

                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.65),
                            blurRadius: 25,
                            spreadRadius: 2,
                            offset: const Offset(0, 10),
                          ),

                          BoxShadow(
                            color: const Color(
                              0xFF06B6D4,
                            ).withOpacity(_enRango ? 0.80 : 0.10),

                            blurRadius: _glowAnim.value,
                            spreadRadius: 2,
                          ),
                        ],
                      ),

                      child: Center(
                        child: Container(
                          width: 200,
                          height: 200,

                          decoration: BoxDecoration(
                            shape: BoxShape.circle,

                            gradient: SweepGradient(
                              colors: _enRango
                                  ? const [
                                      Color(0xFF22D3EE),
                                      Color(0xFF06B6D4),
                                      Color(0xFF0891B2),
                                      Color(0xFF22D3EE),
                                    ]
                                  : const [
                                      Color(0xFF4B5563),
                                      Color(0xFF374151),
                                      Color(0xFF1F2937),
                                      Color(0xFF4B5563),
                                    ],
                            ),
                          ),

                          child: Center(
                            child: Container(
                              width: 165,
                              height: 165,

                              decoration: BoxDecoration(
                                shape: BoxShape.circle,

                                gradient: const LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,

                                  colors: [
                                    Color(0xFF4B5563),
                                    Color(0xFF2A2A2A),
                                  ],
                                ),

                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.45),
                                    blurRadius: 12,
                                  ),
                                ],
                              ),

                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,

                                children: [
                                  Text(
                                    "${now.day}",
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 58,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),

                                  Text(
                                    _mes(now.month),
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 15,
                                      letterSpacing: 2.5,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 30),

              StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('turnos')
                    .where('nombre_sede', isEqualTo: _sedeActual)
                    .where('estado', isEqualTo: true)
                    .snapshots(),
                builder: (context, snap) {
                  if (!snap.hasData) return const SizedBox();

                  final turnos = snap.data!.docs
                      .map((e) => TurnoModel.fromDoc(e))
                      .toList();

                  final existeTurnoSeleccionado = turnos.any(
                    (turno) => turno.uidTurno == _uidTurnoSeleccionado,
                  );

                  final valueDropdown = existeTurnoSeleccionado
                      ? _uidTurnoSeleccionado
                      : null;

                  return Container(
                    width: 280,

                    padding: const EdgeInsets.symmetric(horizontal: 16),

                    decoration: BoxDecoration(
                      color: const Color(0xFF111827),

                      borderRadius: BorderRadius.circular(10),

                      border: Border.all(color: const Color(0xFF22D3EE)),
                    ),

                    child: DropdownButton<String>(
                      value: valueDropdown,

                      isExpanded: true,

                      underline: const SizedBox(),

                      dropdownColor: const Color(0xFF1E293B),

                      style: const TextStyle(color: Colors.white),

                      iconEnabledColor: Colors.white70,

                      hint: const Text(
                        "Selecciona Horario",
                        style: TextStyle(color: Colors.white70),
                      ),

                      items: turnos.map((t) {
                        return DropdownMenuItem<String>(
                          value: t.uidTurno,
                          child: Text(t.nombreTurno),
                        );
                      }).toList(),

                      onChanged: (uidTurno) {
                        if (uidTurno == null) return;

                        final turnoElegido = turnos.firstWhere(
                          (turno) => turno.uidTurno == uidTurno,
                        );

                        setState(() {
                          _uidTurnoSeleccionado = uidTurno;
                          _turnoSeleccionado = turnoElegido;
                        });
                      },
                    ),
                  );
                },
              ),

              const SizedBox(height: 20),

              Text(
                "Hoy es ${_fechaTexto(now)}",
                style: const TextStyle(color: Colors.white70),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _mes(int m) => [
    "ENERO",
    "FEBRERO",
    "MARZO",
    "ABRIL",
    "MAYO",
    "JUNIO",
    "JULIO",
    "AGOSTO",
    "SEPTIEMBRE",
    "OCTUBRE",
    "NOVIEMBRE",
    "DICIEMBRE",
  ][m - 1];

  String _fechaTexto(DateTime d) {
    const dias = [
      "lunes",
      "martes",
      "miércoles",
      "jueves",
      "viernes",
      "sábado",
      "domingo",
    ];
    return "${dias[d.weekday - 1]}, ${d.day} de ${_mes(d.month).toLowerCase()} de ${d.year}";
  }
}
