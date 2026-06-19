import 'package:flutter/material.dart';

import '../widgets/app_sidebar.dart';
import '../widgets/app_navbar.dart';

class NotificacionesUsuarioPage extends StatefulWidget {
  const NotificacionesUsuarioPage({super.key});

  @override
  State<NotificacionesUsuarioPage> createState() =>
      _NotificacionesUsuarioPageState();
}

class _NotificacionesUsuarioPageState extends State<NotificacionesUsuarioPage> {
  int currentTab = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,

      drawer: const AppSidebar(),

      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0B0F1A), Color(0xFF111827), Color(0xFF1E293B)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),

        child: SafeArea(
          child: Column(
            children: [
              const AppNavbar(),

              const SizedBox(height: 10),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),

                  child: Column(
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),

                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(18),
                        ),

                        child: const Column(
                          children: [
                            Icon(
                              Icons.notifications,
                              size: 50,
                              color: Colors.white,
                            ),

                            SizedBox(height: 12),

                            Text(
                              "Notificaciones del Usuario",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            SizedBox(height: 8),

                            Text(
                              "Próximamente aquí irá el módulo de notificaciones.",
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.white70),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
