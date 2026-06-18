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
      padding: const EdgeInsets.only(left: 16, top: 0, right: 16, bottom: 0),

      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(bottom: 8),

            child: Row(
              children: [
                /// FILTRO
                SizedBox(
                  width: 38,
                  height: 38,

                  child: ElevatedButton(
                    onPressed: () {},

                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E293B),
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),

                    child: const Icon(
                      Icons.filter_alt_outlined,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ),

                const SizedBox(width: 8),

                /// REGISTRAR EGRESO
                Expanded(
                  child: SizedBox(
                    height: 38,

                    child: ElevatedButton(
                      onPressed: () {},

                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1E293B),
                        padding: EdgeInsets.zero,

                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),

                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,

                        children: [
                          Text(
                            "Registrar",
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.white,
                              height: 1.25,
                            ),
                          ),

                          Text(
                            "Egreso",
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.white,
                              height: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 8),

                /// INGRESO MANUAL
                Expanded(
                  child: SizedBox(
                    height: 38,

                    child: ElevatedButton(
                      onPressed: () {},

                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1E293B),
                        padding: EdgeInsets.zero,

                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),

                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,

                        children: [
                          Text(
                            "Ingreso",
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.white,
                              height: 1.25,
                            ),
                          ),

                          Text(
                            "Manual",
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.white,
                              height: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 8),

                /// REALIZAR AJUSTE
                Expanded(
                  child: SizedBox(
                    height: 38,

                    child: ElevatedButton(
                      onPressed: () {},

                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1E293B),
                        padding: EdgeInsets.zero,

                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),

                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,

                        children: [
                          Text(
                            "Realizar",
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.white,
                              height: 1.25,
                            ),
                          ),

                          Text(
                            "Ajuste",
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.white,
                              height: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

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

                final movimientos = snapshot.data!.docs.toList();

                movimientos.sort((a, b) {
                  final dataA = a.data();
                  final dataB = b.data();

                  final fechaA =
                      (dataA['fecha_pago'] as Timestamp?)?.toDate() ??
                      DateTime(2000);

                  final fechaB =
                      (dataB['fecha_pago'] as Timestamp?)?.toDate() ??
                      DateTime(2000);

                  // Hora descendente
                  final comparacionHora = fechaB.compareTo(fechaA);

                  if (comparacionHora != 0) {
                    return comparacionHora;
                  }

                  final tipoA = (dataA['tipo'] ?? '').toString();
                  final tipoB = (dataB['tipo'] ?? '').toString();

                  // Tipo descendente (Z-A)
                  return tipoB.compareTo(tipoA);
                });

                return Scrollbar(
                  thumbVisibility: true,

                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,

                    child: SingleChildScrollView(
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
                            label: Center(
                              child: Text(
                                'Hora',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                          ),

                          DataColumn(
                            label: Center(
                              child: Text(
                                'Tipo',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                          ),

                          DataColumn(
                            label: Center(
                              child: Text(
                                'Categoría',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                          ),

                          DataColumn(
                            label: Center(
                              child: Text(
                                'Descripción',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                          ),

                          DataColumn(
                            label: Center(
                              child: Text(
                                'Método',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                          ),

                          DataColumn(
                            label: Center(
                              child: Text(
                                'Monto',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                          ),

                          DataColumn(
                            label: Center(
                              child: Text(
                                'Pedido',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                          ),

                          DataColumn(
                            label: Center(
                              child: Text(
                                'Pago',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                          ),
                        ],

                        rows: List.generate(movimientos.length, (index) {
                          final doc = movimientos[index];
                          final data = doc.data();

                          final tipo = data['tipo'] ?? '';

                          final monto =
                              (data['monto'] as num?)?.toDouble() ?? 0;

                          final Color colorMovimiento = switch (tipo) {
                            'ingreso' => Colors.greenAccent,
                            'vuelto' => Colors.amber,
                            _ => Colors.redAccent,
                          };

                          final horaActual = formatearFecha(data['fecha_pago']);

                          bool usarColorClaro = true;

                          for (int i = 0; i <= index; i++) {
                            if (i == 0) continue;

                            final horaFilaActual = formatearFecha(
                              movimientos[i].data()['fecha_pago'],
                            );

                            final horaFilaAnterior = formatearFecha(
                              movimientos[i - 1].data()['fecha_pago'],
                            );

                            if (horaFilaActual != horaFilaAnterior) {
                              usarColorClaro = !usarColorClaro;
                            }
                          }
                          return DataRow(
                            color: MaterialStateProperty.all(
                              usarColorClaro
                                  ? const Color(0xFF1E293B)
                                  : const Color(0xFF111827),
                            ),
                            cells: [
                              DataCell(
                                Center(
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
                                Center(
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
                                Center(
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
                                Center(
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
                                Center(
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
                                Center(
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
                        }),
                      ),
                    ),
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
