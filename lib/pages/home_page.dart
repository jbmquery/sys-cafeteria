import 'package:flutter/material.dart';
import '../widgets/app_sidebar.dart';
import '../widgets/app_navbar.dart';
import '../widgets/table_card.dart';
import '../widgets/app_bottom_tabbar.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int currentTab = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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

              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    sectionTitle("Mesas en el local"),

                    gridSection([
                      const TableCard(
                        nombre: "Mesa 1",
                        subtitulo: "4 personas",
                        disponible: true,
                      ),
                      const TableCard(
                        nombre: "Mesa 2",
                        subtitulo: "2 personas",
                        disponible: false,
                      ),
                      const TableCard(
                        nombre: "Mesa 3",
                        subtitulo: "6 personas",
                        disponible: true,
                      ),
                      const TableCard(
                        nombre: "Mesa 4",
                        subtitulo: "4 personas",
                        disponible: true,
                      ),
                      const TableCard(
                        nombre: "Mesa 5",
                        subtitulo: "2 personas",
                        disponible: false,
                      ),
                      const TableCard(
                        nombre: "Mesa 6",
                        subtitulo: "6 personas",
                        disponible: true,
                      ),
                      const TableCard(
                        nombre: "Mesa 7",
                        subtitulo: "6 personas",
                        disponible: true,
                      ),
                      const TableCard(
                        nombre: "Mesa 8",
                        subtitulo: "6 personas",
                        disponible: true,
                      ),
                    ]),
                  ],
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
    );
  }

  static Widget sectionTitle(String titulo) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14, top: 10),
      child: Text(
        titulo,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 21,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  static Widget gridSection(List<Widget> cards) {
    return GridView.count(
      crossAxisCount: 4,
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 0.75,
      children: cards,
    );
  }
}
