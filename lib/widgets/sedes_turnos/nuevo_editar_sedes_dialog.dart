import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../custom_textfield.dart';

class NuevoEditarSedesDialog extends StatefulWidget {
  final DocumentSnapshot? sede;

  const NuevoEditarSedesDialog({super.key, this.sede});

  @override
  State<NuevoEditarSedesDialog> createState() => _NuevoEditarSedesDialogState();
}

class _NuevoEditarSedesDialogState extends State<NuevoEditarSedesDialog> {
  final nombreController = TextEditingController();
  final direccionController = TextEditingController();
  final capacidadController = TextEditingController();

  final latitudController = TextEditingController();
  final longitudController = TextEditingController();

  String tipoSede = "local";
  bool estado = true;
  bool cargando = false;

  bool get editando => widget.sede != null;

  @override
  void initState() {
    super.initState();

    if (editando) {
      final data = widget.sede!.data() as Map<String, dynamic>;

      nombreController.text = data['nombre_sede'] ?? '';
      direccionController.text = data['direccion'] ?? '';
      capacidadController.text = data['capacidad'].toString();

      tipoSede = data['tipo_sede'] ?? 'local';
      estado = data['estado'] ?? true;

      if (data['ubicacion'] != null) {
        final GeoPoint geo = data['ubicacion'];
        latitudController.text = geo.latitude.toString();
        longitudController.text = geo.longitude.toString();
      }
    }
  }

  Future<void> guardarSede() async {
    try {
      setState(() {
        cargando = true;
      });

      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        throw Exception("Usuario no autenticado");
      }

      final data = {
        'uid_usuario': user.uid,
        'nombre_sede': nombreController.text.trim(),
        'direccion': direccionController.text.trim(),
        'capacidad': int.tryParse(capacidadController.text.trim()) ?? 0,
        'tipo_sede': tipoSede,
        'estado': estado,
        'fecha_creacion': Timestamp.now(),
        'ubicacion': GeoPoint(
          double.tryParse(latitudController.text.trim()) ?? 0,
          double.tryParse(longitudController.text.trim()) ?? 0,
        ),
      };

      if (editando) {
        await FirebaseFirestore.instance
            .collection('sedes')
            .doc(widget.sede!.id)
            .update(data);
      } else {
        await FirebaseFirestore.instance.collection('sedes').add(data);
      }

      if (mounted) Navigator.pop(context);
    } catch (e) {
      print("ERROR FIRESTORE: $e");

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error al guardar: $e")));
    } finally {
      if (mounted) {
        setState(() {
          cargando = false;
        });
      }
    }
  }

  Future<void> eliminarSede() async {
    await FirebaseFirestore.instance
        .collection('sedes')
        .doc(widget.sede!.id)
        .delete();

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFF111827),
          borderRadius: BorderRadius.circular(28),
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Text(
                editando ? "Editar Sede" : "Nueva Sede",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                "Gestión de sedes",
                style: TextStyle(color: Colors.white54, fontSize: 13),
              ),

              const SizedBox(height: 24),

              CustomTextField(
                controller: nombreController,
                hint: "Nombre sede",
                icon: Icons.storefront,
                borderColor: const Color.fromARGB(255, 111, 114, 255),
              ),

              const SizedBox(height: 12),

              CustomTextField(
                controller: direccionController,
                hint: "Dirección",
                icon: Icons.location_on_outlined,
                borderColor: const Color.fromARGB(255, 111, 114, 255),
              ),

              const SizedBox(height: 12),

              CustomTextField(
                controller: capacidadController,
                hint: "Capacidad",
                icon: Icons.groups,
                keyboardType: TextInputType.number,
                borderColor: const Color.fromARGB(255, 111, 114, 255),
              ),

              const SizedBox(height: 12),

              CustomTextField(
                controller: latitudController,
                hint: "Latitud",
                icon: Icons.map,
                keyboardType: TextInputType.number,
                borderColor: const Color.fromARGB(255, 111, 114, 255),
              ),

              const SizedBox(height: 12),

              CustomTextField(
                controller: longitudController,
                hint: "Longitud",
                icon: Icons.map_outlined,
                keyboardType: TextInputType.number,
                borderColor: const Color.fromARGB(255, 111, 114, 255),
              ),

              const SizedBox(height: 12),

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
                    value: tipoSede,
                    isExpanded: true,
                    style: const TextStyle(color: Colors.white),
                    items: const [
                      DropdownMenuItem(value: "casa", child: Text("Casa")),
                      DropdownMenuItem(value: "local", child: Text("Local")),
                      DropdownMenuItem(
                        value: "edificio",
                        child: Text("Edificio"),
                      ),
                      DropdownMenuItem(
                        value: "oficina",
                        child: Text("Oficina"),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        tipoSede = value!;
                      });
                    },
                  ),
                ),
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
                        onPressed: eliminarSede,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text("Eliminar"),
                      ),
                    ),

                  if (editando) const SizedBox(width: 12),

                  Expanded(
                    child: ElevatedButton(
                      onPressed: guardarSede,
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
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
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
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.white24),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
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
