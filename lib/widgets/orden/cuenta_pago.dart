//lib/widgets/orden/cuenta_pago.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'envases_dialog.dart';

class CuentaPago extends StatefulWidget {
  final String pedidoId;
  final List<QueryDocumentSnapshot> detalles;
  final Map<String, bool> checkedItems;

  const CuentaPago({
    super.key,
    required this.pedidoId,
    required this.detalles,
    required this.checkedItems,
  });

  @override
  State<CuentaPago> createState() => _CuentaPagoState();
}

class _CuentaPagoState extends State<CuentaPago> {
  String tipoComprobante = "Boleta";

  List<Map<String, dynamic>> pagos = [
    {"tipo": "efectivo", "monto": TextEditingController()},
  ];

  List<Map<String, dynamic>> ajustes = [];

  final nombreCliente = TextEditingController();
  final documentoCliente = TextEditingController();

  List<Map<String, dynamic>> obtenerResumen() {
    final padres = widget.detalles.where((d) {
      final x = d.data() as Map<String, dynamic>;
      return (x['id_detalle_padre'] ?? '') == '';
    }).toList();

    final seleccionados = padres.where((d) {
      return widget.checkedItems[d.id] == true;
    }).toList();

    final usarTodos =
        seleccionados.isEmpty || seleccionados.length == padres.length;

    final basePadres = usarTodos ? padres : seleccionados;

    final Map<String, List<QueryDocumentSnapshot>> agrupados = {};

    /// ===== AGRUPAR PRODUCTOS PADRE =====
    for (final d in basePadres) {
      final x = d.data() as Map<String, dynamic>;

      final key =
          "${x['nombre']}_${x['precio']}_${x['porcion']}_${x['unidad']}";

      agrupados.putIfAbsent(key, () => []);
      agrupados[key]!.add(d);
    }

    /// ===== BUSCAR TOPPINGS RELACIONADOS SOLO DE LOS PADRES SELECCIONADOS =====
    final toppingsRelacionados = widget.detalles.where((d) {
      final x = d.data() as Map<String, dynamic>;

      return basePadres.any((padre) => padre.id == x['id_detalle_padre']);
    }).toList();

    /// ===== AGRUPAR TOPPINGS =====
    for (final d in toppingsRelacionados) {
      final x = d.data() as Map<String, dynamic>;

      final key = "TOPPING_${x['nombre']}_${x['precio']}";

      agrupados.putIfAbsent(key, () => []);
      agrupados[key]!.add(d);
    }

    /// ===== CONSTRUIR RESULTADO FINAL =====
    return agrupados.values.map((items) {
      final x = items.first.data() as Map<String, dynamic>;

      return {
        "nombre": x['nombre'],
        "precio": x['precio'],
        "porcion": x['porcion'] ?? '',
        "unidad": x['unidad'] ?? '',
        "cantidad": items.length,
      };
    }).toList();
  }

  double subtotal() {
    final resumen = obtenerResumen();

    double total = 0;

    for (final item in resumen) {
      total += (item["precio"] as num).toDouble() * item["cantidad"];
    }

    return total;
  }

  double totalPagado() {
    double total = 0;

    for (final p in pagos) {
      final val = double.tryParse(p["monto"].text) ?? 0;
      total += val;
    }

    return total;
  }

  double totalDescuento() {
    double total = 0;

    for (final a in ajustes) {
      if (a["tipo"] == "descuento") {
        total += double.tryParse(a["monto"].text) ?? 0;
      }
    }

    return total;
  }

  double totalPropina() {
    double total = 0;

    for (final a in ajustes) {
      if (a["tipo"] == "propina") {
        total += double.tryParse(a["monto"].text) ?? 0;
      }
    }

    return total;
  }

  double totalDelivery() {
    double total = 0;

    for (final a in ajustes) {
      if (a["tipo"] == "delivery") {
        total += double.tryParse(a["monto"].text) ?? 0;
      }
    }

    return total;
  }

  double totalFinal() {
    return subtotal() - totalDescuento() + totalPropina() + totalDelivery();
  }

