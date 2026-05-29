//lib/widgets/caja/resumen_general_tab.dart
import 'package:flutter/material.dart';

class ResumenGeneralTab extends StatefulWidget {
  const ResumenGeneralTab({super.key});

  @override
  State<ResumenGeneralTab> createState() => _ResumenGeneralTabState();
}

class _ResumenGeneralTabState extends State<ResumenGeneralTab> {
  Widget _card({required Widget child}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(18),

        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),

      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),

      child: Column(
        children: [
          /// 🔵 CARD RESUMEN
          _card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: const [
                Text(
                  "Resumen de Caja",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                SizedBox(height: 12),

                Text(
                  "Aquí irá todo el resumen general de caja.",
                  style: TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),

          /// 🔵 CARD INGRESOS
          _card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: const [
                Text(
                  "Ingresos",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                SizedBox(height: 10),

                Text(
                  "Contenido futuro...",
                  style: TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),

          /// 🔵 CARD EGRESOS
          _card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: const [
                Text(
                  "Egresos",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                SizedBox(height: 10),

                Text(
                  "Contenido futuro...",
                  style: TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
