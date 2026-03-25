//lib/widgets/app_navbar.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../pages/login_page.dart';

class AppNavbar extends StatelessWidget {
  const AppNavbar({super.key});

  Future<bool> hayMenusVisibles() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    final doc = await FirebaseFirestore.instance
        .collection("usuarios")
        .doc(uid)
        .get();

    final data = doc.data()!;
    final tipoUsuario = data["tipo_usuario"] ?? "";

    if (tipoUsuario == "developer" || tipoUsuario == "admin") {
      return true;
    }

    final permisos = Map<String, bool>.from(data["permisos"] ?? {});

    return permisos.values.any((e) => e == true);
  }

  @override
  Widget build(BuildContext context) {
    String usuario = "Santiago";
    final AuthService authService = AuthService();

    return FutureBuilder(
      future: hayMenusVisibles(),
      builder: (context, snapshot) {
        final mostrarMenu = snapshot.data ?? false;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              mostrarMenu
                  ? Builder(
                      builder: (context) => GestureDetector(
                        onTap: () {
                          Scaffold.of(context).openDrawer();
                        },
                        child: glassButton(Icons.menu),
                      ),
                    )
                  : const SizedBox(width: 42),

              const Text(
                "Pluvia Café",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),

              PopupMenuButton<String>(
                color: const Color(0xFF1E293B),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                offset: const Offset(0, 55),

                itemBuilder: (context) => [
                  PopupMenuItem(
                    enabled: false,
                    child: Text(
                      "Hola, $usuario",
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),

                  menuItem(Icons.person_outline, "Ver información"),
                  menuItem(Icons.calendar_month, "Marcar asistencia"),
                  menuItem(Icons.notifications_none, "Notificaciones"),
                  menuItem(Icons.logout, "Cerrar Sesión"),
                ],

                onSelected: (value) async {
                  if (value == "Cerrar Sesión") {
                    await authService.logout();

                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginPage()),
                      (route) => false,
                    );
                  }
                },

                child: glassButton(Icons.account_circle),
              ),
            ],
          ),
        );
      },
    );
  }

  static PopupMenuItem<String> menuItem(IconData icon, String texto) {
    return PopupMenuItem<String>(
      value: texto,
      child: Row(
        children: [
          Icon(icon, color: Colors.white70, size: 20),
          const SizedBox(width: 12),
          Text(texto, style: const TextStyle(color: Colors.white)),
        ],
      ),
    );
  }

  static Widget glassButton(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Icon(icon, color: Colors.white),
    );
  }
}
