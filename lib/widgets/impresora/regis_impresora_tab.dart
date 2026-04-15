//lib/widgets/impresora/regis_impresora_tab.dart
import 'package:flutter/material.dart';

class RegisImpresoraTab extends StatefulWidget {
  const RegisImpresoraTab({super.key});

  @override
  State<RegisImpresoraTab> createState() => _RegisImpresoraTabState();
}

class _RegisImpresoraTabState extends State<RegisImpresoraTab> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          /// 🔹 Título
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "Historial de impresiones",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          const SizedBox(height: 20),

          /// 🔹 Lista placeholder
          Expanded(
            child: ListView.builder(
              itemCount: 5, // dummy
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
                      const Icon(Icons.print, color: Colors.white70),

                      const SizedBox(width: 12),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Impresión de prueba",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Fecha: ${DateTime.now()}",
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                          ],
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
