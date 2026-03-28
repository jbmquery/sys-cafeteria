//lib/pages/home_page.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../widgets/app_sidebar.dart';
import '../widgets/app_navbar.dart';
import '../widgets/table_card.dart';
import '../widgets/app_bottom_tabbar.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final uidUsuarioActual = FirebaseAuth.instance.currentUser!.uid;
  int currentTab = 0;

  final List<String> tipos = ["Mesa", "Delivery", "Llevar", "Prueba"];

  int extraerNumero(String texto) {
    final regex = RegExp(r'\d+');
    final match = regex.firstMatch(texto);

    if (match != null) {
      return int.tryParse(match.group(0)!) ?? 9999;
    }

    return 9999;
  }

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
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('mesas')
                      .orderBy('fecha_creacion', descending: false)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      );
                    }

                    final docs = snapshot.data!.docs;

                    return ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      children: tipos.map((tipo) {
                        final mesasGrupo = docs.where((doc) {
                          final data = doc.data() as Map<String, dynamic>;
                          return data['tipo_mesa'] == tipo;
                        }).toList();

                        mesasGrupo.sort((a, b) {
                          final dataA = a.data() as Map<String, dynamic>;
                          final dataB = b.data() as Map<String, dynamic>;

                          final nombreA = dataA['nombre_mesa'] ?? '';
                          final nombreB = dataB['nombre_mesa'] ?? '';

                          final numA = extraerNumero(nombreA);
                          final numB = extraerNumero(nombreB);

                          if (numA != numB) {
                            return numA.compareTo(numB);
                          }

                          return nombreA.compareTo(nombreB);
                        });

                        if (mesasGrupo.isEmpty) {
                          return const SizedBox();
                        }

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            sectionTitle(tipo),

                            gridSection(
                              mesasGrupo.map((mesa) {
                                final data =
                                    mesa.data() as Map<String, dynamic>;

                                return TableCard(
                                  nombre: data['nombre_mesa'] ?? '',
                                  subtitulo: "${data['capacidad']} personas",
                                  disponible: data['disponibilidad'] ?? true,
                                  uidMesa: mesa.id,
                                  uidUsuarioAccion: uidUsuarioActual,
                                );
                              }).toList(),
                            ),
                          ],
                        );
                      }).toList(),
                    );
                  },
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
      padding: const EdgeInsets.only(bottom: 14, top: 18),
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
