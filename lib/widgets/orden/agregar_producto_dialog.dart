//lib/widgets/orden/agregar_producto_dialog.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
    final uidActual = FirebaseAuth.instance.currentUser?.uid ?? "";

    final pedidoRef = FirebaseFirestore.instance
        .collection('pedidos')
        .doc(widget.pedidoId);

    /// 🔹 AGREGAR PRODUCTO AL DETALLE
    await pedidoRef.collection('detalle').add({
      "nombre": data["nombre"] ?? data["grupo"] ?? "",
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
      "grupo": data["grupo"] ?? "",
      "uid_usuario": uidActual,
      "codigo_barra": "",
      "vence": "",
    });

    /// 🔹 ESPERAR UN MICRO MOMENTO PARA ASEGURAR SINCRONIZACIÓN
    await Future.delayed(const Duration(milliseconds: 300));

    /// 🔹 OBTENER TODOS LOS DETALLES ACTUALES
    final detalleSnapshot = await pedidoRef.collection('detalle').get();

    double nuevoSubtotal = 0;

    for (final doc in detalleSnapshot.docs) {
      final item = doc.data();

      nuevoSubtotal += ((item["precio"] ?? 0) as num).toDouble();
    }

    /// 🔹 ACTUALIZAR SUBTOTAL EN PEDIDO
    await pedidoRef.update({"monto_subtotal": nuevoSubtotal});

    if (mounted) Navigator.pop(context, true);
  }

  Widget grupoCard(String grupo, List<QueryDocumentSnapshot> items) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              grupo,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

          Wrap(
            spacing: 6,
            children: items.map((doc) {
              final data = doc.data() as Map<String, dynamic>;

              final porcion = (data["porcion"] ?? "").toString().trim();
              final unidad = (data["unidad"] ?? "").toString().trim();

              String texto = "+";

              if (porcion.isNotEmpty && unidad.isNotEmpty) {
                texto = "$porcion $unidad";
              } else if (porcion.isNotEmpty) {
                texto = porcion;
              } else if (unidad.isNotEmpty) {
                texto = unidad;
              }

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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    gradient: seleccionado?.id == doc.id
                        ? const LinearGradient(
                            colors: [Color(0xFF00C8AA), Color(0xFF00A896)],
                          )
                        : disponible
                        ? null
                        : const LinearGradient(
                            colors: [
                              Color.fromARGB(255, 243, 59, 157),
                              Color.fromARGB(255, 200, 6, 109),
                            ],
                          ),
                    color: seleccionado?.id == doc.id
                        ? null
                        : Colors.white.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    texto,
                    style: TextStyle(
                      color: seleccionado?.id == doc.id
                          ? Colors.black
                          : Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
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

                    final grupo = (data["grupo"] ?? "")
                        .toString()
                        .toLowerCase();
                    final nombre = (data["nombre"] ?? "")
                        .toString()
                        .toLowerCase();

                    return grupo.contains(searchText) ||
                        nombre.contains(searchText);
                  }).toList();

                  final Map<String, List<QueryDocumentSnapshot>> agrupados = {};

                  for (var doc in docs) {
                    final data = doc.data() as Map<String, dynamic>;
                    final grupo = data["grupo"] ?? "";

                    agrupados.putIfAbsent(grupo, () => []);
                    agrupados[grupo]!.add(doc);
                  }

                  return ListView(
                    children: agrupados.entries.map((entry) {
                      return grupoCard(entry.key, entry.value);
                    }).toList(),
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
