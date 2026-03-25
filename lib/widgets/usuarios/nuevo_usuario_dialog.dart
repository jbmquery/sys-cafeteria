//lib/widgtes/usuarios/nuevo_usuario_dialog.dart
import 'package:flutter/material.dart';
import '../../services/user_service.dart';
import '../custom_textfield.dart';
import '../../services/auth_service.dart';
import '../../pages/login_page.dart';

class NuevoUsuarioDialog extends StatefulWidget {
  const NuevoUsuarioDialog({super.key});

  @override
  State<NuevoUsuarioDialog> createState() => _NuevoUsuarioDialogState();
}

class _NuevoUsuarioDialogState extends State<NuevoUsuarioDialog> {
  final nombresController = TextEditingController();
  final correoController = TextEditingController();
  final passwordController = TextEditingController();

  final UserService userService = UserService();
  final AuthService authService = AuthService();

  bool cargando = false;
  String tipoUsuarioSeleccionado = "encargado";

  Future<void> guardarUsuario() async {
    setState(() {
      cargando = true;
    });

    String? uid = await userService.crearUsuario(
      nombres: nombresController.text.trim(),
      correo: correoController.text.trim(),
      password: passwordController.text.trim(),
      tipoUsuario: tipoUsuarioSeleccionado,
    );

    setState(() {
      cargando = false;
    });

    if (uid == "correo_existente") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Ese correo ya está registrado")),
      );
      return;
    }

    if (uid != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Usuario creado correctamente")),
      );

      await Future.delayed(const Duration(milliseconds: 700));

      await authService.logout();

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
        (route) => false,
      );
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Error al crear usuario")));
    }
  }

  void limpiarCampos() {
    nombresController.clear();
    correoController.clear();
    passwordController.clear();

    setState(() {
      tipoUsuarioSeleccionado = "encargado";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
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

            const SizedBox(height: 12),

            CustomTextField(
              controller: correoController,
              hint: "Correo",
              icon: Icons.mail_outline,
              borderColor: const Color.fromARGB(255, 111, 114, 255),
            ),

            const SizedBox(height: 12),

            CustomTextField(
              controller: passwordController,
              hint: "Contraseña",
              icon: Icons.lock_outline,
              obscure: true,
              borderColor: const Color.fromARGB(255, 111, 114, 255),
            ),

            const SizedBox(height: 12),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color.fromARGB(255, 111, 114, 255),
                ),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  dropdownColor: const Color(0xFF111827),
                  value: tipoUsuarioSeleccionado,
                  isExpanded: true,
                  style: const TextStyle(color: Colors.white),
                  icon: const Icon(
                    Icons.keyboard_arrow_down,
                    color: Colors.white,
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: "encargado",
                      child: Text("Encargado"),
                    ),
                    DropdownMenuItem(value: "barista", child: Text("Barista")),
                    DropdownMenuItem(value: "mesero", child: Text("Mesero")),
                    DropdownMenuItem(
                      value: "auxiliar",
                      child: Text("Auxiliar"),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      tipoUsuarioSeleccionado = value!;
                    });
                  },
                ),
              ),
            ),

            const SizedBox(height: 24),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      limpiarCampos();
                      Navigator.pop(context);
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.white24),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      "Cancelar",
                      style: TextStyle(color: Colors.white70),
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: ElevatedButton(
                    onPressed: cargando ? null : guardarUsuario,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 111, 114, 255),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: cargando
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            "Guardar",
                            style: TextStyle(color: Colors.black),
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
