// lib/pages/orden_page.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../widgets/app_sidebar.dart';
import '../widgets/app_navbar.dart';
import '../widgets/app_bottom_tabbar.dart';

class OrdenPage extends StatefulWidget {
  const OrdenPage({super.key});

  @override
  State<OrdenPage> createState() => _OrdenPageState();
}

class _OrdenPageState extends State<OrdenPage> {
  int currentTab = 1;

  final Map<String, bool> checkedItems = {};

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
                      .collection('pedidos')
                      .orderBy('fecha', descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      );
                    }

                    final pedidos = snapshot.data!.docs;

                    if (pedidos.isEmpty) {
                      return const Center(
                        child: Text(
                          "Sin pedidos",
                          style: TextStyle(color: Colors.white54),
                        ),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: pedidos.length,
                      itemBuilder: (context, index) {
                        final pedido = pedidos[index];
                        final data = pedido.data() as Map<String, dynamic>;

                        final fecha = (data['fecha'] as Timestamp).toDate();
                        final fechaTexto = DateFormat(
                          'dd/MM/yyyy',
                        ).format(fecha);

                        final hora = data['hora_pedido'] ?? '';

                        return Container(
                          margin: const EdgeInsets.only(bottom: 14),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: ExpansionTile(
                            collapsedIconColor: Colors.white70,
                            iconColor: Colors.white,
                            tilePadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),

                            title: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    "Para: ${data['nombre_mesa']}   Pedido: ${pedido.id}",
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),

                                GestureDetector(
                                  onTap: () {
                                    // agregar producto luego
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [
                                          Color(0xFF00C8AA),
                                          Color(0xFF00A896),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Icon(
                                      Icons.add,
                                      color: Colors.black,
                                      size: 18,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 6),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  "fecha: $fechaTexto   hora: $hora",
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 11,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ),
                            ),

                            children: [
                              StreamBuilder<QuerySnapshot>(
                                stream: FirebaseFirestore.instance
                                    .collection('pedidos')
                                    .doc(pedido.id)
                                    .collection('detalle')
                                    .snapshots(),
                                builder: (context, detalleSnapshot) {
                                  if (!detalleSnapshot.hasData) {
                                    return const Padding(
                                      padding: EdgeInsets.all(16),
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                      ),
                                    );
                                  }

                                  final detalles = detalleSnapshot.data!.docs;

                                  final productosPadre = detalles.where((d) {
                                    final x = d.data() as Map<String, dynamic>;
                                    return (x['id_detalle_padre'] ?? '') == '';
                                  }).toList();

                                  return Column(
                                    children: [
                                      ...productosPadre.map((detalle) {
                                        final item =
                                            detalle.data()
                                                as Map<String, dynamic>;

                                        final toppings = detalles.where((d) {
                                          final x =
                                              d.data() as Map<String, dynamic>;
                                          return x['id_detalle_padre'] ==
                                              detalle.id;
                                        }).toList();

                                        return Container(
                                          width: double.infinity,
                                          margin: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 6,
                                          ),
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color: Colors.white.withOpacity(
                                              0.03,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              14,
                                            ),
                                          ),
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Checkbox(
                                                value:
                                                    checkedItems[detalle.id] ??
                                                    false,
                                                onChanged: (value) {
                                                  setState(() {
                                                    checkedItems[detalle.id] =
                                                        value ?? false;
                                                  });
                                                },
                                                activeColor: const Color(
                                                  0xFF00C8AA,
                                                ),
                                              ),

                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      "${item['nombre']} (${item['porcion']} ${item['unidad']})",
                                                      style: const TextStyle(
                                                        color: Colors.white,
                                                      ),
                                                    ),

                                                    if (toppings.isNotEmpty)
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets.only(
                                                              top: 4,
                                                            ),
                                                        child: Text(
                                                          "○ Toppings: ${toppings.map((t) => (t.data() as Map<String, dynamic>)['nombre']).join(", ")}",
                                                          style:
                                                              const TextStyle(
                                                                color: Colors
                                                                    .green,
                                                                fontSize: 11,
                                                              ),
                                                        ),
                                                      ),

                                                    if ((item['observacion'] ??
                                                            '')
                                                        .toString()
                                                        .isNotEmpty)
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets.only(
                                                              top: 4,
                                                            ),
                                                        child: Text(
                                                          "○ Observación: ${item['observacion']}",
                                                          style:
                                                              const TextStyle(
                                                                color: Colors
                                                                    .white70,
                                                                fontSize: 11,
                                                              ),
                                                        ),
                                                      ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      }),

                                      const SizedBox(height: 12),

                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 8,
                                        ),
                                        child: Row(
                                          children: [
                                            _actionIcon(Icons.receipt_long),
                                            const SizedBox(width: 10),
                                            _actionIcon(Icons.restaurant),
                                            const SizedBox(width: 10),
                                            _actionIcon(Icons.delete_outline),
                                            const Spacer(),
                                            _payButton(),
                                          ],
                                        ),
                                      ),

                                      const SizedBox(height: 12),
                                    ],
                                  );
                                },
                              ),
                            ],
                          ),
                        );
                      },
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

  Widget _actionIcon(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: Colors.white70, size: 20),
    );
  }

  Widget _payButton() {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF00C8AA), Color(0xFF00A896)],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        child: Text(
          "Pagar",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
