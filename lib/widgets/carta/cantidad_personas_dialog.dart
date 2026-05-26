//lib/widgets/carta/cantidad_personas_dialog.dart
import 'package:flutter/material.dart';

class CantidadPersonasDialog extends StatefulWidget {
  const CantidadPersonasDialog({super.key});

  @override
  State<CantidadPersonasDialog> createState() => _CantidadPersonasDialogState();
}

class _CantidadPersonasDialogState extends State<CantidadPersonasDialog> {
  final TextEditingController controller = TextEditingController();

  String? error;

  void agregarNumero(String numero) {
    setState(() {
      controller.text += numero;

      /// mover cursor al final
      controller.selection = TextSelection.fromPosition(
        TextPosition(offset: controller.text.length),
      );

      error = null;
    });
  }

  void borrarNumero() {
    if (controller.text.isEmpty) return;

    setState(() {
      controller.text = controller.text.substring(
        0,
        controller.text.length - 1,
      );

      controller.selection = TextSelection.fromPosition(
        TextPosition(offset: controller.text.length),
      );
    });
  }

  Widget _buildNumberButton({
    required String texto,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,

      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.04)),
        ),

        child: Center(
          child: Text(
            texto,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,

      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Color.fromARGB(255, 243, 59, 157),
              Color.fromARGB(255, 200, 6, 109),
            ],
          ),
          borderRadius: BorderRadius.circular(12),
        ),

        child: Center(child: Icon(icon, color: Colors.white, size: 20)),
      ),
    );
  }

  Widget _teclaNumero(String numero) {
    return SizedBox(
      width: 35,
      height: 42,
      child: _buildNumberButton(
        texto: numero,
        onTap: () => agregarNumero(numero),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 40),

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

              readOnly: true,
              showCursor: true,

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

            /// ===============================
            /// TECLADO NUMERICO
            /// ===============================
            Column(
              children: [
                /// ===== FILA 1 =====
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _teclaNumero("1"),
                    _teclaNumero("2"),
                    _teclaNumero("3"),
                    _teclaNumero("4"),
                    _teclaNumero("5"),
                    _teclaNumero("6"),
                  ],
                ),

                const SizedBox(height: 8),

                /// ===== FILA 2 =====
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _teclaNumero("7"),
                    _teclaNumero("8"),
                    _teclaNumero("9"),
                    _teclaNumero("0"),

                    SizedBox(
                      width: 80,
                      height: 42,
                      child: _buildIconButton(
                        icon: Icons.backspace_outlined,
                        onTap: borrarNumero,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 24),

            Row(
              children: [
                /// =========================
                /// CERRAR
                /// =========================
                Expanded(
                  child: SizedBox(
                    height: 48,

                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(
                          color: Color(0xFF00C8AA),
                          width: 1.2,
                        ),

                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),

                        backgroundColor: Colors.transparent,
                      ),

                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text(
                        "Cerrar",
                        style: TextStyle(color: Color(0xFF00C8AA)),
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 10),

                /// =========================
                /// GUARDAR
                /// =========================
                Expanded(
                  child: Container(
                    height: 48,

                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF00C8AA), Color(0xFF00A896)],
                      ),

                      borderRadius: BorderRadius.circular(12),
                    ),

                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                      ),

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

                      child: const Text(
                        "Guardar",
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
