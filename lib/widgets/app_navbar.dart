//lib/widgets/app_navbar.dart
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../pages/login_page.dart';

class AppNavbar extends StatelessWidget {
  const AppNavbar({super.key});

  @override
  Widget build(BuildContext context) {
    String usuario = "Santiago";
    final AuthService authService = AuthService();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Builder(
            builder: (context) => GestureDetector(
              onTap: () {
                Scaffold.of(context).openDrawer();
              },
              child: glassButton(Icons.menu),
            ),
          ),

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
