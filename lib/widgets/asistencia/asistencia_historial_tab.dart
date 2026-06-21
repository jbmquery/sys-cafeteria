//lib/widgets/asistencia/asistencia_historial_tab.dart
import 'package:flutter/material.dart';

class AsistenciaHistorialTab extends StatefulWidget {
  const AsistenciaHistorialTab({super.key});

  @override
  State<AsistenciaHistorialTab> createState() => _AsistenciaHistorialTabState();
}

class _AsistenciaHistorialTabState extends State<AsistenciaHistorialTab> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),

      child: Column(
        children: [
          /// TÍTULO
          const Align(
            alignment: Alignment.centerLeft,

            child: Text(
              "Historial de asistencias",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          const SizedBox(height: 20),

          /// PLACEHOLDER
          Expanded(
            child: Center(
              child: Text(
                "Aquí aparecerá el historial de asistencias",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
