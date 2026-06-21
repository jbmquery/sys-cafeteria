//lib/pages/asistencia_page.dart
import 'package:flutter/material.dart';

import '../widgets/app_sidebar.dart';
import '../widgets/app_navbar.dart';
import '../widgets/app_bottom_tabbar.dart';

import '../widgets/asistencia/asistencia_resumen_tab.dart';
import '../widgets/asistencia/asistencia_historial_tab.dart';

class AsistenciaPage extends StatefulWidget {
  const AsistenciaPage({super.key});

  @override
  State<AsistenciaPage> createState() => _AsistenciaPageState();
}

class _AsistenciaPageState extends State<AsistenciaPage> {
  int currentTab = 2;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
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

                /// TAB BAR
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.all(6),

                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(24),
                  ),

                  child: const TabBar(
                    indicatorSize: TabBarIndicatorSize.tab,

                    indicator: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Color.fromARGB(255, 132, 95, 221),
                          Color.fromARGB(255, 111, 114, 255),
                        ],
                      ),

                      borderRadius: BorderRadius.all(Radius.circular(18)),
                    ),

                    labelColor: Colors.black,
                    unselectedLabelColor: Colors.white70,
                    dividerColor: Colors.transparent,

                    tabs: [
                      Tab(text: "Resumen"),
                      Tab(text: "Historial"),
                    ],
                  ),
                ),

                const SizedBox(height: 10),

                /// CONTENIDO
                const Expanded(
                  child: TabBarView(
                    children: [
                      AsistenciaResumenTab(),
                      AsistenciaHistorialTab(),
                    ],
                  ),
                ),

                /// BOTTOM BAR
                AppBottomTabBar(
                  currentIndex: currentTab,
                  onTap: (index) {
                    setState(() {
                      currentTab = index;
                    });
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
