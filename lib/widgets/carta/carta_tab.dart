import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'carta_dialog.dart';

class CartaTab extends StatefulWidget {
  const CartaTab({super.key});

  @override
  State<CartaTab> createState() => _CartaTabState();
}

class _CartaTabState extends State<CartaTab> {
  String filtroCategoria = "todas";
  String busqueda = "";

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          /// FILA 1
          Row(
            children: [
              Expanded(
                flex: 2,
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('categorias')
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const SizedBox();
                    }

                    List categorias = snapshot.data!.docs.where((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      return data['estado'] == true;
                    }).toList();

                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          isExpanded: true,
                          value: filtroCategoria,
                          dropdownColor: const Color(0xFF111827),
                          style: const TextStyle(color: Colors.white),
                          items: [
                            const DropdownMenuItem(
                              value: "todas",
                              child: Text("Categorías"),
                            ),
                            ...categorias.map((doc) {
                              final data = doc.data() as Map<String, dynamic>;
                              return DropdownMenuItem<String>(
                                value: data['nombre_cat'],
                                child: Text(data['nombre_cat']),
                              );
                            }),
                          ],
                          onChanged: (value) {
                            setState(() {
                              filtroCategoria = value!;
                            });
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(width: 10),

              Expanded(
                flex: 3,
                child: TextField(
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: "Buscar...",
                    hintStyle: const TextStyle(color: Colors.white54),
                    prefixIcon: const Icon(Icons.search, color: Colors.white54),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.05),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      busqueda = value.toLowerCase();
                    });
                  },
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          /// FILA 2
          Row(
            children: [
              Expanded(
                flex: 3,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color.fromARGB(255, 132, 95, 221),
                        Color.fromARGB(255, 111, 114, 255),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: ElevatedButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (_) => const CartaDialog(),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                    ),
                    child: const Text(
                      "Nuevo Producto",
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 10),

              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.upload_file, color: Colors.white),
                ),
              ),

              const SizedBox(width: 10),

              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.download, color: Colors.white),
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          /// LISTA
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('carta')
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  );
                }

                List docs = snapshot.data!.docs;

                docs = docs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;

                  final categoria = data['nombre_cat'] ?? '';

                  final texto =
                      "${data['nombre_cat']} "
                              "${data['nombre_subcat']} "
                              "${data['nombre']} "
                              "${data['grupo']} "
                              "${data['abreviado']} "
                              "${data['precio']} "
                              "${data['puntos']} "
                              "${data['porcion']} "
                              "${data['unidad']} "
                              "${data['observacion']}"
                          .toLowerCase();

                  final filtroCategoriaOk =
                      filtroCategoria == "todas" ||
                      categoria == filtroCategoria;

                  final filtroBusquedaOk =
                      busqueda.isEmpty || texto.contains(busqueda);

                  return filtroCategoriaOk && filtroBusquedaOk;
                }).toList();

                docs.sort((a, b) {
                  final dataA = a.data() as Map<String, dynamic>;
                  final dataB = b.data() as Map<String, dynamic>;
                  return (dataA['nombre'] ?? '').compareTo(
                    dataB['nombre'] ?? '',
                  );
                });

                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final item = docs[index];
                    final data = item.data() as Map<String, dynamic>;

                    final disponible = data['disponibilidad'] ?? true;

                    return GestureDetector(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (_) => CartaDialog(item: item),
                        );
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.fastfood, color: Colors.white),

                            const SizedBox(width: 14),

                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    data['nombre'] ?? '',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),

                                  const SizedBox(height: 4),

                                  Text(
                                    "${data['nombre_cat']} • ${data['precio']} • ${data['porcion']} ${data['unidad']}",
                                    style: const TextStyle(
                                      color: Colors.white54,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: disponible
                                    ? Colors.green.withOpacity(0.2)
                                    : Colors.red.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Text(
                                disponible ? "Disponible" : "No disponible",
                                style: TextStyle(
                                  color: disponible
                                      ? Colors.greenAccent
                                      : Colors.redAccent,
                                  fontSize: 11,
                                ),
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
        ],
      ),
    );
  }
}
