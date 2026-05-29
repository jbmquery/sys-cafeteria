//lib/widgets/caja/movimientos_caja_tab.dart
import 'package:flutter/material.dart';

class MovimientosCajaTab extends StatefulWidget {
  const MovimientosCajaTab({super.key});

  @override
  State<MovimientosCajaTab> createState() => _MovimientosCajaTabState();
}

class _MovimientosCajaTabState extends State<MovimientosCajaTab> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),

      child: Column(
        children: [
          /// 🔹 TITULO
          const Align(
            alignment: Alignment.centerLeft,

            child: Text(
              "Movimientos de Caja",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          const SizedBox(height: 20),

          /// 🔹 LISTA PLACEHOLDER
          Expanded(
            child: ListView.builder(
              itemCount: 10,

              itemBuilder: (context, index) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),

                  padding: const EdgeInsets.all(16),

                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),

                    borderRadius: BorderRadius.circular(18),

                    border: Border.all(color: Colors.white.withOpacity(0.06)),
                  ),

                  child: Row(
                    children: [
                      const Icon(Icons.receipt_long, color: Colors.white70),

                      const SizedBox(width: 12),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,

                          children: [
                            Text(
                              "Movimiento #$index",
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),

                            const SizedBox(height: 4),

                            const Text(
                              "Detalle del movimiento",
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const Text(
                        "S/ 0.00",
                        style: TextStyle(
                          color: Colors.greenAccent,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
