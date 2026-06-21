//lib/widgets/asistencia/asistencia_resumen_tab.dart
import 'package:flutter/material.dart';

class AsistenciaResumenTab extends StatefulWidget {
  const AsistenciaResumenTab({super.key});

  @override
  State<AsistenciaResumenTab> createState() => _AsistenciaResumenTabState();
}

class _AsistenciaResumenTabState extends State<AsistenciaResumenTab> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          /// TÍTULO
          const Text(
            "Resumen de asistencia",
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 20),

          /// PLACEHOLDER
          Expanded(
            child: Center(
              child: Text(
                "Aquí aparecerá el resumen de asistencia",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.60),
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
