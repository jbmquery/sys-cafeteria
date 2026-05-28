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
        /// CONTADORES DINAMICOS
        /// =====================================================

        final Map<String, int> contadorTipoMesa = {};
        final Map<String, int> contadorEstado = {};

        for (final pedido in pedidosHoy) {
          final data = pedido.data() as Map<String, dynamic>;

          final tipoMesa = (data['tipo_mesa'] ?? 'Sin Tipo').toString().trim();

          final estado = (data['estado'] ?? 'Sin Estado').toString().trim();

          contadorTipoMesa[tipoMesa] = (contadorTipoMesa[tipoMesa] ?? 0) + 1;

          contadorEstado[estado] = (contadorEstado[estado] ?? 0) + 1;
        }

        /// =====================================================
        /// ORDENAR ALFABETICAMENTE
        /// =====================================================

        final tiposMesaOrdenados = contadorTipoMesa.entries.toList()
          ..sort((a, b) => a.key.compareTo(b.key));

        final estadosOrdenados = contadorEstado.entries.toList()
          ..sort((a, b) => a.key.compareTo(b.key));

        return Container(
          width: double.infinity,

          margin: const EdgeInsets.fromLTRB(16, 8, 16, 6),

          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),

          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.025),

            borderRadius: BorderRadius.circular(14),

            border: Border.all(color: Colors.white.withOpacity(0.2)),
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
                    children: tiposMesaOrdenados.map((entry) {
                      return _buildPill(
                        label: entry.key,
                        value: entry.value,
                        color: Colors.cyanAccent,
                      );
                    }).toList(),
                  ),
                ),
              ),

              const SizedBox(width: 5),

              /// DIVIDER CENTRAL
              Container(
                width: 1,
                height: 24,
                color: Colors.white.withOpacity(0.2),
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

                      children: estadosOrdenados.map((entry) {
                        return _buildPill(
                          label: entry.key,
                          value: entry.value,
                          color: Colors.greenAccent,
                        );
                      }).toList(),
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

          overflow: TextOverflow.ellipsis,
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
