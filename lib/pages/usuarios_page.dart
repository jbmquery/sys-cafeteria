//lib/pages/usuarios_page.dart
import 'package:flutter/material.dart';
import '../widgets/app_sidebar.dart';
import '../widgets/app_navbar.dart';
import '../widgets/app_bottom_tabbar.dart';
import '../widgets/usuarios/usuarios_tab.dart';
import '../widgets/usuarios/permisos_tab.dart';
import '../widgets/usuarios/contratos_tab.dart';

class UsuariosPage extends StatefulWidget {
  const UsuariosPage({super.key});

  @override
  State<UsuariosPage> createState() => _UsuariosPageState();
}

class _UsuariosPageState extends State<UsuariosPage> {
  int currentTab = 0;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
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

                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(18),
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
                      Tab(text: "Usuarios"),
                      Tab(text: "Permisos"),
                      Tab(text: "Contratos"),
                    ],
                  ),
                ),

                const SizedBox(height: 10),

                const Expanded(
                  child: TabBarView(
                    children: [UsuariosTab(), PermisosTab(), ContratosTab()],
                  ),
                ),

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
