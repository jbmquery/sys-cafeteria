import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EnvasesDialog extends StatefulWidget {
  final String pedidoId;

  const EnvasesDialog({super.key, required this.pedidoId});

  @override
  State<EnvasesDialog> createState() => _EnvasesDialogState();
}

class _EnvasesDialogState extends State<EnvasesDialog> {
  QueryDocumentSnapshot? seleccionado;

  Future<void> guardarEnvase() async {
    if (seleccionado == null) return;

    final data = seleccionado!.data() as Map<String, dynamic>;

    await FirebaseFirestore.instance
        .collection('pedidos')
        .doc(widget.pedidoId)
        .collection('detalle')
        .add({
          "abreviado": data["abreviado"] ?? "",
          "canjeado_por": "",
          "cuenta": 0,
          "es_canjeable": true,
          "estado": "pendiente",
          "id_detalle_padre": "",
          "nombre": data["nombre"] ?? "",
          "nombre_cat": data["nombre_cat"] ?? "",
          "nombre_subcat": data["nombre_subcat"] ?? "",
          "observacion": "",
          "porcion": data["porcion"] ?? "",
          "precio": (data["precio"] as num).toDouble(),
          "puntos": 0,
          "unidad": data["unidad"] ?? "",
        });

    if (mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF111827),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Container(
        padding: const EdgeInsets.all(16),
        height: 500,
        child: Column(
          children: [
            const Text(
              "Seleccionar Envase",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 18),

            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('carta')
                    .where('nombre_cat', isEqualTo: 'Envases')
                    .where('estado', isEqualTo: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final docs = snapshot.data!.docs;

                  return ListView.builder(
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final doc = docs[index];
                      final data = doc.data() as Map<String, dynamic>;

                      final disponible = data["disponibilidad"] ?? true;

                      return GestureDetector(
                        onTap: disponible
                            ? () {
                                setState(() {
                                  seleccionado = doc;
                                });
                              }
                            : null,
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: seleccionado?.id == doc.id
                                ? const Color(0xFF00C8AA).withOpacity(0.18)
                                : Colors.white.withOpacity(0.04),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: seleccionado?.id == doc.id
                                  ? const Color(0xFF00C8AA)
                                  : Colors.transparent,
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  data["nombre"],
                                  style: TextStyle(
                                    color: disponible
                                        ? Colors.white
                                        : Colors.white38,
                                  ),
                                ),
                              ),
                              Text(
                                "S/ ${(data["precio"] as num).toStringAsFixed(2)}",
                                style: TextStyle(
                                  color: disponible
                                      ? Colors.white70
                                      : Colors.white24,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),

            const SizedBox(height: 14),

            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Cancelar"),
                  ),
                ),

                const SizedBox(width: 10),

                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF00C8AA), Color(0xFF00A896)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                      ),
                      onPressed: guardarEnvase,
                      child: const Text(
                        "Guardar",
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
