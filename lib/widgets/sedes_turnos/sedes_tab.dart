import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'nuevo_editar_sedes_dialog.dart';

class SedesTab extends StatefulWidget {
  const SedesTab({super.key});

  @override
  State<SedesTab> createState() => _SedesTabState();
}

class _SedesTabState extends State<SedesTab> {
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
                child: gradientButton("Nueva Sede", () {
                  showDialog(
                    context: context,
                    builder: (_) => const NuevoEditarSedesDialog(),
                  );
                }),
              ),
              const SizedBox(width: 12),
              Expanded(child: filtroDropdown()),
            ],
          ),

          const SizedBox(height: 18),

          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('sedes')
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  );
                }

                List docs = snapshot.data!.docs;

                docs = docs.where((doc) {
                  final estado = doc['estado'];

                  if (filtroEstado == "activos") return estado == true;
                  if (filtroEstado == "inactivos") return estado == false;

                  return true;
                }).toList();

                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (_, index) {
                    final sede = docs[index];

                    return card(
                      sede['nombre_sede'],
                      sede['capacidad'].toString(),
                      sede['tipo_sede'],
                      () {
                        showDialog(
                          context: context,
                          builder: (_) => NuevoEditarSedesDialog(sede: sede),
                        );
                      },
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

  Widget gradientButton(String text, VoidCallback onTap) {
    return Container(
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
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
        ),
        child: Text(text, style: const TextStyle(color: Colors.black)),
      ),
    );
  }

  Widget filtroDropdown() {
    return Container(
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
          isExpanded: true,
          items: const [
            DropdownMenuItem(value: "todos", child: Text("Todos")),
            DropdownMenuItem(value: "activos", child: Text("Activo")),
            DropdownMenuItem(value: "inactivos", child: Text("Desactivo")),
          ],
          onChanged: (v) {
            setState(() {
              filtroEstado = v!;
            });
          },
        ),
      ),
    );
  }

  Widget card(
    String nombre,
    String capacidad,
    String tipo,
    VoidCallback onTap,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(18),
      ),
      child: ListTile(
        title: Text(nombre, style: const TextStyle(color: Colors.white)),
        subtitle: Text(
          "• Capacidad: $capacidad • Tipo: $tipo",
          style: const TextStyle(color: Colors.white70),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.more_vert, color: Colors.white54),
          onPressed: onTap,
        ),
      ),
    );
  }
}
