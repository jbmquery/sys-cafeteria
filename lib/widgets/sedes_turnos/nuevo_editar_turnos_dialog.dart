import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../custom_textfield.dart';

class NuevoEditarTurnosDialog extends StatefulWidget {
  final DocumentSnapshot? turno;

  const NuevoEditarTurnosDialog({super.key, this.turno});

  @override
  State<NuevoEditarTurnosDialog> createState() =>
      _NuevoEditarTurnosDialogState();
}

class _NuevoEditarTurnosDialogState extends State<NuevoEditarTurnosDialog> {
  final nombreTurnoController = TextEditingController();
  final toleranciaController = TextEditingController();

  String? sedeSeleccionada;
  bool estado = true;

  TimeOfDay? horaInicio;
  TimeOfDay? horaFin;

  bool cargando = false;

  List<String> sedes = [];

  bool get editando => widget.turno != null;

  @override
  void initState() {
    super.initState();

    cargarSedes();

    if (editando) {
      final data = widget.turno!.data() as Map<String, dynamic>;

      nombreTurnoController.text = data['nombre_turno'] ?? '';
      toleranciaController.text = data['tolerancia_minutos'].toString();

      sedeSeleccionada = data['nombre_sede'];
      estado = data['estado'];

      horaInicio = convertirHora(data['hora_inicio']);
      horaFin = convertirHora(data['hora_fin']);
    }
  }

  Future<void> cargarSedes() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('sedes')
        .where('estado', isEqualTo: true)
        .get();

    setState(() {
      sedes = snapshot.docs.map((doc) => doc['nombre_sede'] as String).toList();
    });
  }

  TimeOfDay convertirHora(String hora) {
    final partes = hora.split(":");

    return TimeOfDay(hour: int.parse(partes[0]), minute: int.parse(partes[1]));
  }

  String formatearHora(TimeOfDay hora) {
    final h = hora.hour.toString().padLeft(2, '0');
    final m = hora.minute.toString().padLeft(2, '0');

    return "$h:$m";
  }

  Future<void> seleccionarHora(bool esInicio) async {
    final hora = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (hora != null) {
      setState(() {
        if (esInicio) {
          horaInicio = hora;
        } else {
          horaFin = hora;
        }
      });
    }
  }

  Future<void> guardarTurno() async {
    if (sedeSeleccionada == null || horaInicio == null || horaFin == null)
      return;

    setState(() {
      cargando = true;
    });

    final uid = FirebaseAuth.instance.currentUser!.uid;

    final data = {
      'uid_usuario': uid,
      'nombre_sede': sedeSeleccionada,
      'nombre_turno': nombreTurnoController.text.trim(),
      'hora_inicio': formatearHora(horaInicio!),
      'hora_fin': formatearHora(horaFin!),
      'tolerancia_minutos': int.parse(toleranciaController.text.trim()),
      'estado': estado,
    };

    if (editando) {
      await FirebaseFirestore.instance
          .collection('turnos')
          .doc(widget.turno!.id)
          .update(data);
    } else {
      await FirebaseFirestore.instance.collection('turnos').add(data);
    }

    setState(() {
      cargando = false;
    });

    Navigator.pop(context);
  }

  Future<void> eliminarTurno() async {
    await FirebaseFirestore.instance
        .collection('turnos')
        .doc(widget.turno!.id)
        .delete();

    Navigator.pop(context);
  }

  Widget horaTile(String titulo, TimeOfDay? hora, VoidCallback onTap) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(titulo, style: const TextStyle(color: Colors.white70)),
      subtitle: Text(
        hora != null ? hora.format(context) : "Seleccionar",
        style: const TextStyle(color: Colors.white),
      ),
      trailing: const Icon(Icons.access_time, color: Colors.white54),
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFF111827),
          borderRadius: BorderRadius.circular(28),
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Text(
                editando ? "Editar Turno" : "Nuevo Turno",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 24),

              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color.fromARGB(255, 111, 114, 255),
                  ),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    dropdownColor: const Color(0xFF111827),
                    value: sedeSeleccionada,
                    hint: const Text(
                      "Seleccionar sede",
                      style: TextStyle(color: Colors.white54),
                    ),
                    isExpanded: true,
                    style: const TextStyle(color: Colors.white),
                    items: sedes.map((sede) {
                      return DropdownMenuItem(value: sede, child: Text(sede));
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        sedeSeleccionada = value;
                      });
                    },
                  ),
                ),
              ),

              const SizedBox(height: 12),

              CustomTextField(
                controller: nombreTurnoController,
                hint: "Nombre turno",
                icon: Icons.schedule,
                borderColor: const Color.fromARGB(255, 111, 114, 255),
              ),

              const SizedBox(height: 12),

              horaTile("Hora inicio", horaInicio, () => seleccionarHora(true)),

              horaTile("Hora fin", horaFin, () => seleccionarHora(false)),

              const SizedBox(height: 12),

              CustomTextField(
                controller: toleranciaController,
                hint: "Tolerancia minutos",
                icon: Icons.timer,
                keyboardType: TextInputType.number,
                borderColor: const Color.fromARGB(255, 111, 114, 255),
              ),

              const SizedBox(height: 12),

              SwitchListTile(
                value: estado,
                activeColor: const Color.fromARGB(255, 111, 114, 255),
                onChanged: (v) {
                  setState(() {
                    estado = v;
                  });
                },
                title: const Text(
                  "Estado",
                  style: TextStyle(color: Colors.white),
                ),
              ),

              const SizedBox(height: 24),

              Row(
                children: [
                  if (editando)
                    Expanded(
                      child: ElevatedButton(
                        onPressed: eliminarTurno,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: const Text("Eliminar"),
                      ),
                    ),

                  if (editando) const SizedBox(width: 12),

                  Expanded(
                    child: ElevatedButton(
                      onPressed: guardarTurno,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(
                          255,
                          111,
                          114,
                          255,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: cargando
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text(editando ? "Actualizar" : "Guardar"),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text(
                    "Cerrar",
                    style: TextStyle(color: Colors.white70),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
