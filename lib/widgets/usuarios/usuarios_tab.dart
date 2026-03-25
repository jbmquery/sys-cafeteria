//lib/widgets/usuarios/usuarios_tab.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/user_service.dart';
import 'nuevo_usuario_dialog.dart';

class UsuariosTab extends StatefulWidget {
  const UsuariosTab({super.key});

  @override
  State<UsuariosTab> createState() => _UsuariosTabState();
}

class _UsuariosTabState extends State<UsuariosTab> {
  String filtroEstado = "todos";

  int prioridadRol(String rol) {
    switch (rol) {
      case "developer":
        return 1;
      case "admin":
        return 2;
      case "encargado":
        return 3;
      case "auxiliar":
        return 4;
      case "barista":
        return 5;
      case "mesero":
        return 6;
      default:
        return 99;
    }
  }

  Color colorRol(String rol) {
    switch (rol) {
      case "developer":
        return Colors.deepPurpleAccent;
      case "admin":
        return Colors.redAccent;
      case "encargado":
        return Colors.blueAccent;
      case "auxiliar":
        return Colors.teal;
      case "barista":
        return Colors.brown;
      case "mesero":
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final userService = UserService();

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
                        builder: (_) => const NuevoUsuarioDialog(),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      "Nuevo Usuario",
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
                    border: Border.all(color: Colors.white.withOpacity(0.06)),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      dropdownColor: const Color(0xFF111827),
                      value: filtroEstado,
                      isExpanded: true,
                      style: const TextStyle(color: Colors.white),
                      icon: const Icon(
                        Icons.keyboard_arrow_down,
                        color: Colors.white70,
                      ),
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
              stream: userService.obtenerUsuarios(),
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

                docs.sort((a, b) {
                  final rolA = a['tipo_usuario'];
                  final rolB = b['tipo_usuario'];

                  return prioridadRol(rolA).compareTo(prioridadRol(rolB));
                });

                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final usuario = docs[index];

                    final nombre = usuario['nombres'];
                    final rol = usuario['tipo_usuario'];

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.06),
                        ),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 24,
                            backgroundColor: colorRol(rol).withOpacity(0.18),
                            child: Icon(Icons.person, color: colorRol(rol)),
                          ),

                          const SizedBox(width: 14),

                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  nombre,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),

                                const SizedBox(height: 4),

                                Text(
                                  rol.toUpperCase(),
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          IconButton(
                            onPressed: () {},
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
