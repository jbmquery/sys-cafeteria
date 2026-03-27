import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'subcategorias_dialog.dart';

class SubcategoriasTab extends StatefulWidget {
  const SubcategoriasTab({super.key});

  @override
  State<SubcategoriasTab> createState() => _SubcategoriasTabState();
}

class _SubcategoriasTabState extends State<SubcategoriasTab> {
  String filtroEstado = "todos";
  String filtroCategoria = "todas";

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                flex: 3,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: filtroEstado,
                      dropdownColor: const Color(0xFF111827),
                      style: const TextStyle(color: Colors.white),
                      items: const [
                        DropdownMenuItem(value: "todos", child: Text("Todos")),
                        DropdownMenuItem(
                          value: "activos",
                          child: Text("Activo"),
                        ),
                        DropdownMenuItem(
                          value: "inactivos",
                          child: Text("Inactivo"),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          filtroEstado = value!;
                        });
                      },
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 10),

              Expanded(
                flex: 4,
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('categorias')
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return Container(
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: const Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        ),
                      );
                    }

                    List categorias = snapshot.data!.docs;

                    categorias = categorias.where((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      return data['estado'] == true;
                    }).toList();

                    categorias.sort((a, b) {
                      final dataA = a.data() as Map<String, dynamic>;
                      final dataB = b.data() as Map<String, dynamic>;

                      return (dataA['nombre_cat'] ?? '').compareTo(
                        dataB['nombre_cat'] ?? '',
                      );
                    });

                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: filtroCategoria,
                          dropdownColor: const Color(0xFF111827),
                          style: const TextStyle(color: Colors.white),
                          items: [
                            const DropdownMenuItem(
                              value: "todas",
                              child: Text("Categorias"),
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
                        builder: (_) => const SubcategoriasDialog(),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                    ),
                    child: const Text(
                      "Nuevo",
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('subcategorias')
                  .orderBy('nombre_cat')
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

                  final estado = data['estado'] ?? true;
                  final categoria = data['nombre_cat'] ?? '';

                  final filtroEstadoOk =
                      filtroEstado == "todos" ||
                      (filtroEstado == "activos" && estado == true) ||
                      (filtroEstado == "inactivos" && estado == false);

                  final filtroCategoriaOk =
                      filtroCategoria == "todas" ||
                      categoria == filtroCategoria;

                  return filtroEstadoOk && filtroCategoriaOk;
                }).toList();

                docs.sort((a, b) {
                  final dataA = a.data() as Map<String, dynamic>;
                  final dataB = b.data() as Map<String, dynamic>;

                  final catCompare = (dataA['nombre_cat'] ?? '').compareTo(
                    dataB['nombre_cat'] ?? '',
                  );

                  if (catCompare != 0) return catCompare;

                  return (dataA['nombre_subcat'] ?? '').compareTo(
                    dataB['nombre_subcat'] ?? '',
                  );
                });

                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final item = docs[index];
                    final data = item.data() as Map<String, dynamic>;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.restaurant_menu,
                            color: Colors.white,
                          ),

                          const SizedBox(width: 14),

                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  data['nombre_subcat'] ?? '',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  data['nombre_cat'] ?? '',
                                  style: const TextStyle(
                                    color: Colors.white54,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          IconButton(
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (_) => SubcategoriasDialog(item: item),
                              );
                            },
                            icon: const Icon(
                              Icons.more_vert,
                              color: Colors.white54,
                            ),
                          ),
                        ],
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
