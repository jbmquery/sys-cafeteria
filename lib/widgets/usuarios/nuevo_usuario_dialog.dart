import 'package:flutter/material.dart';
import '../custom_textfield.dart';

class NuevoUsuarioDialog extends StatelessWidget {
  const NuevoUsuarioDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final nombresController = TextEditingController();
    final correoController = TextEditingController();
    final passwordController = TextEditingController();

    return Dialog(
      backgroundColor: Colors.transparent,

      child: Container(
        padding: const EdgeInsets.all(24),

        decoration: BoxDecoration(
          color: const Color(0xFF111827),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: Colors.white.withOpacity(0.08)),
        ),

        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 18),

            const Text(
              "Nuevo Usuario",
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              "Registro inicial del colaborador",
              style: TextStyle(color: Colors.white54, fontSize: 13),
            ),

            const SizedBox(height: 24),

            CustomTextField(
              controller: nombresController,
              hint: "Nombres",
              icon: Icons.person_outline,
              borderColor: const Color.fromARGB(255, 111, 114, 255),
            ),

            const SizedBox(height: 16),

            CustomTextField(
              controller: correoController,
              hint: "Correo",
              icon: Icons.mail_outline,
              borderColor: const Color.fromARGB(255, 111, 114, 255),
            ),

            const SizedBox(height: 16),

            CustomTextField(
              controller: passwordController,
              hint: "Contraseña",
              icon: Icons.lock_outline,
              obscure: true,
              borderColor: const Color.fromARGB(255, 111, 114, 255),
            ),

            const SizedBox(height: 24),

            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(16),
                    ),

                    child: TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text(
                        "Cancelar",
                        style: TextStyle(color: Colors.white70),
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: Container(
                    height: 50,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color.fromARGB(255, 132, 95, 221),
                          Color.fromARGB(255, 111, 114, 255),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),

                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                      ),
                      onPressed: () {},
                      child: const Text(
                        "Guardar",
                        style: TextStyle(color: Colors.black),
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
