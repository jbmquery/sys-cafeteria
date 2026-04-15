//lib/widgets/impresora/config_impresora_tab.dart
import 'package:flutter/material.dart';

class ConfigImpresoraTab extends StatefulWidget {
  const ConfigImpresoraTab({super.key});

  @override
  State<ConfigImpresoraTab> createState() => _ConfigImpresoraTabState();
}

class _ConfigImpresoraTabState extends State<ConfigImpresoraTab> {
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
              "Configuración de impresora",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          const SizedBox(height: 20),

          /// 🔹 Card placeholder
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.white.withOpacity(0.06)),
            ),
            child: const Text(
              "Aquí irá la configuración de impresora...",
              style: TextStyle(color: Colors.white70),
            ),
          ),

          const SizedBox(height: 20),

          /// 🔹 Botón placeholder
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueGrey,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text("Guardar configuración"),
            ),
          ),
        ],
      ),
    );
  }
}
