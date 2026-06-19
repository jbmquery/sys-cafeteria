//lib/pages/marcar_asistencia_page.dart
import 'package:flutter/material.dart';

import '../widgets/app_sidebar.dart';
import '../widgets/app_navbar.dart';

class MarcarAsistenciaPage extends StatefulWidget {
  const MarcarAsistenciaPage({super.key});

  @override
  State<MarcarAsistenciaPage> createState() => _MarcarAsistenciaPageState();
}

class _MarcarAsistenciaPageState extends State<MarcarAsistenciaPage> {
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
                      const SizedBox(height: 10),

                      /// TÍTULO
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "Asistencia Sede ",
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),

                          Text(
                            "Fuera de rango",
                            style: TextStyle(
                              color: Colors.orange.shade300,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 40),

                      /// BOTÓN CIRCULAR
                      Center(
                        child: Container(
                          width: 240,
                          height: 240,

                          decoration: BoxDecoration(
                            shape: BoxShape.circle,

                            boxShadow: [
                              BoxShadow(
                                color: Colors.blue.withOpacity(0.45),
                                blurRadius: 35,
                                spreadRadius: 8,
                              ),
                            ],

                            gradient: const RadialGradient(
                              colors: [Color(0xFF3B82F6), Color(0xFF2563EB)],
                            ),
                          ),

                          child: Center(
                            child: Container(
                              width: 180,
                              height: 180,

                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.black.withOpacity(0.20),
                              ),

                              child: const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.calendar_month,
                                    color: Colors.white70,
                                    size: 34,
                                  ),

                                  Text(
                                    "19",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 52,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),

                                  Text(
                                    "JUNIO",
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 1.2,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 40),

                      /// HORARIO
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 220,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),

                            decoration: BoxDecoration(
                              color: const Color(0xFF111827),
                              borderRadius: BorderRadius.circular(8),
                            ),

                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Selecciona Horario",
                                  style: TextStyle(color: Colors.white70),
                                ),

                                Icon(
                                  Icons.keyboard_arrow_down,
                                  color: Colors.white54,
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(width: 10),

                          Container(
                            width: 42,
                            height: 42,

                            decoration: BoxDecoration(
                              color: const Color(0xFF2A2A2A),
                              borderRadius: BorderRadius.circular(8),
                            ),

                            child: const Icon(
                              Icons.question_mark,
                              color: Colors.amber,
                              size: 18,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 50),

                      /// MENSAJE
                      const Text(
                        "Presiona el botón para marcar tu asistencia",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),

                      const SizedBox(height: 18),

                      const Text(
                        "Hoy es viernes, 19 de junio de 2026",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white60, fontSize: 14),
                      ),

                      const SizedBox(height: 40),
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
