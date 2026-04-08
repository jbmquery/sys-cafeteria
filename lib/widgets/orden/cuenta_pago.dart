//lib/widgets/orden/cuenta_pago.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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

  double totalFinal() {
    return subtotal() - totalDescuento() + totalPropina();
  }

  Widget _tabComprobante(String label) {
    final activo = tipoComprobante == label;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            tipoComprobante = label;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            gradient: activo
                ? const LinearGradient(
                    colors: [Color(0xFF00C8AA), Color(0xFF00A896)],
                  )
                : null,
            color: activo ? null : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: activo ? Colors.black : Colors.white54,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ),
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

              const SizedBox(height: 20),

              /// ===== TABS FIJOS =====
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(14),
                ),
                padding: const EdgeInsets.all(4),
                child: Row(
                  children: [
                    _tabComprobante("Boleta"),
                    _tabComprobante("Boleta Electronica"),
                    _tabComprobante("Factura"),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              /// ===== CONTENIDO SCROLL =====
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      if (tipoComprobante == "Boleta Electronica" ||
                          tipoComprobante == "Factura")
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.04),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.search,
                                      color: Colors.white54,
                                      size: 18,
                                    ),
                                    const SizedBox(width: 8),
                                    const Expanded(
                                      child: TextField(
                                        style: TextStyle(color: Colors.white),
                                        decoration: InputDecoration(
                                          hintText: "Buscar Cliente",
                                          hintStyle: TextStyle(
                                            color: Colors.white38,
                                          ),
                                          border: InputBorder.none,
                                        ),
                                      ),
                                    ),
                                    Icon(
                                      Icons.close,
                                      color: Colors.white.withOpacity(0.5),
                                      size: 18,
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 15),

                              Align(
                                alignment: Alignment.centerRight,
                                child: Text(
                                  "+ Nuevo Cliente",
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.7),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),

                              const SizedBox(height: 20),

                              Row(
                                children: [
                                  const Icon(
                                    Icons.person_outline,
                                    color: Colors.white54,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 8),
                                  const Text(
                                    "Nombre:",
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 12,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      "JHEFERSON SANTIAGO BLANCO MARTIN",
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 8),

                              Row(
                                children: [
                                  const Icon(
                                    Icons.badge_outlined,
                                    color: Colors.white54,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    tipoComprobante == "Factura"
                                        ? "RUC:"
                                        : "N° Documento:",
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 12,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      tipoComprobante == "Factura"
                                          ? "10760452471"
                                          : "76045247",
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 8),

                              Row(
                                children: [
                                  const Icon(
                                    Icons.location_on_outlined,
                                    color: Colors.white54,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 8),
                                  const Text(
                                    "Dirección:",
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 12,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      "MZ K LT 17 VISTA ALEGRE - CARABAYLLO",
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                      const SizedBox(height: 20),

                      Text(
                        "Detalle de la Orden",
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 14,
                        ),
                      ),

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

                      Align(
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
                                        : [
                                            const Color(0xFFFFD54F),
                                            const Color(0xFFFFB300),
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
                                      : Icons.volunteer_activism_outlined,
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
                            "+ Agregar Descuento o Propina",
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
              const SizedBox(height: 15),

              Text(
                "Descuento: S/ ${totalDescuento().toStringAsFixed(2)}",
                style: const TextStyle(color: Colors.white70),
              ),

              Text(
                "Propina: S/ ${totalPropina().toStringAsFixed(2)}",
                style: const TextStyle(color: Colors.white70),
              ),

              Text(
                "Total final: S/ ${totalFinal().toStringAsFixed(2)}",
                style: const TextStyle(color: Colors.white),
              ),

              Text(
                "Total pagado: S/ ${totalPagado().toStringAsFixed(2)}",
                style: const TextStyle(color: Colors.white),
              ),

              Text(
                "Vuelto: S/ ${(totalPagado() - totalFinal()).toStringAsFixed(2)}",
                style: const TextStyle(color: Colors.white70),
              ),

              const SizedBox(height: 20),

              ElevatedButton(onPressed: () {}, child: const Text("PAGAR")),
            ],
          ),
        ),
      ),
    );
  }
}
