//lib/pages/impresora_page.dart
import 'package:flutter/material.dart';
import '../widgets/app_sidebar.dart';
import '../widgets/app_navbar.dart';
import '../widgets/app_bottom_tabbar.dart';

// 🔥 IMPORTS NUEVOS
import '../widgets/impresora/config_impresora_tab.dart';
import '../widgets/impresora/regis_impresora_tab.dart';

class ImpresoraPage extends StatefulWidget {
  const ImpresoraPage({super.key});

  @override
  State<ImpresoraPage> createState() => _ImpresoraPageState();
}

class _ImpresoraPageState extends State<ImpresoraPage> {
  int currentTab = 2;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2, // 👈 SOLO 2 TABS
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

                /// 🔵 TAB BAR (COPIADO DEL OTRO)
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
                      Tab(text: "Configuración"),
                      Tab(text: "Registros"),
                    ],
                  ),
                ),

                const SizedBox(height: 10),

                /// 🟣 CONTENIDO DE LOS TABS
                const Expanded(
                  child: TabBarView(
                    children: [
                      ConfigImpresoraTab(), // ⚙️
                      RegisImpresoraTab(), // 🧾
                    ],
                  ),
                ),

                /// 🔻 BOTTOM BAR
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
