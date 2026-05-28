// lib/widgets/ventas/contadores_montos.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ContadoresMontos extends StatelessWidget {
  const ContadoresMontos({super.key});

  bool esHoy(Timestamp timestamp) {
    final fecha = timestamp.toDate();
    final ahora = DateTime.now();

    return fecha.year == ahora.year &&
        fecha.month == ahora.month &&
        fecha.day == ahora.day;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('pedidos').snapshots(),

      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox();
        }

        final pedidosHoy = snapshot.data!.docs.where((doc) {
          final data = doc.data() as Map<String, dynamic>;

          final fecha = data['fecha'] as Timestamp?;

          if (fecha == null) return false;

          return esHoy(fecha);
        }).toList();

        /// =====================================================
        /// CONTADORES
        /// =====================================================

        final Map<String, int> contadorTipoMesa = {};
        final Map<String, int> contadorEstado = {};

        for (final pedido in pedidosHoy) {
          final data = pedido.data() as Map<String, dynamic>;

          final tipoMesa = (data['tipo_mesa'] ?? '').toString().toLowerCase();

          final estado = (data['estado'] ?? '').toString().toLowerCase();

          contadorTipoMesa[tipoMesa] = (contadorTipoMesa[tipoMesa] ?? 0) + 1;

          contadorEstado[estado] = (contadorEstado[estado] ?? 0) + 1;
        }

        return Container(
          width: double.infinity,

          margin: const EdgeInsets.fromLTRB(16, 8, 16, 6),

          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),

          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.025),

            borderRadius: BorderRadius.circular(14),

            border: Border.all(color: Colors.white.withOpacity(0.05)),
          ),

          child: Row(
            children: [
              /// =================================================
              /// IZQUIERDA -> TIPO MESA
              /// =================================================
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,

                  child: Row(
                    children: [
                      if (contadorTipoMesa.containsKey('mesa'))
                        _buildPill(
                          label: "Mesa",
                          value: contadorTipoMesa['mesa']!,
                          color: const Color(0xFF22D3EE),
                        ),

                      if (contadorTipoMesa.containsKey('delivery'))
                        _buildPill(
                          label: "Delivery",
                          value: contadorTipoMesa['delivery']!,
                          color: const Color(0xFFFB923C),
                        ),

                      if (contadorTipoMesa.containsKey('llevar'))
                        _buildPill(
                          label: "Llevar",
                          value: contadorTipoMesa['llevar']!,
                          color: const Color(0xFFC084FC),
                        ),
                    ],
                  ),
                ),
              ),

              const SizedBox(width: 5),

              /// DIVIDER CENTRAL
              Container(
                width: 1,
                height: 24,
                color: Colors.white.withOpacity(0.08),
              ),

              const SizedBox(width: 5),

              /// =================================================
              /// DERECHA -> ESTADOS
              /// =================================================
              Expanded(
                child: Align(
                  alignment: Alignment.centerRight,

                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,

                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,

                      children: [
                        if (contadorEstado.containsKey('completado'))
                          _buildPill(
                            label: "Completados",
                            value: contadorEstado['completado']!,
                            color: const Color(0xFF4ADE80),
                          ),

                        if (contadorEstado.containsKey('pendiente'))
                          _buildPill(
                            label: "Pend",
                            value: contadorEstado['pendiente']!,
                            color: const Color(0xFFFBBF24),
                          ),

                        if (contadorEstado.containsKey('cancelado'))
                          _buildPill(
                            label: "Cancelados",
                            value: contadorEstado['cancelado']!,
                            color: const Color(0xFFFB7185),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// ===========================================================
/// CAPSULA COMPACTA VERTICAL
/// ===========================================================

Widget _buildPill({
  required String label,
  required int value,
  required Color color,
}) {
  return Container(
    margin: const EdgeInsets.only(right: 5),

    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),

    decoration: BoxDecoration(
      color: color.withOpacity(0.08),

      borderRadius: BorderRadius.circular(10),

      border: Border.all(color: color.withOpacity(0.22)),
    ),

    child: Column(
      mainAxisSize: MainAxisSize.min,

      children: [
        Text(
          label,

          style: TextStyle(
            color: Colors.white.withOpacity(0.78),
            fontSize: 8.8,
            fontWeight: FontWeight.w500,
            height: 1,
          ),
        ),

        const SizedBox(height: 4),

        Text(
          value.toString(),

          style: TextStyle(
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.bold,
            height: 1,
          ),
        ),
      ],
    ),
  );
}
