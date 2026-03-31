import 'package:flutter/material.dart';

class CantidadPersonasDialog extends StatefulWidget {
  const CantidadPersonasDialog({super.key});

  @override
  State<CantidadPersonasDialog> createState() => _CantidadPersonasDialogState();
}

class _CantidadPersonasDialogState extends State<CantidadPersonasDialog> {
  final TextEditingController controller = TextEditingController();

  String? error;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),

      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFF111827),
          borderRadius: BorderRadius.circular(28),
        ),

        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Cantidad de personas",
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),

              decoration: InputDecoration(
                hintText: "Ejemplo: 3",
                hintStyle: const TextStyle(color: Colors.white38),

                errorText: error,

                filled: true,
                fillColor: Colors.white.withOpacity(0.05),

                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),

                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: Color(0xFF00C8AA)),
                ),
              ),
            ),

            const SizedBox(height: 20),

            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      final cantidad = int.tryParse(controller.text.trim());

                      if (cantidad == null || cantidad <= 0) {
                        setState(() {
                          error = "Ingrese un número válido";
                        });
                        return;
                      }

                      Navigator.pop(context, cantidad);
                    },

                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00C8AA),
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),

                    child: const Text("Guardar"),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),

                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.white24),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),

                child: const Text(
                  "Cerrar",
                  style: TextStyle(color: Colors.white70),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
