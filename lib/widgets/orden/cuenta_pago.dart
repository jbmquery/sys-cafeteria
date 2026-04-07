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

    final base = usarTodos ? padres : seleccionados;

    final Map<String, List<QueryDocumentSnapshot>> agrupados = {};

    for (final d in base) {
      final x = d.data() as Map<String, dynamic>;

      final key =
          "${x['nombre']}_${x['precio']}_${x['porcion']}_${x['unidad']}";

      agrupados.putIfAbsent(key, () => []);
      agrupados[key]!.add(d);
    }

    return agrupados.values.map((items) {
      final x = items.first.data() as Map<String, dynamic>;

      return {
        "nombre": x['nombre'],
        "precio": x['precio'],
        "porcion": x['porcion'],
        "unidad": x['unidad'],
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

              Column(
                children: [
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
                          /// BUSCADOR CLIENTE
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
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

                          /// DATOS CLIENTE VISUAL
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
                ],
              ),

              const SizedBox(height: 20),

              Expanded(
                child: ListView.builder(
                  itemCount: resumen.length,
                  itemBuilder: (context, index) {
                    final item = resumen[index];

                    final total =
                        (item["precio"] as num).toDouble() * item["cantidad"];

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
                            "${item["nombre"]} (${item["porcion"]} ${item["unidad"]})",
                            style: const TextStyle(color: Colors.white),
                          ),
                          Text(
                            "S/ ${item["precio"]} x${item["cantidad"]} = S/ ${total.toStringAsFixed(2)}",
                            style: const TextStyle(color: Colors.white70),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(16),
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

              ...pagos.map((p) {
                return Row(
                  children: [
                    Expanded(
                      child: DropdownButton<String>(
                        value: p["tipo"],
                        dropdownColor: const Color(0xFF1E293B),
                        items: const [
                          DropdownMenuItem(
                            value: "efectivo",
                            child: Text("Efectivo"),
                          ),
                          DropdownMenuItem(value: "yape", child: Text("Yape")),
                          DropdownMenuItem(value: "plin", child: Text("Plin")),
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

                    const SizedBox(width: 10),

                    Expanded(
                      child: TextField(
                        controller: p["monto"],
                        keyboardType: TextInputType.number,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(hintText: "Monto"),
                        onChanged: (_) {
                          setState(() {});
                        },
                      ),
                    ),
                  ],
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
                child: const Icon(Icons.add, color: Colors.white),
              ),

              const SizedBox(height: 16),

              Text(
                "Total pagado: S/ ${totalPagado().toStringAsFixed(2)}",
                style: const TextStyle(color: Colors.white),
              ),

              Text(
                "Vuelto: S/ ${(totalPagado() - subtotal()).toStringAsFixed(2)}",
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
