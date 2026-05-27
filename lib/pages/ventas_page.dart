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

                                              if (pagoSnapshot.hasData &&
                                                  pagoSnapshot
                                                      .data!
                                                      .docs
                                                      .isNotEmpty) {
                                                final primerPago =
                                                    pagoSnapshot
                                                            .data!
                                                            .docs
                                                            .first
                                                            .data()
                                                        as Map<String, dynamic>;

                                                subtotal =
                                                    (primerPago['monto'] ?? 0)
                                                        .toDouble();
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

                                                      final uidDetalle =
                                                          (item['uid_usuario'] ??
                                                                  '')
                                                              .toString();

                                                      final mismoUsuario =
                                                          uidDetalle ==
                                                          uidUsuario;

                                                      final precio =
                                                          (item['precio'] ?? 0)
                                                              .toDouble();

                                                      return FutureBuilder<
                                                        String
                                                      >(
                                                        future: mismoUsuario
                                                            ? Future.value('')
                                                            : obtenerNombreUsuario(
                                                                uidDetalle,
                                                              ),

                                                        builder:
                                                            (
                                                              context,
                                                              detalleUsuarioSnapshot,
                                                            ) {
                                                              final nombreDetalle =
                                                                  detalleUsuarioSnapshot
                                                                      .data ??
                                                                  '';

                                                              return Padding(
                                                                padding:
                                                                    const EdgeInsets.only(
                                                                      bottom: 6,
                                                                    ),

                                                                child: Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .spaceBetween,

                                                                  children: [
                                                                    Expanded(
                                                                      child: Text(
                                                                        mismoUsuario
                                                                            ? "${item['nombre']}"
                                                                            : "($nombreDetalle) ${item['nombre']}",

                                                                        style: const TextStyle(
                                                                          color:
                                                                              Colors.white70,
                                                                          fontSize:
                                                                              12,
                                                                        ),
                                                                      ),
                                                                    ),

                                                                    const SizedBox(
                                                                      width: 10,
                                                                    ),

                                                                    Text(
                                                                      "S/ ${precio.toStringAsFixed(2)}",

                                                                      style: const TextStyle(
                                                                        color: Colors
                                                                            .white,
                                                                        fontSize:
                                                                            12,
                                                                        fontWeight:
                                                                            FontWeight.w600,
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              );
                                                            },
                                                      );
                                                    }),

                                                    Divider(
                                                      color: Colors.white
                                                          .withOpacity(0.1),
                                                    ),

                                                    if (pagoSnapshot.hasData &&
                                                        pagoSnapshot
                                                            .data!
                                                            .docs
                                                            .isNotEmpty)
                                                      (() {
                                                        final pagos =
                                                            pagoSnapshot
                                                                .data!
                                                                .docs;

                                                        /// ===== PRIMER PAGO =====
                                                        /// Usamos solo el primero para evitar duplicados
                                                        final primerPago =
                                                            pagos.first.data()
                                                                as Map<
                                                                  String,
                                                                  dynamic
                                                                >;

                                                        final subtotalCuenta =
                                                            (primerPago['monto'] ??
                                                                    0)
                                                                .toDouble();

                                                        final montoPropina =
                                                            (primerPago['monto_propina'] ??
                                                                    0)
                                                                .toDouble();

                                                        final montoDelivery =
                                                            (primerPago['monto_delivery'] ??
                                                                    0)
                                                                .toDouble();

                                                        final montoDescuento =
                                                            (primerPago['monto_descuento'] ??
                                                                    0)
                                                                .toDouble();

                                                        final montoSubtotal =
                                                            (primerPago['monto_subtotal'] ??
                                                                    0)
                                                                .toDouble();

                                                        final montoVuelto =
                                                            (primerPago['monto_vuelto'] ??
                                                                    0)
                                                                .toDouble();

                                                        final modoVuelto =
                                                            (primerPago['modo_vuelto'] ??
                                                                    '')
                                                                .toString();

                                                        final uidPago =
                                                            (primerPago['uid_usuario'] ??
                                                                    '')
                                                                .toString();

                                                        final Timestamp?
                                                        horaPagoTimestamp =
                                                            primerPago['hora_pago'];

                                                        final horaPago =
                                                            horaPagoTimestamp !=
                                                                null
                                                            ? DateFormat(
                                                                'hh:mm a',
                                                              ).format(
                                                                horaPagoTimestamp
                                                                    .toDate(),
                                                              )
                                                            : '--:--';

                                                        /// ===== SUMA PAGOS =====
                                                        double totalPagado = 0;

                                                        for (final pago
                                                            in pagos) {
                                                          final pagoData =
                                                              pago.data()
                                                                  as Map<
                                                                    String,
                                                                    dynamic
                                                                  >;

                                                          totalPagado +=
                                                              (pagoData['monto_pagado'] ??
                                                                      0)
                                                                  .toDouble();
                                                        }

                                                        return FutureBuilder<
                                                          String
                                                        >(
                                                          future:
                                                              obtenerNombreUsuario(
                                                                uidPago,
                                                              ),

                                                          builder:
                                                              (
                                                                context,
                                                                pagoUserSnapshot,
                                                              ) {
                                                                final nombrePago =
                                                                    pagoUserSnapshot
                                                                        .data ??
                                                                    '...';

                                                                return Container(
                                                                  margin:
                                                                      const EdgeInsets.only(
                                                                        top: 10,
                                                                      ),

                                                                  child: Row(
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .start,

                                                                    children: [
                                                                      /// ===================================================
                                                                      /// COLUMNA IZQUIERDA
                                                                      /// ===================================================
                                                                      Expanded(
                                                                        child: Container(
                                                                          padding: const EdgeInsets.only(
                                                                            right:
                                                                                10,
                                                                          ),

                                                                          child: Column(
                                                                            crossAxisAlignment:
                                                                                CrossAxisAlignment.start,

                                                                            children: [
                                                                              /// HEADER
                                                                              Row(
                                                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,

                                                                                children: [
                                                                                  Expanded(
                                                                                    child: Text(
                                                                                      "Pago: $nombrePago",

                                                                                      style: const TextStyle(
                                                                                        color: Colors.white,
                                                                                        fontSize: 11,
                                                                                        fontWeight: FontWeight.w600,
                                                                                      ),

                                                                                      overflow: TextOverflow.ellipsis,
                                                                                    ),
                                                                                  ),

                                                                                  Text(
                                                                                    horaPago,

                                                                                    style: TextStyle(
                                                                                      color: Colors.white.withOpacity(
                                                                                        0.6,
                                                                                      ),
                                                                                      fontSize: 8,
                                                                                    ),
                                                                                  ),
                                                                                ],
                                                                              ),

                                                                              const SizedBox(
                                                                                height: 8,
                                                                              ),

                                                                              /// LISTA PAGOS
                                                                              ...pagos.map(
                                                                                (
                                                                                  pagoDoc,
                                                                                ) {
                                                                                  final pagoData =
                                                                                      pagoDoc.data()
                                                                                          as Map<
                                                                                            String,
                                                                                            dynamic
                                                                                          >;

                                                                                  final modoPago =
                                                                                      (pagoData['modo_pago'] ??
                                                                                              '')
                                                                                          .toString();

                                                                                  final montoPagado =
                                                                                      (pagoData['monto_pagado'] ??
                                                                                              0)
                                                                                          .toDouble();

                                                                                  return Padding(
                                                                                    padding: const EdgeInsets.only(
                                                                                      bottom: 4,
                                                                                    ),

                                                                                    child: Row(
                                                                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,

                                                                                      children: [
                                                                                        Expanded(
                                                                                          child: Text(
                                                                                            modoPago,

                                                                                            style: const TextStyle(
                                                                                              color: Colors.white70,
                                                                                              fontSize: 11,
                                                                                            ),
                                                                                          ),
                                                                                        ),

                                                                                        Text(
                                                                                          montoPagado.toStringAsFixed(
                                                                                            2,
                                                                                          ),

                                                                                          style: const TextStyle(
                                                                                            color: Colors.white,
                                                                                            fontSize: 11,
                                                                                            fontWeight: FontWeight.w600,
                                                                                          ),
                                                                                        ),
                                                                                      ],
                                                                                    ),
                                                                                  );
                                                                                },
                                                                              ),

                                                                              Divider(
                                                                                color: Colors.white.withOpacity(
                                                                                  0.1,
                                                                                ),
                                                                              ),

                                                                              Align(
                                                                                alignment: Alignment.centerRight,

                                                                                child: Text(
                                                                                  totalPagado.toStringAsFixed(
                                                                                    2,
                                                                                  ),

                                                                                  style: const TextStyle(
                                                                                    color: Colors.white,
                                                                                    fontSize: 11,
                                                                                    fontWeight: FontWeight.bold,
                                                                                  ),
                                                                                ),
                                                                              ),

                                                                              const SizedBox(
                                                                                height: 6,
                                                                              ),

                                                                              _buildMiniRow(
                                                                                "Total",
                                                                                montoSubtotal,
                                                                                Colors.greenAccent,
                                                                              ),

                                                                              Divider(
                                                                                color: Colors.white.withOpacity(
                                                                                  0.1,
                                                                                ),
                                                                              ),

                                                                              _buildMiniRow(
                                                                                "Vuelto ($modoVuelto)",
                                                                                montoVuelto,
                                                                                Colors.orangeAccent,
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ),
                                                                      ),

                                                                      /// DIVIDER VERTICAL
                                                                      Container(
                                                                        width:
                                                                            1,
                                                                        height:
                                                                            180,
                                                                        color: Colors
                                                                            .white
                                                                            .withOpacity(
                                                                              0.08,
                                                                            ),
                                                                      ),

                                                                      /// ===================================================
                                                                      /// COLUMNA DERECHA
                                                                      /// ===================================================
                                                                      Expanded(
                                                                        child: Container(
                                                                          padding: const EdgeInsets.only(
                                                                            left:
                                                                                10,
                                                                          ),

                                                                          child: Column(
                                                                            children: [
                                                                              _buildMiniRow(
                                                                                "Subtotal",
                                                                                subtotalCuenta,
                                                                                Colors.white,
                                                                              ),

                                                                              _buildMiniRow(
                                                                                "Propina (+)",
                                                                                montoPropina,
                                                                                Colors.amberAccent,
                                                                              ),

                                                                              _buildMiniRow(
                                                                                "Delivery (+)",
                                                                                montoDelivery,
                                                                                Colors.lightBlueAccent,
                                                                              ),

                                                                              _buildMiniRow(
                                                                                "Descuento (-)",
                                                                                montoDescuento,
                                                                                Colors.redAccent,
                                                                              ),

                                                                              Divider(
                                                                                color: Colors.white.withOpacity(
                                                                                  0.1,
                                                                                ),
                                                                              ),

                                                                              _buildMiniRow(
                                                                                "Total",
                                                                                montoSubtotal,
                                                                                Colors.greenAccent,
                                                                                bold: true,
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                );
                                                              },
                                                        );
                                                      })(),
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

Widget _buildMiniRow(
  String titulo,
  double monto,
  Color color, {
  bool bold = false,
}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 3),

    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,

      children: [
        Expanded(
          child: Text(
            titulo,

            style: TextStyle(
              color: Colors.white70,
              fontSize: 11,
              fontWeight: bold ? FontWeight.bold : FontWeight.w400,
            ),
          ),
        ),

        Text(
          monto.toStringAsFixed(2),

          style: TextStyle(
            color: color,
            fontSize: 11,
            fontWeight: bold ? FontWeight.bold : FontWeight.w600,
          ),
        ),
      ],
    ),
  );
}
