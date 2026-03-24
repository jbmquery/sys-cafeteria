//lib/widgtes/usuarios/nusuarios_tab.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/user_service.dart';
import 'nuevo_usuario_dialog.dart';

class UsuariosTab extends StatelessWidget {
  const UsuariosTab({super.key});

  @override
  Widget build(BuildContext context) {
    final userService = UserService();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              const Expanded(
                child: Text(
                  "Equipo activo",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) => const NuevoUsuarioDialog(),
                  );
                },
                child: const Text("Nuevo Usuario"),
              ),
            ],
          ),
        ),

        const SizedBox(height: 14),

        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: userService.obtenerUsuarios(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final usuarios = snapshot.data!.docs;

              return ListView.builder(
                itemCount: usuarios.length,
                itemBuilder: (context, index) {
                  final user = usuarios[index];

                  return ListTile(
                    title: Text(
                      user['nombres'],
                      style: const TextStyle(color: Colors.white),
                    ),
                    subtitle: Text(
                      user['tipo_usuario'],
                      style: const TextStyle(color: Colors.white54),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
