//lib/widgets/caja/movimientos_caja_tab.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class MovimientosCajaTab extends StatefulWidget {
  const MovimientosCajaTab({super.key});

  @override
  State<MovimientosCajaTab> createState() => _MovimientosCajaTabState();
}

class _MovimientosCajaTabState extends State<MovimientosCajaTab> {
  Future<QuerySnapshot<Map<String, dynamic>>> obtenerMovimientos() async {
    final firestore = FirebaseFirestore.instance;

    final ahora = DateTime.now();

    final inicioDia = DateTime(ahora.year, ahora.month, ahora.day);

    final finDia = DateTime(ahora.year, ahora.month, ahora.day, 23, 59, 59);

    final cajaQuery = await firestore
        .collection('caja')
        .where('estado', isEqualTo: true)
        .where('fecha', isGreaterThanOrEqualTo: Timestamp.fromDate(inicioDia))
        .where('fecha', isLessThanOrEqualTo: Timestamp.fromDate(finDia))
        .limit(1)
        .get();

    if (cajaQuery.docs.isEmpty) {
      throw Exception("No existe caja activa");
    }

    final cajaRef = cajaQuery.docs.first.reference;

    return await cajaRef
        .collection('movimientos')
        .orderBy('fecha_pago', descending: true)
        .get();
  }

  String formatearFecha(dynamic fecha) {
    if (fecha == null) return '-';

    if (fecha is Timestamp) {
      return DateFormat('HH:mm:ss').format(fecha.toDate());
    }

    return '-';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),

      child: Column(
        children: [
          const Align(
            alignment: Alignment.centerLeft,

            child: Text(
              "Movimientos de Caja",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          const SizedBox(height: 20),

          Expanded(
            child: FutureBuilder<QuerySnapshot<Map<String, dynamic>>>(
              future: obtenerMovimientos(),

              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  final error = snapshot.error.toString();

                  if (error.contains("No existe caja activa")) {
                    return const Center(
                      child: Text(
                        'No hay caja activa',
                        style: TextStyle(color: Colors.white54, fontSize: 14),
                      ),
                    );
                  }

                  return Center(
                    child: Text(
                      error,
                      style: const TextStyle(color: Colors.white54),
                    ),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text(
                      'No existen movimientos',
                      style: TextStyle(color: Colors.white70),
                    ),
                  );
                }

                final movimientos = snapshot.data!.docs;

                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,

                  child: DataTable(
                    columnSpacing: 20,
                    horizontalMargin: 10,
                    dataRowMinHeight: 60,
                    dataRowMaxHeight: 70,
                    headingRowHeight: 42,

                    headingRowColor: MaterialStateProperty.all(
                      const Color(0xFF1E293B),
                    ),

                    dataRowColor: MaterialStateProperty.resolveWith(
                      (states) => const Color(0xFF111827),
                    ),

                    columns: const [
                      DataColumn(
                        label: SizedBox(
                          child: Text(
                            'Hora',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),

                      DataColumn(
                        label: SizedBox(
                          child: Text(
                            'Tipo',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),

                      DataColumn(
                        label: SizedBox(
                          child: Text(
                            'Categoría',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),

                      DataColumn(
                        label: SizedBox(
                          child: Text(
                            'Descripción',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),

                      DataColumn(
                        label: SizedBox(
                          child: Text(
                            'Método',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),

                      DataColumn(
                        label: SizedBox(
                          child: Text(
                            'Monto',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),

                      DataColumn(
                        label: SizedBox(
                          child: Text(
                            'Pedido',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),

                      DataColumn(
                        label: SizedBox(
                          child: Text(
                            'Pago',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],

                    rows: movimientos.map((doc) {
                      final data = doc.data();

                      final tipo = data['tipo'] ?? '';

                      final monto = (data['monto'] as num?)?.toDouble() ?? 0;

                      final colorMovimiento = tipo == 'ingreso'
                          ? Colors.greenAccent
                          : Colors.redAccent;

                      return DataRow(
                        cells: [
                          DataCell(
                            SizedBox(
                              child: Text(
                                formatearFecha(data['fecha_pago']),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                          ),

                          DataCell(
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 0,
                              ),
                              decoration: BoxDecoration(
                                color: colorMovimiento.withOpacity(.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                tipo.toUpperCase(),
                                style: TextStyle(
                                  color: colorMovimiento,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                          ),

                          DataCell(
                            SizedBox(
                              child: Text(
                                data['categoria'] ?? '',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                          ),

                          DataCell(
                            SizedBox(
                              child: Text(
                                data['descripcion'] ?? '',
                                softWrap: true,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 11,
                                  height: 1.1,
                                ),
                              ),
                            ),
                          ),

                          DataCell(
                            SizedBox(
                              child: Text(
                                data['metodo_monetario'] ?? '',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                          ),

                          DataCell(
                            SizedBox(
                              child: Text(
                                "S/ ${monto.toStringAsFixed(2)}",
                                style: TextStyle(
                                  color: colorMovimiento,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                          ),

                          DataCell(
                            SizedBox(
                              child: Text(
                                data['apodo_pedido'] ?? '',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                          ),

                          DataCell(
                            SizedBox(
                              child: Text(
                                data['apodo_pago'] ?? '',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
