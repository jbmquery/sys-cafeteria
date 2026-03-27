import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CartaDialog extends StatefulWidget {
  final DocumentSnapshot? item;

  const CartaDialog({super.key, this.item});

  @override
  State<CartaDialog> createState() => _CartaDialogState();
}

class _CartaDialogState extends State<CartaDialog> {
  final nombreController = TextEditingController();

  bool estado = true;

  bool get editando => widget.item != null;

  Future<void> guardar() async {
    final data = {
      'nombre': nombreController.text.trim(),
      'estado': estado,
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

    Navigator.pop(context);
  }

  Future<void> eliminar() async {
    await FirebaseFirestore.instance
        .collection('carta')
        .doc(widget.item!.id)
        .delete();

    Navigator.pop(context);
  }

  @override
  void initState() {
    super.initState();

    if (editando) {
      final data = widget.item!.data() as Map<String, dynamic>;
      nombreController.text = data['nombre'];
      estado = data['estado'];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF111827),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nombreController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: "Nombre",
                hintStyle: TextStyle(color: Colors.white54),
              ),
            ),

            SwitchListTile(
              value: estado,
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

            ElevatedButton(
              onPressed: guardar,
              child: Text(editando ? "Actualizar" : "Guardar"),
            ),

            if (editando)
              ElevatedButton(
                onPressed: eliminar,
                child: const Text("Eliminar"),
              ),
          ],
        ),
      ),
    );
  }
}
