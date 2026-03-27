import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'categorias_dialog.dart';

class CategoriasTab extends StatefulWidget {
  const CategoriasTab({super.key});

  @override
  State<CategoriasTab> createState() => _CategoriasTabState();
}

class _CategoriasTabState extends State<CategoriasTab> {
  String filtroEstado = "todos";

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                flex: 2,
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
                        builder: (_) => const CategoriasDialog(),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                    ),
                    child: const Text(
                      "Nueva Categoria",
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
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
                          child: Text("Desactivo"),
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
            ],
          ),

          const SizedBox(height: 18),

          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('categorias')
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  );
                }

                List docs = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final item = docs[index];

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
                            child: Text(
                              item['nombre_cat'],
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),

                          IconButton(
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (_) => CategoriasDialog(item: item),
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
