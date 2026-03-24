//lib/widgets/usuarios/contratos_tab.dart
import 'package:flutter/material.dart';

class ContratosTab extends StatelessWidget {
  const ContratosTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: 5,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.all(16),

          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(18),
          ),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Contrato ${index + 1}",
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                "Turno mañana • sede principal",
                style: TextStyle(color: Colors.white70),
              ),

              const SizedBox(height: 6),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text(
                    "S/ 1800",
                    style: TextStyle(
                      color: Color(0xFF00C8AA),
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  Icon(Icons.description_outlined, color: Colors.white54),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
