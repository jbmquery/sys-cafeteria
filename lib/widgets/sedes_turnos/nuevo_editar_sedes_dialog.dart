import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NuevoEditarSedesDialog extends StatefulWidget {
  final DocumentSnapshot? sede;

  const NuevoEditarSedesDialog({super.key, this.sede});

  @override
  State<NuevoEditarSedesDialog> createState() => _NuevoEditarSedesDialogState();
}

class _NuevoEditarSedesDialogState extends State<NuevoEditarSedesDialog> {
  final nombre = TextEditingController();
  final direccion = TextEditingController();
  final capacidad = TextEditingController();

  String tipoSede = "local";
  bool estado = true;

  Future<void> guardar() async {
    await FirebaseFirestore.instance.collection('sedes').add({
      'nombre_sede': nombre.text,
      'direccion': direccion.text,
      'capacidad': int.tryParse(capacidad.text) ?? 0,
      'tipo_sede': tipoSede,
      'estado': estado,
      'fecha_creacion': DateTime.now(),
    });

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        padding: const EdgeInsets.all(24),
        color: const Color.fromARGB(255, 38, 86, 188),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nombre),
            TextField(controller: direccion),
            TextField(controller: capacidad),

            ElevatedButton(onPressed: guardar, child: const Text("Guardar")),
          ],
        ),
      ),
    );
  }
}
