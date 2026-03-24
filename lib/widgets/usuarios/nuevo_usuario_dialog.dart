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

  Future<void> guardarUsuario() async {
    setState(() {
      cargando = true;
    });

    String? uid = await userService.crearUsuario(
      nombres: nombresController.text.trim(),
      correo: correoController.text.trim(),
      password: passwordController.text.trim(),
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

            ElevatedButton(
              onPressed: cargando ? null : guardarUsuario,
              child: cargando
                  ? const CircularProgressIndicator()
                  : const Text("Guardar"),
            ),
          ],
        ),
      ),
    );
  }
}
