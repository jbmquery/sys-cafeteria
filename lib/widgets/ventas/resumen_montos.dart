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
        /// TOTALES GENERALES
        /// =========================================================
        double totalDescuento = 0;
        double totalPropina = 0;
        double totalDelivery = 0;
        double totalFinal = 0;
        double totalVuelto = 0;
        double totalPagado = 0;

        /// =========================================================
        /// RECORRER CADA CUENTA
        /// =========================================================
        for (final cuenta in pagosPorCuenta.entries) {
          final pagosCuenta = cuenta.value;

          /// SOLO PRIMER PAGO
          /// para evitar duplicados
          final primerPago = pagosCuenta.first.data() as Map<String, dynamic>;

          totalDescuento += (primerPago['monto_descuento'] ?? 0).toDouble();

          totalPropina += (primerPago['monto_propina'] ?? 0).toDouble();

          totalDelivery += (primerPago['monto_delivery'] ?? 0).toDouble();

          totalFinal += (primerPago['monto_subtotal'] ?? 0).toDouble();

          totalVuelto += (primerPago['monto_vuelto'] ?? 0).toDouble();

          /// =====================================================
          /// SUMAR TODOS LOS PAGOS
          /// =====================================================
          for (final pago in pagosCuenta) {
            final pagoData = pago.data() as Map<String, dynamic>;

            totalPagado += (pagoData['monto_pagado'] ?? 0).toDouble();
          }
        }

        return Container(
          width: double.infinity,
          margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
          padding: const EdgeInsets.all(14),

          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.04),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white.withOpacity(0.05)),
          ),

          child: Column(
            children: [
              /// =====================================================
              /// FILA SUPERIOR
              /// =====================================================
              Row(
                children: [
                  Expanded(
                    child: _buildResumenBox(
                      titulo: "Descuento",
                      valor: "- S/ ${totalDescuento.toStringAsFixed(2)}",
                      color: Colors.redAccent,
                    ),
                  ),

                  const SizedBox(width: 8),

                  Expanded(
                    child: _buildResumenBox(
                      titulo: "Propina",
                      valor: "+ S/ ${totalPropina.toStringAsFixed(2)}",
                      color: Colors.amberAccent,
                    ),
                  ),

                  const SizedBox(width: 8),

                  Expanded(
                    child: _buildResumenBox(
                      titulo: "Delivery",
                      valor: "+ S/ ${totalDelivery.toStringAsFixed(2)}",
                      color: Colors.lightBlueAccent,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              Divider(color: Colors.white.withOpacity(0.08)),

              const SizedBox(height: 10),

              /// =====================================================
              /// FILA INFERIOR
              /// =====================================================
              Row(
                children: [
                  Expanded(
                    child: _buildResumenBox(
                      titulo: "Total Final",
                      valor: "S/ ${totalFinal.toStringAsFixed(2)}",
                      color: Colors.greenAccent,
                      bold: true,
                    ),
                  ),

                  const SizedBox(width: 8),

                  Expanded(
                    child: _buildResumenBox(
                      titulo: "Pagado",
                      valor: "S/ ${totalPagado.toStringAsFixed(2)}",
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(width: 8),

                  Expanded(
                    child: _buildResumenBox(
                      titulo: "Vuelto",
                      valor: "S/ ${totalVuelto.toStringAsFixed(2)}",
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

Widget _buildResumenBox({
  required String titulo,
  required String valor,
  required Color color,
  bool bold = false,
}) {
  return Container(
    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),

    decoration: BoxDecoration(
      color: Colors.black.withOpacity(0.12),
      borderRadius: BorderRadius.circular(10),
    ),

    child: Column(
      children: [
        Text(
          titulo,
          style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 10),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 6),

        Text(
          valor,
          style: TextStyle(
            color: color,
            fontSize: 12,
            fontWeight: bold ? FontWeight.bold : FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    ),
  );
}
