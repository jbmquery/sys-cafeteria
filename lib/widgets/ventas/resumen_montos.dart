// lib/widgets/ventas/resumen_montos.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ResumenMontos extends StatelessWidget {
  final String pedidoId;

  const ResumenMontos({super.key, required this.pedidoId});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<QuerySnapshot>(
      future: FirebaseFirestore.instance
          .collection('pedidos')
          .doc(pedidoId)
          .collection('pagos')
          .get(),

      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox();
        }

        final pagos = snapshot.data!.docs;

        if (pagos.isEmpty) {
          return const SizedBox();
        }

        /// =========================================================
        /// AGRUPAR POR CUENTA
        /// =========================================================
        final Map<int, List<QueryDocumentSnapshot>> pagosPorCuenta = {};

        for (final pago in pagos) {
          final data = pago.data() as Map<String, dynamic>;

          final cuenta = data['cuenta'] ?? 0;

          pagosPorCuenta.putIfAbsent(cuenta, () => []);

          pagosPorCuenta[cuenta]!.add(pago);
        }

        /// =========================================================
        /// TOTALES
        /// =========================================================
        double totalDescuento = 0;
        double totalPropina = 0;
        double totalDelivery = 0;
        double totalFinal = 0;
        double totalVuelto = 0;
        double totalPagado = 0;

        for (final cuenta in pagosPorCuenta.entries) {
          final pagosCuenta = cuenta.value;

          final primerPago = pagosCuenta.first.data() as Map<String, dynamic>;

          totalDescuento += (primerPago['monto_descuento'] ?? 0).toDouble();

          totalPropina += (primerPago['monto_propina'] ?? 0).toDouble();

          totalDelivery += (primerPago['monto_delivery'] ?? 0).toDouble();

          totalFinal += (primerPago['monto_subtotal'] ?? 0).toDouble();

          totalVuelto += (primerPago['monto_vuelto'] ?? 0).toDouble();

          /// SUMAR TODOS LOS PAGOS
          for (final pago in pagosCuenta) {
            final pagoData = pago.data() as Map<String, dynamic>;

            totalPagado += (pagoData['monto_pagado'] ?? 0).toDouble();
          }
        }

        return Container(
          width: double.infinity,

          margin: const EdgeInsets.fromLTRB(12, 2, 12, 10),

          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),

          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.035),
            borderRadius: BorderRadius.circular(12),

            border: Border.all(color: Colors.white.withOpacity(0.04)),
          ),

          child: Column(
            children: [
              /// =====================================================
              /// FILA SUPERIOR
              /// =====================================================
              Row(
                children: [
                  Expanded(
                    child: _buildCompactBox(
                      titulo: "Descuento",
                      valor: "-${totalDescuento.toStringAsFixed(2)}",
                      color: Colors.redAccent,
                    ),
                  ),

                  const SizedBox(width: 6),

                  Expanded(
                    child: _buildCompactBox(
                      titulo: "Propina",
                      valor: "+${totalPropina.toStringAsFixed(2)}",
                      color: Colors.amberAccent,
                    ),
                  ),

                  const SizedBox(width: 6),

                  Expanded(
                    child: _buildCompactBox(
                      titulo: "Delivery",
                      valor: "+${totalDelivery.toStringAsFixed(2)}",
                      color: Colors.lightBlueAccent,
                    ),
                  ),
                ],
              ),

              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),

                child: Divider(
                  height: 1,
                  thickness: 1,
                  color: Colors.white.withOpacity(0.06),
                ),
              ),

              /// =====================================================
              /// FILA INFERIOR
              /// =====================================================
              Row(
                children: [
                  Expanded(
                    child: _buildCompactBox(
                      titulo: "Total",
                      valor: totalFinal.toStringAsFixed(2),
                      color: Colors.greenAccent,
                      bold: true,
                    ),
                  ),

                  const SizedBox(width: 6),

                  Expanded(
                    child: _buildCompactBox(
                      titulo: "Pagado",
                      valor: totalPagado.toStringAsFixed(2),
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(width: 6),

                  Expanded(
                    child: _buildCompactBox(
                      titulo: "Vuelto",
                      valor: totalVuelto.toStringAsFixed(2),
                      color: Colors.orangeAccent,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

/// ===============================================================
/// BOX COMPACTO
/// ===============================================================
Widget _buildCompactBox({
  required String titulo,
  required String valor,
  required Color color,
  bool bold = false,
}) {
  return Container(
    padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),

    decoration: BoxDecoration(
      color: Colors.black.withOpacity(0.12),
      borderRadius: BorderRadius.circular(8),
    ),

    child: Column(
      mainAxisSize: MainAxisSize.min,

      children: [
        Text(
          titulo,

          maxLines: 1,
          overflow: TextOverflow.ellipsis,

          style: TextStyle(
            color: Colors.white.withOpacity(0.65),
            fontSize: 9.5,
            fontWeight: FontWeight.w500,
          ),
        ),

        const SizedBox(height: 4),

        Text(
          "S/ $valor",

          maxLines: 1,
          overflow: TextOverflow.ellipsis,

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
