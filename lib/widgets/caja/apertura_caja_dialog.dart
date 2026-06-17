//lib/widgets/caja/apertura_caja_dialog.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AperturaCajaDialog extends StatefulWidget {
  const AperturaCajaDialog({super.key});

  @override
  State<AperturaCajaDialog> createState() => _AperturaCajaDialogState();
}

class _AperturaCajaDialogState extends State<AperturaCajaDialog> {
  @override
  void initState() {
    super.initState();

    cargarUsuario();
  }

  final observacionController = TextEditingController();

  final montoController = TextEditingController(text: "0");

  bool cargando = false;

  String? sedeSeleccionada;
  String? turnoSeleccionado;

  String? sedeIdSeleccionada;
  String? turnoIdSeleccionado;
  String apodoUsuario = "Cargando...";
  bool cargandoUsuario = true;

  double get montoApertura {
    return double.tryParse(montoController.text.trim()) ?? 0;
  }

  Future<void> cargarUsuario() async {
    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) return;

      final doc = await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(user.uid)
          .get();

      if (!doc.exists) {
        setState(() {
          apodoUsuario = "Sin usuario";
          cargandoUsuario = false;
        });

        return;
      }

      final data = doc.data()!;

      setState(() {
        apodoUsuario = data['apodo'] ?? "Sin apodo";
        cargandoUsuario = false;
      });
    } catch (e) {
      setState(() {
        apodoUsuario = "Error usuario";
        cargandoUsuario = false;
      });
    }
  }

  Future<void> guardarApertura() async {
    try {
      setState(() {
        cargando = true;
      });

      final user = FirebaseAuth.instance.currentUser;

      final apodo = cargandoUsuario ? "Cargando..." : apodoUsuario;

      // Crear documento principal de caja
      final cajaRef = await FirebaseFirestore.instance.collection('caja').add({
        'uid_usuario_apertura': user?.uid ?? '',
        'apodo_apertura': apodo,
        'fecha': Timestamp.now(),
        'sede': sedeSeleccionada ?? '',
        'turno': turnoSeleccionado ?? '',
        'observacion_apertura': observacionController.text.trim(),
        'estado': true,
      });

      // Crear registro en subcolección resumen
      await cajaRef.collection('resumen').add({
        'monto_apertura': montoApertura,
      });

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      if (mounted) {
        setState(() {
          cargando = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    final apodo = cargandoUsuario ? "Cargando..." : apodoUsuario;

    final now = DateTime.now();

    final fecha =
        "${now.day.toString().padLeft(2, '0')}/"
        "${now.month.toString().padLeft(2, '0')}/"
        "${now.year}";

    final hora =
        "${now.hour.toString().padLeft(2, '0')}:"
        "${now.minute.toString().padLeft(2, '0')}";

    return Dialog(
      backgroundColor: Colors.transparent,

      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),

      child: Container(
        padding: const EdgeInsets.all(22),

        decoration: BoxDecoration(
          color: const Color(0xFF111827),
          borderRadius: BorderRadius.circular(28),
        ),

        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              /// 🔥 TITULO
              const Center(
                child: Text(
                  "Apertura de Caja",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              /// 🔥 INFO SUPERIOR
              Container(
                padding: const EdgeInsets.all(14),

                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),

                  borderRadius: BorderRadius.circular(18),

                  border: Border.all(color: Colors.white.withOpacity(0.04)),
                ),

                child: Row(
                  children: [
                    Expanded(child: _infoColumn("Usuario", apodo)),

                    Expanded(child: _infoColumn("Fecha", fecha)),

                    Expanded(child: _infoColumn("Hora", hora)),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              /// 🏢 SEDES
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('sedes')
                    .where('estado', isEqualTo: true)
                    .snapshots(),

                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final docs = snapshot.data!.docs;

                  return _dropdownContainer(
                    icon: Icons.storefront_outlined,

                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        dropdownColor: const Color(0xFF111827),

                        value: sedeIdSeleccionada,

                        isExpanded: true,

                        hint: const Text(
                          "Seleccionar sede",
                          style: TextStyle(color: Colors.white70),
                        ),

                        style: const TextStyle(color: Colors.white),

                        items: docs.map((doc) {
                          final data = doc.data() as Map<String, dynamic>;

                          final nombreSede =
                              data['nombre_sede']?.toString() ?? '';

                          return DropdownMenuItem<String>(
                            value: doc.id,

                            child: Text(nombreSede),
                          );
                        }).toList(),

                        onChanged: (value) {
                          if (value == null) return;

                          final sedeDoc = docs.firstWhere(
                            (doc) => doc.id == value,
                          );

                          final data = sedeDoc.data() as Map<String, dynamic>;

                          setState(() {
                            sedeIdSeleccionada = value;

                            sedeSeleccionada = data['nombre_sede'] ?? '';

                            /// 🔥 RESETEA TURNO
                            turnoSeleccionado = null;

                            turnoIdSeleccionado = null;
                          });
                        },
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 12),

              /// 🔥 TURNOS
              StreamBuilder<QuerySnapshot>(
                stream: sedeSeleccionada == null
                    ? null
                    : FirebaseFirestore.instance
                          .collection('turnos')
                          .where('estado', isEqualTo: true)
                          .where('nombre_sede', isEqualTo: sedeSeleccionada)
                          .snapshots(),

                builder: (context, snapshot) {
                  if (sedeSeleccionada == null) {
                    return Container(
                      padding: const EdgeInsets.all(16),

                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.04),

                        borderRadius: BorderRadius.circular(16),
                      ),

                      child: const Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: Colors.white54,
                            size: 18,
                          ),

                          SizedBox(width: 10),

                          Text(
                            "Primero selecciona una sede",
                            style: TextStyle(color: Colors.white54),
                          ),
                        ],
                      ),
                    );
                  }

                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final docs = snapshot.data!.docs;

                  return _dropdownContainer(
                    icon: Icons.schedule,

                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        dropdownColor: const Color(0xFF111827),

                        value: turnoIdSeleccionado,

                        isExpanded: true,

                        hint: const Text(
                          "Seleccionar turno",
                          style: TextStyle(color: Colors.white70),
                        ),

                        style: const TextStyle(color: Colors.white),

                        items: docs.map((doc) {
                          final data = doc.data() as Map<String, dynamic>;

                          final nombreTurno =
                              data['nombre_turno']?.toString() ?? '';

                          return DropdownMenuItem<String>(
                            value: doc.id,

                            child: Text(nombreTurno),
                          );
                        }).toList(),

                        onChanged: (value) {
                          if (value == null) return;

                          final turnoDoc = docs.firstWhere(
                            (doc) => doc.id == value,
                          );

                          final data = turnoDoc.data() as Map<String, dynamic>;

                          setState(() {
                            turnoIdSeleccionado = value;

                            turnoSeleccionado = data['nombre_turno'] ?? '';
                          });
                        },
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 20),

              /// 💰 MONTO APERTURA
              Container(
                padding: const EdgeInsets.all(16),

                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),

                  borderRadius: BorderRadius.circular(18),

                  border: Border.all(color: Colors.white.withOpacity(0.04)),
                ),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    const Text(
                      "Monto de apertura",
                      style: TextStyle(color: Colors.white70, fontSize: 13),
                    ),

                    const SizedBox(height: 10),

                    TextField(
                      controller: montoController,

                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),

                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),

                      decoration: InputDecoration(
                        prefixText: "S/ ",

                        prefixStyle: const TextStyle(
                          color: Colors.greenAccent,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),

                        hintText: "0.00",

                        hintStyle: TextStyle(
                          color: Colors.white.withOpacity(0.25),
                        ),

                        filled: true,

                        fillColor: Colors.black.withOpacity(0.18),

                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),

                          borderSide: BorderSide.none,
                        ),

                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),

                          borderSide: BorderSide(
                            color: Colors.white.withOpacity(0.05),
                          ),
                        ),

                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),

                          borderSide: const BorderSide(
                            color: Color.fromARGB(255, 111, 114, 255),
                          ),
                        ),
                      ),

                      onChanged: (_) {
                        setState(() {});
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              /// 📝 OBSERVACION
              TextField(
                controller: observacionController,

                maxLines: 3,

                style: const TextStyle(color: Colors.white),

                decoration: InputDecoration(
                  hintText: "Observación",

                  hintStyle: const TextStyle(color: Colors.white54),

                  filled: true,

                  fillColor: Colors.white.withOpacity(0.05),

                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              /// 🔘 BOTONES
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },

                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.white24),

                        padding: const EdgeInsets.symmetric(vertical: 14),

                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),

                      child: const Text(
                        "Cancelar",
                        style: TextStyle(color: Colors.white70),
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: ElevatedButton(
                      onPressed: cargando ? null : guardarApertura,

                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(
                          255,
                          111,
                          114,
                          255,
                        ),

                        padding: const EdgeInsets.symmetric(vertical: 14),

                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),

                      child: cargando
                          ? const SizedBox(
                              width: 18,
                              height: 18,

                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text("Aceptar"),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _dropdownContainer({required Widget child, required IconData icon}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),

      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),

        borderRadius: BorderRadius.circular(16),

        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),

      child: Row(
        children: [
          Icon(icon, color: Colors.white70, size: 20),

          const SizedBox(width: 10),

          Expanded(child: child),
        ],
      ),
    );
  }

  Widget _infoColumn(String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,

      children: [
        Text(
          title,
          style: const TextStyle(color: Colors.white54, fontSize: 11),
        ),

        const SizedBox(height: 4),

        Text(
          value,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}
