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
  int numeroCuentaActual = 1;
  bool cargandoPago = false;

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

  List<QueryDocumentSnapshot> obtenerDetallesAPagar() {
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

    final idsPadres = basePadres.map((e) => e.id).toSet();

    final relacionados = widget.detalles.where((d) {
      final x = d.data() as Map<String, dynamic>;

      final idPadre = x['id_detalle_padre'] ?? '';

      return idsPadres.contains(idPadre);
    }).toList();

    final todos = [...basePadres, ...relacionados];

    return todos.where((d) {
      final x = d.data() as Map<String, dynamic>;

      return x['estado'] != 'pagado';
    }).toList();
  }

  String calcularEstadoPedidoLocal(List<Map<String, dynamic>> detalles) {
    final estados = detalles
        .map((e) => (e['estado'] ?? '').toString())
        .toList();

    /// ===== COMPLETADO =====
    final todosPagados = estados.every((e) => e == 'pagado');

    if (todosPagados) {
      return 'completado';
    }

    /// ===== CANCELADO =====
    final todosCanceladosOPerdida = estados.every(
      (e) => e == 'cancelado' || e == 'perdida',
    );

    if (todosCanceladosOPerdida) {
      return 'cancelado';
    }

    /// ===== INCONCLUSO =====
    final tienePagados = estados.any((e) => e == 'pagado');

    final tieneCanceladosOPerdida = estados.any(
      (e) => e == 'cancelado' || e == 'perdida',
    );

    if (tienePagados && tieneCanceladosOPerdida) {
      return 'inconcluso';
    }

    /// ===== ABIERTO =====
    return 'abierto';
  }

  Future<void> realizarPago() async {
    if (cargandoPago) return;

    final total = totalFinal();
    final pagado = totalPagado();

    if (pagado < total) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('El monto pagado es menor al total.')),
      );

      return;
    }

    setState(() {
      cargandoPago = true;
    });

    try {
      final firestore = FirebaseFirestore.instance;

      final pedidoRef = firestore.collection('pedidos').doc(widget.pedidoId);

      final detallesAPagar = obtenerDetallesAPagar();

      final batch = firestore.batch();

      /// ===============================
      /// CREAR PAGOS
      /// ===============================

      for (final p in pagos) {
        final monto = double.tryParse(p["monto"].text) ?? 0;

        if (monto <= 0) continue;

        final pagoRef = pedidoRef.collection('pagos').doc();

        batch.set(pagoRef, {
          'modo_pago': p["tipo"],
          'hora_pago': Timestamp.now(),
          'monto': monto, //evaluacion
          'cuenta': numeroCuentaActual,
          'monto_delivery': totalDelivery(),
          'monto_descuento': totalDescuento(),
          'monto_pagado': monto,
          'monto_propina': totalPropina(),
          'monto_subtotal': totalFinal(),
          'monto_vuelto': totalPagado() - totalFinal(),
        });
      }

      /// ===============================
      /// ACTUALIZAR DETALLES
      /// ===============================

      for (final detalle in detallesAPagar) {
        final detalleRef = pedidoRef.collection('detalle').doc(detalle.id);

        batch.update(detalleRef, {
          'estado': 'pagado',
          'cuenta': numeroCuentaActual,
        });
      }

      /// ===============================
      /// SIMULAR NUEVOS ESTADOS EN MEMORIA
      /// ===============================

      final todosLosDetalles = widget.detalles.map((d) {
        final data = Map<String, dynamic>.from(
          d.data() as Map<String, dynamic>,
        );

        /// si este detalle está dentro de los que se pagarán
        final seraPagado = detallesAPagar.any((x) => x.id == d.id);

        if (seraPagado) {
          data['estado'] = 'pagado';
        }

        return data;
      }).toList();

      final nuevoEstadoPedido = calcularEstadoPedidoLocal(todosLosDetalles);

      batch.update(pedidoRef, {'estado': nuevoEstadoPedido});

      /// ===============================
      /// COMMIT
      /// ===============================

      await batch.commit();

      /// ===============================
      /// ACTUALIZAR SIGUIENTE CUENTA
      /// ===============================

      numeroCuentaActual++;

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pago realizado correctamente')),
        );

        setState(() {});
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error al realizar pago: $e')));
    } finally {
      if (mounted) {
        setState(() {
          cargandoPago = false;
        });
      }
    }
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

  Future<void> obtenerNumeroCuenta() async {
    final pagosSnapshot = await FirebaseFirestore.instance
        .collection('pedidos')
        .doc(widget.pedidoId)
        .collection('pagos')
        .get();

    if (pagosSnapshot.docs.isEmpty) {
      numeroCuentaActual = 1;
      return;
    }

    int maxCuenta = 0;

    for (final doc in pagosSnapshot.docs) {
      final data = doc.data();

      final cuenta = (data['cuenta'] ?? 0) as int;

      if (cuenta > maxCuenta) {
        maxCuenta = cuenta;
      }
    }

    numeroCuentaActual = maxCuenta + 1;
  }

  @override
  void initState() {
    super.initState();

    obtenerNumeroCuenta().then((_) {
      if (mounted) {
        setState(() {});
      }
    });
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

              Text(
                "Cuenta de Pago # $numeroCuentaActual",
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
                  horizontal: 6,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.white.withOpacity(0.2)),
                ),
                child: Column(
                  children: [
                    /// ===== DESCUENTO / PROPINA / DELIVERY =====
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            children: [
                              const Text(
                                "Descuento",
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),

                              const SizedBox(height: 4),

                              Text(
                                "- S/ ${totalDescuento().toStringAsFixed(2)}",
                                style: const TextStyle(
                                  color: Color(0xFFFF6B6B),
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),

                        Expanded(
                          child: Column(
                            children: [
                              const Text(
                                "Propina",
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),

                              const SizedBox(height: 4),

                              Text(
                                "+ S/ ${totalPropina().toStringAsFixed(2)}",
                                style: const TextStyle(
                                  color: Color(0xFFFFD54F),
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),

                        Expanded(
                          child: Column(
                            children: [
                              const Text(
                                "Delivery",
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),

                              const SizedBox(height: 4),

                              Text(
                                "+ S/ ${totalDelivery().toStringAsFixed(2)}",
                                style: const TextStyle(
                                  color: Color(0xFF64B5F6),
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    Divider(color: Colors.white.withOpacity(0.2), height: 1),

                    const SizedBox(height: 12),

                    /// ===== TOTAL / PAGADO / VUELTO =====
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            children: [
                              const Text(
                                "Total Final",
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),

                              const SizedBox(height: 4),

                              Text(
                                "S/ ${totalFinal().toStringAsFixed(2)}",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),

                        Expanded(
                          child: Column(
                            children: [
                              const Text(
                                "Pagado",
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),

                              const SizedBox(height: 4),

                              Text(
                                "S/ ${totalPagado().toStringAsFixed(2)}",
                                style: const TextStyle(
                                  color: Color(0xFF00E5C3),
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),

                        Expanded(
                          child: Column(
                            children: [
                              const Text(
                                "Vuelto",
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),

                              const SizedBox(height: 4),

                              Text(
                                "S/ ${(totalPagado() - totalFinal()).toStringAsFixed(2)}",
                                style: const TextStyle(
                                  color: Color(0xFF64B5F6),
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
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
                    onPressed: cargandoPago ? null : realizarPago,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: cargandoPago
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.black,
                            ),
                          )
                        : const Text(
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
