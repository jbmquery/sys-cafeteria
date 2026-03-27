import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../custom_textfield.dart';

class CartaDialog extends StatefulWidget {
  final DocumentSnapshot? item;

  const CartaDialog({super.key, this.item});

  @override
  State<CartaDialog> createState() => _CartaDialogState();
}

class _CartaDialogState extends State<CartaDialog> {
  final nombreController = TextEditingController();
  final grupoController = TextEditingController();
  final abreviadoController = TextEditingController();
  final precioController = TextEditingController();
  final puntosController = TextEditingController();
  final observacionController = TextEditingController();

  String? categoriaSeleccionada;
  String? subcategoriaSeleccionada;
  String? porcionSeleccionada = "1";
  String? unidadSeleccionada = "Oz";

  bool estado = true;
  bool disponibilidad = true;
  bool cargando = false;

  bool get editando => widget.item != null;

  @override
  void initState() {
    super.initState();

    if (editando) {
      final data = widget.item!.data() as Map<String, dynamic>;

      categoriaSeleccionada = data['nombre_cat'];
      subcategoriaSeleccionada = data['nombre_subcat'];
      nombreController.text = data['nombre'] ?? '';
      grupoController.text = data['grupo'] ?? '';
      abreviadoController.text = data['abreviado'] ?? '';
      precioController.text = data['precio'].toString();
      puntosController.text = data['puntos'].toString();
      porcionSeleccionada = data['porcion'];
      unidadSeleccionada = data['unidad'];
      observacionController.text = data['observacion'] ?? '';
      estado = data['estado'] ?? true;
      disponibilidad = data['disponibilidad'] ?? true;
    }
  }

  Future<void> guardarProducto() async {
    try {
      setState(() {
        cargando = true;
      });

      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        throw Exception("Usuario no autenticado");
      }

      final data = {
        'nombre_cat': categoriaSeleccionada,
        'nombre_subcat': subcategoriaSeleccionada,
        'nombre': nombreController.text.trim(),
        'grupo': grupoController.text.trim(),
        'abreviado': abreviadoController.text.trim(),
        'precio': int.tryParse(precioController.text) ?? 0,
        'puntos': int.tryParse(puntosController.text) ?? 0,
        'porcion': porcionSeleccionada,
        'unidad': unidadSeleccionada,
        'observacion': observacionController.text.trim(),
        'estado': estado,
        'disponibilidad': disponibilidad,
        'uid_usuario': user.uid,
        'fecha_creacion': Timestamp.now(),
      };

      if (editando) {
        await FirebaseFirestore.instance
            .collection('carta')
            .doc(widget.item!.id)
            .update(data);
      } else {
        await FirebaseFirestore.instance.collection('carta').add(data);
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

  Future<void> eliminarProducto() async {
    await FirebaseFirestore.instance
        .collection('carta')
        .doc(widget.item!.id)
        .delete();

    Navigator.pop(context);
  }

  InputDecoration deco(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white70),
      prefixIcon: Icon(icon, color: Colors.white70),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: Colors.white38, width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(
          color: Color.fromARGB(255, 111, 114, 255),
          width: 2,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.90,
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
                editando ? "Editar Producto" : "Nuevo Producto",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 24),

              /// CATEGORIA
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('categorias')
                    .where('estado', isEqualTo: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData)
                    return const CircularProgressIndicator();

                  return DropdownButtonFormField<String>(
                    value: categoriaSeleccionada,
                    dropdownColor: const Color(0xFF1F2937),
                    decoration: deco("Categoría", Icons.category),
                    style: const TextStyle(color: Colors.white),
                    items: snapshot.data!.docs.map((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      return DropdownMenuItem<String>(
                        value: data['nombre_cat'],
                        child: Text(data['nombre_cat']),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        categoriaSeleccionada = value;
                        subcategoriaSeleccionada = null;
                      });
                    },
                  );
                },
              ),

              const SizedBox(height: 12),

              /// SUBCATEGORIA
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('subcategorias')
                    .where('nombre_cat', isEqualTo: categoriaSeleccionada)
                    .where('estado', isEqualTo: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData)
                    return const CircularProgressIndicator();

                  return DropdownButtonFormField<String>(
                    value: subcategoriaSeleccionada,
                    dropdownColor: const Color(0xFF1F2937),
                    decoration: deco("Subcategoría", Icons.label),
                    style: const TextStyle(color: Colors.white),
                    items: snapshot.data!.docs.map((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      return DropdownMenuItem<String>(
                        value: data['nombre_subcat'],
                        child: Text(data['nombre_subcat']),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        subcategoriaSeleccionada = value;
                      });
                    },
                  );
                },
              ),

              const SizedBox(height: 12),

              CustomTextField(
                controller: nombreController,
                hint: "Nombre",
                icon: Icons.fastfood,
              ),
              const SizedBox(height: 12),

              CustomTextField(
                controller: grupoController,
                hint: "Grupo",
                icon: Icons.layers,
              ),
              const SizedBox(height: 12),

              CustomTextField(
                controller: abreviadoController,
                hint: "Abreviado",
                icon: Icons.short_text,
              ),
              const SizedBox(height: 12),

              CustomTextField(
                controller: precioController,
                hint: "Precio",
                icon: Icons.attach_money,
                keyboardType: TextInputType.number,
              ),

              const SizedBox(height: 12),

              CustomTextField(
                controller: puntosController,
                hint: "Puntos",
                icon: Icons.stars,
                keyboardType: TextInputType.number,
              ),

              const SizedBox(height: 12),

              DropdownButtonFormField<String>(
                value: porcionSeleccionada,
                dropdownColor: const Color(0xFF1F2937),
                decoration: deco("Porción", Icons.format_list_numbered),
                style: const TextStyle(color: Colors.white),
                items: ["1", "2", "9", "12", "16", "20"]
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    porcionSeleccionada = value;
                  });
                },
              ),

              const SizedBox(height: 12),

              DropdownButtonFormField<String>(
                value: unidadSeleccionada,
                dropdownColor: const Color(0xFF1F2937),
                decoration: deco("Unidad", Icons.straighten),
                style: const TextStyle(color: Colors.white),
                items: ["Oz"]
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    unidadSeleccionada = value;
                  });
                },
              ),

              const SizedBox(height: 12),

              CustomTextField(
                controller: observacionController,
                hint: "Observación",
                icon: Icons.note,
              ),

              if (editando) ...[
                const SizedBox(height: 12),

                SwitchListTile(
                  value: estado,
                  activeColor: const Color.fromARGB(255, 111, 114, 255),
                  onChanged: (v) => setState(() => estado = v),
                  title: const Text(
                    "Estado",
                    style: TextStyle(color: Colors.white),
                  ),
                ),

                SwitchListTile(
                  value: disponibilidad,
                  activeColor: Colors.greenAccent,
                  onChanged: (v) => setState(() => disponibilidad = v),
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
                        onPressed: eliminarProducto,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                        ),
                        child: const Text("Eliminar"),
                      ),
                    ),

                  if (editando) const SizedBox(width: 12),

                  Expanded(
                    child: ElevatedButton(
                      onPressed: guardarProducto,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(
                          255,
                          111,
                          114,
                          255,
                        ),
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
                  onPressed: () => Navigator.pop(context),
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
