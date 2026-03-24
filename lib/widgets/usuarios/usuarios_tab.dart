//lib/widgets/usuarios/usuarios_tab.dart
import 'package:flutter/material.dart';
import 'nuevo_usuario_dialog.dart';

class UsuariosTab extends StatelessWidget {
  const UsuariosTab({super.key});

  @override
  Widget build(BuildContext context) {
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

              Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color.fromARGB(255, 132, 95, 221),
                      Color.fromARGB(255, 111, 114, 255),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),

                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                  ),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (_) => const NuevoUsuarioDialog(),
                    );
                  },
                  child: const Text(
                    "Nuevo Usuario",
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 14),

        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: 10,
            itemBuilder: (context, index) {
              return Container(
                margin: const EdgeInsets.only(bottom: 14),
                padding: const EdgeInsets.all(16),

                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(18),
                ),

                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.white.withOpacity(0.08),
                      child: const Icon(Icons.person, color: Colors.white70),
                    ),

                    const SizedBox(width: 14),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Usuario ${index + 1}",
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 4),

                          const Text(
                            "Mozo",
                            style: TextStyle(color: Colors.white54),
                          ),
                        ],
                      ),
                    ),

                    const Icon(Icons.chevron_right, color: Colors.white38),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
