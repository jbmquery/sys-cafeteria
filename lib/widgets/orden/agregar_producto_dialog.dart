import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AgregarProductoDialog extends StatefulWidget {
  final String pedidoId;

  const AgregarProductoDialog({super.key, required this.pedidoId});

  @override
  State<AgregarProductoDialog> createState() => _AgregarProductoDialogState();
}

class _AgregarProductoDialogState extends State<AgregarProductoDialog> {
  QueryDocumentSnapshot? seleccionado;
  String searchText = "";
  final TextEditingController searchController = TextEditingController();

  Future<void> guardarProducto() async {
    if (seleccionado == null) return;

    final data = seleccionado!.data() as Map<String, dynamic>;

    await FirebaseFirestore.instance
        .collection('pedidos')
        .doc(widget.pedidoId)
        .collection('detalle')
        .add({
          "nombre": data["nombre"] ?? "",
          "precio": (data["precio"] as num).toDouble(),
          "porcion": data["porcion"] ?? "",
          "unidad": data["unidad"] ?? "",
          "nombre_cat": data["nombre_cat"] ?? "",
          "nombre_subcat": data["nombre_subcat"] ?? "",
          "puntos": data["puntos"] ?? 0,
          "abreviado": data["abreviado"] ?? "",
          "observacion": "",
          "es_canjeable": true,
          "estado": "pendiente",
          "canjeado_por": "",
          "cuenta": 0,
          "id_detalle_padre": "",
        });

    if (mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF111827),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        width: 430,
        height: 560,
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              "Agregar Producto",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),

            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: searchController,
                    style: const TextStyle(color: Colors.white),
                    onChanged: (value) {
                      setState(() {
                        searchText = value.toLowerCase();
                      });
                    },
                    decoration: InputDecoration(
                      hintText: "Buscar...",
                      hintStyle: const TextStyle(color: Colors.white54),
                      prefixIcon: const Icon(
                        Icons.search,
                        color: Colors.white54,
                      ),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.05),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 8),

                GestureDetector(
                  onTap: () {
                    searchController.clear();
                    setState(() {
                      searchText = "";
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.close, color: Colors.white70),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('carta')
                    .where('estado', isEqualTo: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final docs = snapshot.data!.docs.where((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    final nombre = (data["nombre"] ?? "")
                        .toString()
                        .toLowerCase();
                    return nombre.contains(searchText);
                  }).toList();

                  return ListView.builder(
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final doc = docs[index];
                      final data = doc.data() as Map<String, dynamic>;

                      final disponible = data["disponibilidad"] ?? true;
                      final esPromo = data["nombre_cat"] == "Promos";

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
                          child: Opacity(
                            opacity: disponible ? 1 : 0.35,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Builder(
                                  builder: (_) {
                                    final porcion = (data["porcion"] ?? "")
                                        .toString()
                                        .trim();
                                    final unidad = (data["unidad"] ?? "")
                                        .toString()
                                        .trim();

                                    String extra = "";

                                    if (porcion.isNotEmpty &&
                                        unidad.isNotEmpty) {
                                      extra = " ($porcion $unidad)";
                                    } else if (porcion.isNotEmpty) {
                                      extra = " ($porcion)";
                                    } else if (unidad.isNotEmpty) {
                                      extra = " ($unidad)";
                                    }

                                    return Text(
                                      "${data["nombre"]}$extra",
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    );
                                  },
                                ),

                                const SizedBox(height: 4),

                                Text(
                                  "${data["nombre_cat"]} - S/ ${(data["precio"] as num).toStringAsFixed(2)}",
                                  style: TextStyle(
                                    color: esPromo
                                        ? Colors.greenAccent
                                        : Colors.white70,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
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
                  child: SizedBox(
                    height: 48,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(
                          color: Color(0xFF00C8AA),
                          width: 1.2,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        backgroundColor: Colors.transparent,
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        "Cancelar",
                        style: TextStyle(color: Color(0xFF00C8AA)),
                      ),
                    ),
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
                      onPressed: guardarProducto,
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
