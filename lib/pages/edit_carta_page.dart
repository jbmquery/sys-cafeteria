import 'package:flutter/material.dart';
import '../widgets/app_sidebar.dart';
import '../widgets/app_navbar.dart';
import '../widgets/app_bottom_tabbar.dart';

import '../widgets/carta/carta_tab.dart';
import '../widgets/carta/categorias_tab.dart';
import '../widgets/carta/subcategorias_tab.dart';

class EditCartaPage extends StatefulWidget {
  const EditCartaPage({super.key});

  @override
  State<EditCartaPage> createState() => _EditCartaPageState();
}

class _EditCartaPageState extends State<EditCartaPage> {
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
                      Tab(text: "Carta"),
                      Tab(text: "Categorías"),
                      Tab(text: "Subcategorías"),
                    ],
                  ),
                ),

                const SizedBox(height: 10),

                const Expanded(
                  child: TabBarView(
                    children: [CartaTab(), CategoriasTab(), SubcategoriasTab()],
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
