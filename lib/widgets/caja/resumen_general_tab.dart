//lib/widgets/caja/resumen_general_tab.dart

import 'package:flutter/material.dart';
import '../../services/caja/montos_resumen.dart';
import 'package:intl/intl.dart';

class ResumenGeneralTab extends StatefulWidget {
  const ResumenGeneralTab({super.key});

  @override
  State<ResumenGeneralTab> createState() => _ResumenGeneralTabState();
}

class _ResumenGeneralTabState extends State<ResumenGeneralTab> {
  late Future<Map<String, dynamic>?> resumenFuture;

  /// 🔥 CARD BASE
  Widget _card({required Widget child}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),

      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),

        borderRadius: BorderRadius.circular(18),

        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),

      child: child,
    );
  }

  /// 🔥 MINI CARD COMPACTO
  Widget _miniCard({
    required String title,
    required String value,
    IconData? icon,
    Color valueColor = Colors.white,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),

      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),

        borderRadius: BorderRadius.circular(16),

        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),

      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          /// 🔹 ICONO + TITULO
          Row(
            children: [
              if (icon != null) Icon(icon, color: Colors.white60, size: 14),

              if (icon != null) const SizedBox(width: 5),

              Expanded(
                child: Text(
                  title,

                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,

                  style: const TextStyle(color: Colors.white54, fontSize: 11),
                ),
              ),
            ],
          ),

          const SizedBox(height: 4),

          /// 🔹 MONTO
          Text(
            value,

            maxLines: 1,
            overflow: TextOverflow.ellipsis,

            style: TextStyle(
              color: valueColor,
              fontSize: 17,
              fontWeight: FontWeight.bold,
              height: 1,
            ),
          ),
        ],
      ),
    );
  }

  /// 🔥 FILA RESUMEN
  Widget _rowItem({
    required String title,
    required String amount,
    required String percentage,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),

      child: Row(
        children: [
          /// 🔹 MÉTODO
          Expanded(
            flex: 4,

            child: Text(
              title,

              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
          ),

          /// 🔹 MONTO
          Expanded(
            flex: 3,

            child: Text(
              amount,

              textAlign: TextAlign.end,

              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          /// 🔹 PORCENTAJE
          Expanded(
            flex: 2,

            child: Text(
              percentage,

              textAlign: TextAlign.end,

              style: const TextStyle(
                color: Colors.greenAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 🔥 BOTÓN SUPERIOR
  Widget _topButton({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,

        child: Container(
          height: 46,

          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color.fromARGB(255, 132, 95, 221),
                Color.fromARGB(255, 111, 114, 255),
              ],
            ),

            borderRadius: BorderRadius.circular(14),
          ),

          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,

            children: [
              Icon(icon, color: Colors.black, size: 16),

              const SizedBox(width: 6),

              Flexible(
                child: Text(
                  title,

                  overflow: TextOverflow.ellipsis,

                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();

    resumenFuture = MontosResumenService.obtenerResumenCaja();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>?>(
      future: resumenFuture,

      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data == null) {
          return const Center(
            child: Text(
              'No hay caja activa',
              style: TextStyle(color: Colors.white54, fontSize: 14),
            ),
          );
        }

        final resumen = snapshot.data!;

        final double montoApertura = (resumen['montoApertura'] ?? 0).toDouble();

        final double contadoReal = (resumen['contadoReal'] ?? 0).toDouble();

        final bool mostrarMontos = resumen['mostrarMontos'] ?? false;

        final double ingresos = (resumen['ingresos'] ?? 0).toDouble();

        final double egresos = (resumen['egresos'] ?? 0).toDouble();

        final double diferencia = (resumen['diferencia'] ?? 0).toDouble();

        final double vueltos = (resumen['vueltos'] ?? 0).toDouble();

        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),

          child: Column(
            children: [
              /// =========================================================
              /// 🔥 RESUMEN GENERAL
              /// =========================================================
              GridView.count(
                crossAxisCount: 2,

                shrinkWrap: true,

                physics: const NeverScrollableScrollPhysics(),

                mainAxisSpacing: 12,
                crossAxisSpacing: 12,

                childAspectRatio: 2.3,

                children: [
                  _miniCard(
                    title: "Monto Apertura",
                    value: "S/ ${montoApertura.toStringAsFixed(2)}",
                    icon: Icons.lock_open_outlined,
                  ),

                  _miniCard(
                    title: "Contado Real",
                    value: "S/ ${contadoReal.toStringAsFixed(2)}",
                    icon: Icons.payments_outlined,
                  ),

                  _miniCard(
                    title: "Ingresos Caja",
                    value: mostrarMontos
                        ? "S/ ${ingresos.toStringAsFixed(2)}"
                        : "••••",
                    icon: Icons.arrow_downward,
                    valueColor: Colors.greenAccent,
                  ),

                  _miniCard(
                    title: "Egresos Caja",
                    value: mostrarMontos
                        ? "S/ ${egresos.toStringAsFixed(2)}"
                        : "••••",
                    icon: Icons.arrow_upward,
                    valueColor: Colors.redAccent,
                  ),

                  _miniCard(
                    title: "Diferencia",
                    value: mostrarMontos
                        ? "S/ ${diferencia.toStringAsFixed(2)}"
                        : "••••",
                    icon: Icons.balance,
                  ),

                  _miniCard(
                    title: "Vuelto",
                    value: mostrarMontos
                        ? "S/ ${vueltos.toStringAsFixed(2)}"
                        : "••••",
                    icon: Icons.currency_exchange,
                  ),
                ],
              ),

              const SizedBox(height: 20),

              /// =========================================================
              /// 🔥 MÉTODOS DE PAGO
              /// =========================================================
              _card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    const Text(
                      "Distribución por Método de Pago",

                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 18),

                    ...(resumen['pagosPorMetodo'] as Map<String, double>)
                        .entries
                        .map((e) {
                          final porcentaje = resumen['porcentajePagos'][e.key];

                          return _rowItem(
                            title: e.key,
                            amount: "S/ ${e.value.toStringAsFixed(2)}",
                            percentage: "${porcentaje.toStringAsFixed(0)}%",
                          );
                        }),

                    const SizedBox(height: 16),

                    Container(
                      padding: const EdgeInsets.all(14),

                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.04),

                        borderRadius: BorderRadius.circular(14),
                      ),

                      child: Row(
                        children: [
                          const Expanded(
                            child: Text(
                              "TOTAL INGRESOS",

                              style: TextStyle(
                                color: Colors.white70,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),

                          Text(
                            "S/ ${ingresos.toStringAsFixed(2)}",

                            style: const TextStyle(
                              color: Colors.greenAccent,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              /// =========================================================
              /// 🔥 VUELTOS
              /// =========================================================
              _card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    const Text(
                      "Distribución de Vueltos",

                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 18),

                    ...(resumen['vueltosPorMetodo'] as Map<String, double>)
                        .entries
                        .map((e) {
                          final porcentaje =
                              resumen['porcentajeVueltos'][e.key];

                          return _rowItem(
                            title: e.key,
                            amount: "S/ ${e.value.toStringAsFixed(2)}",
                            percentage: "${porcentaje.toStringAsFixed(0)}%",
                          );
                        }),

                    const SizedBox(height: 16),

                    Container(
                      padding: const EdgeInsets.all(14),

                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.04),

                        borderRadius: BorderRadius.circular(14),
                      ),

                      child: Row(
                        children: [
                          const Expanded(
                            child: Text(
                              "TOTAL VUELTOS",

                              style: TextStyle(
                                color: Colors.white70,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),

                          Text(
                            "S/ ${vueltos.toStringAsFixed(2)}",

                            style: const TextStyle(
                              color: Colors.orangeAccent,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              /// =========================================================
              /// 🔥 MÉTRICAS FINALES
              /// =========================================================
              GridView.count(
                crossAxisCount: 2,

                shrinkWrap: true,

                physics: const NeverScrollableScrollPhysics(),

                mainAxisSpacing: 12,
                crossAxisSpacing: 12,

                childAspectRatio: 2.1,

                children: [
                  _miniCard(
                    title: "Caja Abierta",
                    value: "6h 42m",
                    icon: Icons.timer_outlined,
                  ),

                  _miniCard(
                    title: "Ventas Realizadas",
                    value: "48",
                    icon: Icons.receipt_long_outlined,
                  ),

                  _miniCard(
                    title: "Ticket Promedio",
                    value: "S/ 51.04",
                    icon: Icons.analytics_outlined,
                  ),

                  _miniCard(
                    title: "Cuenta Promedio",
                    value: "S/ 68.20",
                    icon: Icons.people_outline,
                  ),

                  _miniCard(
                    title: "Última Venta",
                    value: "22:41",
                    icon: Icons.access_time_outlined,
                  ),

                  _miniCard(
                    title: "Primera Venta",
                    value: "08:57",
                    icon: Icons.schedule_outlined,
                  ),
                ],
              ),

              const SizedBox(height: 40),
            ],
          ),
        );
      },
    );
  }
}
