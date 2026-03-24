//lib/widgets/usuarios/permisos_tab.dart
import 'package:flutter/material.dart';

class PermisosTab extends StatelessWidget {
  const PermisosTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: 6,
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
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.lock_outline, color: Colors.white70),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Permiso ${index + 1}",
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 4),

                    const Text(
                      "Acceso provisional activo",
                      style: TextStyle(color: Colors.white54),
                    ),
                  ],
                ),
              ),

              Switch(
                value: true,
                activeColor: const Color(0xFF00C8AA),
                onChanged: (_) {},
              ),
            ],
          ),
        );
      },
    );
  }
}
