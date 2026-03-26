import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../custom_textfield.dart';

class EditarMesasDialog extends StatefulWidget {
  final DocumentSnapshot? mesa;

  const EditarMesasDialog({super.key, this.mesa});

  @override
  State<EditarMesasDialog> createState() => _EditarMesasDialogState();
}

class _EditarMesasDialogState extends State<EditarMesasDialog> {
  final nombreController = TextEditingController();
  final capacidadController = TextEditingController();

  String tipoMesa = "Mesa";
  bool disponibilidad = true;
  bool cargando = false;

  bool get editando => widget.mesa != null;

  @override
  void initState() {
    super.initState();

    if (editando) {
      final data = widget.mesa!.data() as Map<String, dynamic>;

      nombreController.text = data['nombre_mesa'] ?? '';
      capacidadController.text = data['capacidad'].toString();
      tipoMesa = data['tipo_mesa'] ?? 'Mesa';
      disponibilidad = data['disponibilidad'] ?? true;
    }
  }

  Future<void> guardarMesa() async {
    try {
      setState(() {
        cargando = true;
      });

      final user = FirebaseAuth.instance.currentUser;

      final data = {
        'nombre_mesa': nombreController.text.trim(),
        'capacidad': int.tryParse(capacidadController.text.trim()) ?? 0,
        'tipo_mesa': tipoMesa,
        'disponibilidad': disponibilidad,
        'uid_usuario': user?.uid ?? '',
        'fecha_creacion': Timestamp.now(),
      };

      if (editando) {
        await FirebaseFirestore.instance
            .collection('mesas')
            .doc(widget.mesa!.id)
            .update(data);
      } else {
        await FirebaseFirestore.instance.collection('mesas').add(data);
      }

      if (mounted) Navigator.pop(context);
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

  Future<void> eliminarMesa() async {
    await FirebaseFirestore.instance
        .collection('mesas')
        .doc(widget.mesa!.id)
        .delete();

    Navigator.pop(context);
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
                editando ? "Editar Mesa" : "Nueva Mesa",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 24),

              CustomTextField(
                controller: nombreController,
                hint: "Nombre mesa",
                icon: Icons.table_restaurant,
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
                    value: tipoMesa,
                    isExpanded: true,
                    style: const TextStyle(color: Colors.white),
                    items: const [
                      DropdownMenuItem(value: "Mesa", child: Text("Mesa")),
                      DropdownMenuItem(
                        value: "Delivery",
                        child: Text("Delivery"),
                      ),
                      DropdownMenuItem(value: "Llevar", child: Text("Llevar")),
                      DropdownMenuItem(value: "Prueba", child: Text("Prueba")),
                    ],
                    onChanged: (value) {
                      setState(() {
                        tipoMesa = value!;
                      });
                    },
                  ),
                ),
              ),

              if (editando) ...[
                const SizedBox(height: 12),

                SwitchListTile(
                  value: disponibilidad,
                  activeColor: const Color.fromARGB(255, 111, 114, 255),
                  onChanged: (v) {
                    setState(() {
                      disponibilidad = v;
                    });
                  },
                  title: const Text(
                    "Disponibilidad",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],

              const SizedBox(height: 24),

              Row(
                children: [
                  if (editando)
                    Expanded(
                      child: ElevatedButton(
                        onPressed: eliminarMesa,
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
                      onPressed: guardarMesa,
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
                          : Text(editando ? "Guardar" : "Guardar"),
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
