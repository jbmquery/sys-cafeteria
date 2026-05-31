//lib/pages/caja_page.dart
import 'package:flutter/material.dart';

import '../widgets/app_sidebar.dart';
import '../widgets/app_navbar.dart';
import '../widgets/app_bottom_tabbar.dart';

/// 🔥 IMPORTS NUEVOS
import '../widgets/caja/resumen_general_tab.dart';
import '../widgets/caja/movimientos_caja_tab.dart';
import '../widgets/caja/apertura_caja_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CajaPage extends StatefulWidget {
  const CajaPage({super.key});

  @override
  State<CajaPage> createState() => _CajaPageState();
}

class _CajaPageState extends State<CajaPage> {
  int currentTab = 2;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,

      child: Scaffold(
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

                /// 🔥 BLOQUE SESIÓN CAJA
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('caja')
                      .where('estado', isEqualTo: true)
                      .orderBy('fecha', descending: true)
                      .limit(1)
                      .snapshots(),

                  builder: (context, snapshot) {
                    /// 🔄 CARGANDO
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16),

                        padding: const EdgeInsets.all(20),

                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),

                          borderRadius: BorderRadius.circular(18),
                        ),

                        child: const Center(child: CircularProgressIndicator()),
                      );
                    }

                    /// ❌ ERROR
                    if (snapshot.hasError) {
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16),

                        padding: const EdgeInsets.all(20),

                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),

                          borderRadius: BorderRadius.circular(18),
                        ),

                        child: Text(
                          "Error: ${snapshot.error}",

                          style: const TextStyle(color: Colors.white),
                        ),
                      );
                    }

                    final docs = snapshot.data?.docs ?? [];

                    bool cajaAbierta = docs.isNotEmpty;

                    String cajeroNombre = '-';
                    String horaInicio = '-';
                    String cajaId = '';

                    /// 🔥 SI HAY CAJA ABIERTA
                    if (cajaAbierta) {
                      final doc = docs.first;

                      final data = doc.data() as Map<String, dynamic>;

                      cajaId = doc.id;

                      cajeroNombre = data['apodo_apertura'] ?? '-';

                      final fechaTimestamp = data['fecha'] as Timestamp?;

                      final fecha = fechaTimestamp?.toDate();

                      if (fecha != null) {
                        horaInicio =
                            "${fecha.hour.toString().padLeft(2, '0')}:"
                            "${fecha.minute.toString().padLeft(2, '0')}";
                      }
                    }

                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),

                      padding: const EdgeInsets.all(14),

                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),

                        borderRadius: BorderRadius.circular(18),

                        border: Border.all(
                          color: Colors.white.withOpacity(0.05),
                        ),
                      ),

                      child: Row(
                        children: [
                          /// 🔥 INFO
                          Expanded(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,

                              children: [
                                Expanded(
                                  child: _infoItem(
                                    label: "Cajero",
                                    value: cajeroNombre,
                                  ),
                                ),

                                Expanded(
                                  child: _infoItem(
                                    label: "Inicio",
                                    value: horaInicio,
                                  ),
                                ),

                                Expanded(
                                  child: _infoItem(
                                    label: "Estado",
                                    value: cajaAbierta ? "Abierto" : "Cerrado",

                                    valueColor: cajaAbierta
                                        ? Colors.greenAccent
                                        : Colors.redAccent,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(width: 12),

                          /// 🔥 BOTÓN
                          Container(
                            height: 40,

                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: cajaAbierta
                                    ? [
                                        Colors.redAccent,
                                        Colors.deepOrangeAccent,
                                      ]
                                    : [
                                        const Color.fromARGB(255, 132, 95, 221),
                                        const Color.fromARGB(
                                          255,
                                          111,
                                          114,
                                          255,
                                        ),
                                      ],
                              ),

                              borderRadius: BorderRadius.circular(14),
                            ),

                            child: ElevatedButton.icon(
                              onPressed: () async {
                                if (!cajaAbierta) {
                                  await showDialog(
                                    context: context,
                                    builder: (_) => const AperturaCajaDialog(),
                                  );
                                }
                              },

                              icon: Icon(
                                cajaAbierta ? Icons.lock_outline : Icons.add,

                                color: Colors.black,
                                size: 14,
                              ),

                              label: Text(
                                cajaAbierta ? "Cerrar Caja" : "Abrir Caja",

                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,

                                shadowColor: Colors.transparent,

                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),

                const SizedBox(height: 5),

                /// 🔵 TAB BAR
                Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 3,
                  ),
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
                      Tab(text: "Resumen General"),
                      Tab(text: "Movimientos"),
                    ],
                  ),
                ),

                const SizedBox(height: 5),

                /// 🟣 CONTENIDO TABS
                const Expanded(
                  child: TabBarView(
                    children: [ResumenGeneralTab(), MovimientosCajaTab()],
                  ),
                ),

                /// 🔻 BOTTOM NAVIGATION
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

  /// 🔥 ITEM INFO
  Widget _infoItem({
    required String label,
    required String value,
    Color valueColor = Colors.white,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,

      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              Text(
                label,

                style: const TextStyle(color: Colors.white54, fontSize: 11),
              ),

              const SizedBox(height: 3),

              Text(
                value,

                overflow: TextOverflow.ellipsis,

                style: TextStyle(
                  color: valueColor,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
