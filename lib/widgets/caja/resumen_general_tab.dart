//lib/widgets/caja/resumen_general_tab.dart

import 'package:flutter/material.dart';

class ResumenGeneralTab extends StatefulWidget {
  const ResumenGeneralTab({super.key});

  @override
  State<ResumenGeneralTab> createState() => _ResumenGeneralTabState();
}

class _ResumenGeneralTabState extends State<ResumenGeneralTab> {
  /// 🔥 CARD BASE
  Widget _card({required Widget child}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),

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
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),

      child: Column(
        children: [
          /// =========================================================
          /// 🔥 BOTONES SUPERIORES
          /// =========================================================
          /*           Row(
            children: [
              _topButton(
                title: "Egreso",
                icon: Icons.remove_circle_outline,

                onTap: () {},
              ),

              const SizedBox(width: 10),

              _topButton(
                title: "Ingreso Manual",
                icon: Icons.add_circle_outline,

                onTap: () {},
              ),

              const SizedBox(width: 10),

              _topButton(title: "Ajustes", icon: Icons.tune, onTap: () {}),
            ],
          ),

          const SizedBox(height: 18), */

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
                value: "S/ 150.00",
                icon: Icons.lock_open_outlined,
              ),

              _miniCard(
                title: "Ingresos",
                value: "S/ 2,450.00",
                icon: Icons.arrow_downward,
                valueColor: Colors.greenAccent,
              ),

              _miniCard(
                title: "Egresos",
                value: "S/ 340.00",
                icon: Icons.arrow_upward,
                valueColor: Colors.redAccent,
              ),

              _miniCard(
                title: "Contado Real",
                value: "S/ 2,260.00",
                icon: Icons.payments_outlined,
              ),

              _miniCard(
                title: "Diferencia",
                value: "+ S/ 20.00",
                icon: Icons.balance,
                valueColor: Colors.greenAccent,
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

                _rowItem(
                  title: "Efectivo",
                  amount: "S/ 1,200",
                  percentage: "49%",
                ),

                Divider(color: Colors.white.withOpacity(0.05)),

                _rowItem(title: "Yape", amount: "S/ 700", percentage: "29%"),

                Divider(color: Colors.white.withOpacity(0.05)),

                _rowItem(title: "Plin", amount: "S/ 300", percentage: "12%"),

                Divider(color: Colors.white.withOpacity(0.05)),

                _rowItem(title: "Tarjeta", amount: "S/ 250", percentage: "10%"),

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
                        "S/ 2,450.00",

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
          /// 🔥 VUELTO
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

                _rowItem(title: "Efectivo", amount: "S/ 85", percentage: "70%"),

                Divider(color: Colors.white.withOpacity(0.05)),

                _rowItem(title: "Yape", amount: "S/ 20", percentage: "16%"),

                Divider(color: Colors.white.withOpacity(0.05)),

                _rowItem(title: "Plin", amount: "S/ 10", percentage: "8%"),

                Divider(color: Colors.white.withOpacity(0.05)),

                _rowItem(title: "Tarjeta", amount: "S/ 5", percentage: "6%"),

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
                        "S/ 120.00",

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
  }
}
