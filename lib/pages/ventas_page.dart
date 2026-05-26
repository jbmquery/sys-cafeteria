// lib/pages/ventas_page.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../widgets/app_sidebar.dart';
import '../widgets/app_navbar.dart';
import '../widgets/app_bottom_tabbar.dart';

class VentasPage extends StatefulWidget {
  const VentasPage({super.key});

  @override
  State<VentasPage> createState() => _VentasPageState();
}

class _VentasPageState extends State<VentasPage> {
  int currentTab = 2;

  Future<String> obtenerNombreUsuario(String uid) async {
    if (uid.isEmpty) return 'Sin usuario';

    final userSnapshot = await FirebaseFirestore.instance
        .collection('usuarios')
        .doc(uid)
        .get();

    if (!userSnapshot.exists) return 'Usuario eliminado';

    final data = userSnapshot.data() ?? {};

    return data['apodo'] ?? 'Sin Apodo';
  }

  bool esHoy(Timestamp timestamp) {
    final fecha = timestamp.toDate();
    final ahora = DateTime.now();

    return fecha.year == ahora.year &&
        fecha.month == ahora.month &&
        fecha.day == ahora.day;
  }

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

              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('pedidos')
                      .where('estado', whereIn: ['completado', 'cancelado'])
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          "Error: ${snapshot.error}",
                          style: const TextStyle(color: Colors.red),
                        ),
                      );
                    }

                    if (!snapshot.hasData) {
                      return const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      );
                    }

                    final pedidos = snapshot.data!.docs.where((doc) {
                      final data = doc.data() as Map<String, dynamic>;

                      final fecha = data['fecha'] as Timestamp?;

                      if (fecha == null) return false;

                      return esHoy(fecha);
                    }).toList();

                    pedidos.sort((a, b) {
                      final dataA = a.data() as Map<String, dynamic>;
                      final dataB = b.data() as Map<String, dynamic>;

                      final fechaA = (dataA['fecha'] as Timestamp).toDate();

                      final fechaB = (dataB['fecha'] as Timestamp).toDate();

                      return fechaB.compareTo(fechaA);
                    });

                    if (pedidos.isEmpty) {
                      return const Center(
                        child: Text(
                          "Sin ventas hoy",
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

                        final hora = DateFormat('hh:mm a').format(fecha);

                        final estado = data['estado'] ?? '';

                        final uidUsuario = data['uid_usuario'] ?? '';

                        return FutureBuilder<String>(
                          future: obtenerNombreUsuario(uidUsuario),
                          builder: (context, usuarioSnapshot) {
                            final nombreUsuario =
                                usuarioSnapshot.data ?? 'Cargando...';

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

                                /// ===== TITULO =====
                                title: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "${data['nombre_mesa']}    Pedido: ${data['num_pedido']}",
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                      ),
                                    ),

                                    const SizedBox(height: 4),

                                    Text(
                                      "$hora    $estado",
                                      style: TextStyle(
                                        color: estado == 'cancelado'
                                            ? Colors.redAccent
                                            : Colors.greenAccent,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),

                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                    ),
                                    child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        "Pedido tomado por: $nombreUsuario",
                                        style: const TextStyle(
                                          color: Colors.white70,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ),

                                  const SizedBox(height: 12),

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

                                      final detalles =
                                          detalleSnapshot.data!.docs;

                                      final Map<
                                        int,
                                        List<QueryDocumentSnapshot>
                                      >
                                      agrupados = {};

                                      for (final detalle in detalles) {
                                        final item =
                                            detalle.data()
                                                as Map<String, dynamic>;

                                        final cuenta = item['cuenta'] ?? 0;

                                        agrupados.putIfAbsent(cuenta, () => []);

                                        agrupados[cuenta]!.add(detalle);
                                      }

                                      return Column(
                                        children: agrupados.entries.map((
                                          entry,
                                        ) {
                                          final cuenta = entry.key;

                                          final items = entry.value;

                                          return FutureBuilder<QuerySnapshot>(
                                            future: FirebaseFirestore.instance
                                                .collection('pedidos')
                                                .doc(pedido.id)
                                                .collection('pagos')
                                                .where(
                                                  'cuenta',
                                                  isEqualTo: cuenta,
                                                )
                                                .get(),
                                            builder: (context, pagoSnapshot) {
                                              double subtotal = 0;

                                              if (pagoSnapshot.hasData) {
                                                for (final pago
                                                    in pagoSnapshot
                                                        .data!
                                                        .docs) {
                                                  final pagoData =
                                                      pago.data()
                                                          as Map<
                                                            String,
                                                            dynamic
                                                          >;

                                                  subtotal +=
                                                      (pagoData['monto'] ?? 0)
                                                          .toDouble();
                                                }
                                              }

                                              return Container(
                                                width: double.infinity,
                                                margin:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 12,
                                                      vertical: 8,
                                                    ),
                                                padding: const EdgeInsets.all(
                                                  14,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: Colors.white
                                                      .withOpacity(0.03),
                                                  borderRadius:
                                                      BorderRadius.circular(14),
                                                ),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      "Cuenta $cuenta",
                                                      style: const TextStyle(
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),

                                                    const SizedBox(height: 10),

                                                    ...items.map((detalle) {
                                                      final item =
                                                          detalle.data()
                                                              as Map<
                                                                String,
                                                                dynamic
                                                              >;

                                                      return Padding(
                                                        padding:
                                                            const EdgeInsets.only(
                                                              bottom: 6,
                                                            ),
                                                        child: Text(
                                                          "($nombreUsuario) ${item['nombre']}",
                                                          style:
                                                              const TextStyle(
                                                                color: Colors
                                                                    .white70,
                                                                fontSize: 12,
                                                              ),
                                                        ),
                                                      );
                                                    }),

                                                    Divider(
                                                      color: Colors.white
                                                          .withOpacity(0.1),
                                                    ),

                                                    Align(
                                                      alignment:
                                                          Alignment.centerRight,
                                                      child: Text(
                                                        "Subtotal: S/ ${subtotal.toStringAsFixed(2)}",
                                                        style: const TextStyle(
                                                          color: Colors
                                                              .greenAccent,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            },
                                          );
                                        }).toList(),
                                      );
                                    },
                                  ),

                                  const SizedBox(height: 14),
                                ],
                              ),
                            );
                          },
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
}