  Widget _buildResumenRow(
    String label,
    String value,
    Color color, {
    bool bold = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.white70,
              fontSize: 12,
              fontWeight: bold ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: bold ? FontWeight.bold : FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final resumen = obtenerResumen();

    return Align(
      alignment: Alignment.centerRight,
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: MediaQuery.of(context).size.width * 0.82,
          height: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: const BoxDecoration(
            color: Color(0xFF111827),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              bottomLeft: Radius.circular(24),
            ),
          ),
          child: Column(
            children: [
              const SizedBox(height: 40),

              const Text(
                "Cuenta de Pago",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 16),

              /// ===== CONTENIDO SCROLL =====
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      ListView.builder(
                        itemCount: resumen.length,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemBuilder: (context, index) {
                          final item = resumen[index];
                          final total =
                              (item["precio"] as num).toDouble() *
                              item["cantidad"];

                          return Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  (() {
                                    final porcion =
                                        item["porcion"]?.toString() ?? "";
                                    final unidad =
                                        item["unidad"]?.toString() ?? "";

                                    final extra =
                                        porcion.isNotEmpty && unidad.isNotEmpty
                                        ? " ($porcion $unidad)"
                                        : "";

                                    return "${item["nombre"]}$extra";
                                  })(),
                                  style: const TextStyle(color: Colors.white),
                                ),
                                Text(
                                  "S/ ${item["precio"].toStringAsFixed(2)} x${item["cantidad"]} = S/ ${total.toStringAsFixed(2)}",
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 16),

                      GestureDetector(
                        onTap: () async {
                          final resultado = await showDialog(
                            context: context,
                            builder: (_) =>
                                EnvasesDialog(pedidoId: widget.pedidoId),
                          );

                          if (resultado == true) {
                            setState(() {});
                          }
                        },
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            "+ Agregar Envase",
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: const Color(0xFF00C8AA),
                            width: 0.8,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Subtotal",
                              style: TextStyle(color: Colors.white70),
                            ),
                            Text(
                              "S/ ${subtotal().toStringAsFixed(2)}",
                              style: const TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      ...pagos.asMap().entries.map((entry) {
                        final index = entry.key;
                        final p = entry.value;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: Row(
                            children: [
                              /// ICONO DINERO
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 16,
                                ),
                                decoration: const BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Color(0xFF00C8AA),
                                      Color.fromARGB(255, 1, 144, 130),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(14),
                                    bottomLeft: Radius.circular(14),
                                  ),
                                ),
                                child: const Icon(
                                  Icons.payments_outlined,
                                  color: Colors.black,
                                  size: 20,
                                ),
                              ),

                              /// SELECT METODO PAGO
                              Expanded(
                                flex: 3,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                  ),
                                  color: const Color(0xFF1E293B),
                                  child: DropdownButton<String>(
                                    value: p["tipo"],
                                    isExpanded: true,
                                    underline: const SizedBox(),
                                    dropdownColor: const Color(0xFF1E293B),
                                    style: const TextStyle(color: Colors.white),
                                    items: const [
                                      DropdownMenuItem(
                                        value: "efectivo",
                                        child: Text("Efectivo"),
                                      ),
                                      DropdownMenuItem(
                                        value: "yape",
                                        child: Text("Yape"),
                                      ),
                                      DropdownMenuItem(
                                        value: "plin",
                                        child: Text("Plin"),
                                      ),
                                      DropdownMenuItem(
                                        value: "agora",
                                        child: Text("Agora"),
                                      ),
                                      DropdownMenuItem(
                                        value: "transferencia",
                                        child: Text("Transferencia"),
                                      ),
                                    ],
                                    onChanged: (v) {
                                      setState(() {
                                        p["tipo"] = v!;
                                      });
                                    },
                                  ),
                                ),
                              ),

                              /// INPUT MONTO
                              Expanded(
                                flex: 2,
                                child: Container(
                                  color: const Color(0xFF1E293B),

                                  child: TextField(
                                    controller: p["monto"],
                                    keyboardType: TextInputType.number,
                                    style: const TextStyle(color: Colors.white),
                                    decoration: const InputDecoration(
                                      hintText: "Monto",
                                      hintStyle: TextStyle(
                                        color: Colors.white38,
                                      ),
                                      border: InputBorder.none,
                                      contentPadding: EdgeInsets.symmetric(
                                        horizontal: 12,
                                      ),
                                    ),
                                    onChanged: (_) {
                                      setState(() {});
                                    },
                                  ),
                                ),
                              ),

                              /// BOTON BORRAR
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    if (pagos.length > 1) {
                                      pagos.removeAt(index);
                                    }
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 16,
                                  ),
                                  decoration: const BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Color.fromARGB(255, 243, 59, 157),
                                        Color.fromARGB(255, 200, 6, 109),
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.only(
                                      topRight: Radius.circular(14),
                                      bottomRight: Radius.circular(14),
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.delete_outline,
                                    color: Colors.black,
                                    size: 20,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),

                      const SizedBox(height: 10),

                      GestureDetector(
                        onTap: () {
                          setState(() {
                            pagos.add({
                              "tipo": "efectivo",
                              "monto": TextEditingController(),
                            });
                          });
                        },
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            "+ Agregar Pago",
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      ...ajustes.asMap().entries.map((entry) {
                        final index = entry.key;
                        final a = entry.value;

                        final esDescuento = a["tipo"] == "descuento";
                        final esPropina = a["tipo"] == "propina";
                        final esDelivery = a["tipo"] == "delivery";

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 16,
                                ),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: esDescuento
                                        ? [
                                            const Color.fromARGB(
                                              255,
                                              243,
                                              59,
                                              157,
                                            ),
                                            const Color.fromARGB(
                                              255,
                                              200,
                                              6,
                                              109,
                                            ),
                                          ]
                                        : esPropina
                                        ? [
                                            const Color(0xFFFFD54F),
                                            const Color(0xFFFFB300),
                                          ]
                                        : [
                                            const Color(0xFF64B5F6),
                                            const Color(0xFF1E88E5),
                                          ],
                                  ),
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(14),
                                    bottomLeft: Radius.circular(14),
                                  ),
                                ),
                                child: Icon(
                                  esDescuento
                                      ? Icons.discount_outlined
                                      : esPropina
                                      ? Icons.volunteer_activism_outlined
                                      : Icons.delivery_dining_outlined,
                                  color: Colors.black,
                                  size: 20,
                                ),
                              ),

                              Expanded(
                                flex: 3,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                  ),
                                  color: const Color(0xFF1E293B),
                                  child: DropdownButton<String>(
                                    value: a["tipo"],
                                    isExpanded: true,
                                    underline: const SizedBox(),
                                    dropdownColor: const Color(0xFF1E293B),
                                    style: const TextStyle(color: Colors.white),
                                    items: const [
                                      DropdownMenuItem(
                                        value: "descuento",
                                        child: Text("Descuento"),
                                      ),
                                      DropdownMenuItem(
                                        value: "propina",
                                        child: Text("Propina"),
                                      ),
                                      DropdownMenuItem(
                                        value: "delivery",
                                        child: Text("Delivery"),
                                      ),
                                    ],
                                    onChanged: (v) {
                                      setState(() {
                                        a["tipo"] = v!;
                                      });
                                    },
                                  ),
                                ),
                              ),

                              Expanded(
                                flex: 2,
                                child: Container(
                                  color: const Color(0xFF1E293B),
                                  child: TextField(
                                    controller: a["monto"],
                                    keyboardType: TextInputType.number,
                                    style: const TextStyle(color: Colors.white),
                                    decoration: const InputDecoration(
                                      hintText: "Monto",
                                      hintStyle: TextStyle(
                                        color: Colors.white38,
                                      ),
                                      border: InputBorder.none,
                                      contentPadding: EdgeInsets.symmetric(
                                        horizontal: 12,
                                      ),
                                    ),
                                    onChanged: (_) {
                                      setState(() {});
                                    },
                                  ),
                                ),
                              ),

                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    ajustes.removeAt(index);
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 16,
                                  ),
                                  decoration: const BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Color.fromARGB(255, 243, 59, 157),
                                        Color.fromARGB(255, 200, 6, 109),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.only(
                                      topRight: Radius.circular(14),
                                      bottomRight: Radius.circular(14),
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.delete_outline,
                                    color: Colors.black,
                                    size: 20,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                      const SizedBox(height: 10),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            ajustes.add({
                              "tipo": "descuento",
                              "monto": TextEditingController(),
                            });
                          });
                        },
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            "+ Agregar Dscto, Delivery o Propina",
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),

              /// ===== FOOTER FIJO =====
              const SizedBox(height: 12),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.white.withOpacity(0.2)),
                ),
                child: Column(
                  children: [
                    _buildResumenRow(
                      "Descuento",
                      "- S/ ${totalDescuento().toStringAsFixed(2)}",
                      const Color(0xFFFF6B6B),
                    ),

                    _buildResumenRow(
                      "Propina",
                      "+ S/ ${totalPropina().toStringAsFixed(2)}",
                      const Color(0xFFFFD54F),
                    ),

                    _buildResumenRow(
                      "Delivery",
                      "+ S/ ${totalDelivery().toStringAsFixed(2)}",
                      const Color(0xFF64B5F6),
                    ),

                    const SizedBox(height: 6),

                    Divider(color: Colors.white.withOpacity(0.2), height: 8),

                    _buildResumenRow(
                      "Total Final",
                      "S/ ${totalFinal().toStringAsFixed(2)}",
                      Colors.white,
                      bold: true,
                    ),

                    _buildResumenRow(
                      "Pagado",
                      "S/ ${totalPagado().toStringAsFixed(2)}",
                      const Color(0xFF00E5C3),
                    ),

                    _buildResumenRow(
                      "Vuelto",
                      "S/ ${(totalPagado() - totalFinal()).toStringAsFixed(2)}",
                      const Color(0xFF64B5F6),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              SizedBox(
                width: double.infinity,
                height: 46,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF00C8AA),
                        Color.fromARGB(255, 1, 144, 130),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      "PAGAR",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        letterSpacing: 0.5,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
