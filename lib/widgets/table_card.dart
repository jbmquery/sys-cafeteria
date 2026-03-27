//lib/widgets/table_card.dart
import 'package:flutter/material.dart';

class TableCard extends StatelessWidget {
  final String nombre;
  final String subtitulo;
  final bool disponible;

  const TableCard({
    super.key,
    required this.nombre,
    required this.subtitulo,
    required this.disponible,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(7),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: disponible
              ? [
                  const Color(0xFF00C8AA),
                  const Color.fromARGB(255, 1, 144, 130),
                ]
              : [const Color(0xFFEF4444), const Color(0xFFB91C1C)],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.22),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),

      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            nombre,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            subtitulo,
            style: const TextStyle(
              color: Color.fromARGB(179, 41, 41, 41),
              fontSize: 11,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            disponible ? "Disponible" : "Ocupado",
            style: const TextStyle(
              color: Colors.black,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
