//lib/widgets/carta/categorias_dialog.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../custom_textfield.dart';

class CategoriasDialog extends StatefulWidget {
  final DocumentSnapshot? item;

  const CategoriasDialog({super.key, this.item});

  @override
  State<CategoriasDialog> createState() => _CategoriasDialogState();
}

class _CategoriasDialogState extends State<CategoriasDialog> {
  final nombreController = TextEditingController();
  final descripcionController = TextEditingController();

  bool estado = true;
  bool cargando = false;

  bool get editando => widget.item != null;

  @override
  void initState() {
    super.initState();

    if (editando) {
      final data = widget.item!.data() as Map<String, dynamic>;

      nombreController.text = data['nombre_cat'] ?? '';
      descripcionController.text = data['descripcion'] ?? '';
      estado = data['estado'] ?? true;
    }
  }

  Future<void> guardarCategoria() async {
    try {
      setState(() {
        cargando = true;
      });

      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        throw Exception("Usuario no autenticado");
      }

      final data = {
        'nombre_cat': nombreController.text.trim(),
        'descripcion': descripcionController.text.trim(),
        'estado': estado,
        'uid_usuario': user.uid,
        'fecha_creacion': Timestamp.now(),
      };

      if (editando) {
        await FirebaseFirestore.instance
            .collection('categorias')
            .doc(widget.item!.id)
            .update(data);
      } else {
        await FirebaseFirestore.instance.collection('categorias').add(data);
      }

      if (mounted) Navigator.pop(context);
    } catch (e) {
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

  Future<void> eliminarCategoria() async {
    await FirebaseFirestore.instance
        .collection('categorias')
        .doc(widget.item!.id)
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
                editando ? "Editar Categoría" : "Nueva Categoría",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                "Gestión de categorías",
                style: TextStyle(color: Colors.white54, fontSize: 13),
              ),

              const SizedBox(height: 24),

              CustomTextField(
                controller: nombreController,
                hint: "Nombre categoría",
                icon: Icons.category,
                borderColor: const Color.fromARGB(255, 111, 114, 255),
              ),

              const SizedBox(height: 12),

              CustomTextField(
                controller: descripcionController,
                hint: "Descripción",
                icon: Icons.description_outlined,
                borderColor: const Color.fromARGB(255, 111, 114, 255),
              ),

              if (editando) ...[
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
              ],

              const SizedBox(height: 24),

              Row(
                children: [
                  if (editando)
                    Expanded(
                      child: ElevatedButton(
                        onPressed: eliminarCategoria,
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
                      onPressed: guardarCategoria,
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
