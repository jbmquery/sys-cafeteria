// lib/pages/carta_page.dart
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

import '../widgets/app_sidebar.dart';
import '../widgets/app_navbar.dart';
import '../widgets/app_bottom_tabbar.dart';
import '../widgets/carta/agregar_editar_toppings.dart';
import '../widgets/carta/cambiar_mesa_dialog.dart';
import '../widgets/carta/cantidad_personas_dialog.dart';
import '../services/impresora/printer_service.dart';
import '../services/impresora/firebase_printer_service.dart';
import '../widgets/carta/impresion_cocina.dart';

class CartaPage extends StatefulWidget {
  final String nombreMesa;
  final String uidMesa;
  final String uidUsuarioAccion;

  const CartaPage({
    super.key,
    required this.nombreMesa,
    required this.uidMesa,
    required this.uidUsuarioAccion,
  });

  @override
  State<CartaPage> createState() => _CartaPageState();
}

class _CartaPageState extends State<CartaPage> {
  String nombreMesaActual = "";
  String uidMesaActual = "";

  int currentTab = 0;

  @override
  void initState() {
    super.initState();
    nombreMesaActual = widget.nombreMesa;
    uidMesaActual = widget.uidMesa;
  }

  String categoriaSeleccionada = "";
  String searchText = "";

  List<Map<String, dynamic>> carrito = [];

  bool isPrinting = false;

  final List<OverlayEntry> _toasts = [];

  final TextEditingController searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppSidebar(),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0B0F1A), Color(0xFF111827), Color(0xFF1E293B)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const AppNavbar(),

              const SizedBox(height: 8),

              categorySection(),

              const SizedBox(height: 8),

              mesaSection(),

              const SizedBox(height: 8),

              searchSection(),

              const SizedBox(height: 8),

              Expanded(child: productosSection()),

              AppBottomTabBar(
                currentIndex: currentTab,
                onTap: (index) {
                  setState(() {
                    currentTab = index;
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget mesaSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: Text(
              "Pedido para: $nombreMesaActual",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          GestureDetector(
            onTap: abrirCambiarMesaDialog,
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.swap_horiz, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget categorySection() {
    return SizedBox(
      height: 40,
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('categorias')
            .where('nivel', isEqualTo: 'primario')
            .orderBy('fecha_creacion')
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const SizedBox();
          }

          final categorias = snapshot.data!.docs;

          if (categorias.isEmpty) {
            return const SizedBox(); // o puedes poner un loader si quieres
          }

          if (categorias.isNotEmpty && categoriaSeleccionada.isEmpty) {
            final firstData = categorias.first.data() as Map<String, dynamic>;
            final primeraCategoria = firstData['nombre_cat'] ?? '';

            // ⚠️ SOLO setea si aún no coincide
            if (categoriaSeleccionada != primeraCategoria) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) {
                  setState(() {
                    categoriaSeleccionada = primeraCategoria;
                  });
                }
              });
            }
          }

          return LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: ConstrainedBox(
                  constraints: BoxConstraints(minWidth: constraints.maxWidth),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(width: 14),

                      ...categorias.map((doc) {
                        final data = doc.data() as Map<String, dynamic>;
                        final categoria = data['nombre_cat'] ?? '';

                        final selected = categoria == categoriaSeleccionada;

                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              categoriaSeleccionada = categoria;
                            });
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            margin: const EdgeInsets.only(right: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 18),
                            decoration: BoxDecoration(
                              gradient: selected
                                  ? const LinearGradient(
                                      colors: [
                                        Color(0xFF00C8AA),
                                        Color(0xFF00A896),
                                      ],
                                    )
                                  : null,
                              color: selected
                                  ? null
                                  : Colors.white.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Center(
                              child: Text(
                                categoria,
                                style: TextStyle(
                                  color: selected
                                      ? Colors.black
                                      : Colors.white70,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),

                      const SizedBox(width: 8),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget searchSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: searchController,
              style: const TextStyle(color: Colors.white),
              onChanged: (value) {
                setState(() {
                  searchText = value.toLowerCase();
                });
              },
              decoration: InputDecoration(
                hintText: "Buscar producto...",
                hintStyle: const TextStyle(color: Colors.white54),
                prefixIcon: const Icon(Icons.search, color: Colors.white54),
                filled: true,
                fillColor: Colors.white.withOpacity(0.05),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          const SizedBox(width: 8),

          Stack(
            children: [
              GestureDetector(
                onTap: abrirCarrito,
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.shopping_cart, color: Colors.white),
                ),
              ),

              if (carrito.isNotEmpty)
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    padding: const EdgeInsets.all(5),
                    decoration: const BoxDecoration(
                      color: Color.fromARGB(255, 243, 59, 157),
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      carrito
                          .fold(
                            0,
                            (sum, item) => sum + (item["cantidad"] as int),
                          )
                          .toString(),
                      style: const TextStyle(color: Colors.white, fontSize: 10),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget productosSection() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('carta')
          .where('estado', isEqualTo: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.white),
          );
        }

        final docs = snapshot.data!.docs;

        final filtrados = docs.where((doc) {
          final data = doc.data() as Map<String, dynamic>;

          final grupo = (data['grupo'] ?? '').toString();
          final nombreCat = (data['nombre_cat'] ?? '').toString();

          final matchCategoria =
              categoriaSeleccionada.isEmpty ||
              nombreCat.toLowerCase() == categoriaSeleccionada.toLowerCase();

          final matchSearch = grupo.toLowerCase().contains(
            searchText.toLowerCase(),
          );

          return matchCategoria && matchSearch;
        }).toList();

        final Map<String, Map<String, List<QueryDocumentSnapshot>>>
        dataAgrupada = {};

        for (var doc in filtrados) {
          final data = doc.data() as Map<String, dynamic>;

          final subcat = (data['nombre_subcat'] ?? '').toString();
          final grupo = (data['grupo'] ?? '').toString();

          dataAgrupada.putIfAbsent(subcat, () => {});
          dataAgrupada[subcat]!.putIfAbsent(grupo, () => []);
          dataAgrupada[subcat]![grupo]!.add(doc);
        }

        // 🔠 ordenar subcategorías
        final subcatsOrdenadas = dataAgrupada.keys.toList()..sort();

        return ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          children: subcatsOrdenadas.expand((subcat) {
            final grupos = dataAgrupada[subcat]!;

            // 🔠 ordenar grupos
            final gruposOrdenados = grupos.keys.toList()..sort();

            return [
              /// 🔹 SEPARADOR SUBCATEGORIA
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Row(
                  children: [
                    Expanded(child: Divider(color: Colors.white24)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Text(
                        subcat,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Expanded(child: Divider(color: Colors.white24)),
                  ],
                ),
              ),

              /// 🔹 PRODUCTOS POR GRUPO
              ...gruposOrdenados.map((grupo) {
                return productCard(grupo, grupos[grupo]!);
              }),
            ];
          }).toList(),
        );
      },
    );
  }

  Widget productCard(String grupo, List<QueryDocumentSnapshot> items) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Text(
              grupo,
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
          ),

          Wrap(
            spacing: 5,
            children: items.map((doc) {
              final data = doc.data() as Map<String, dynamic>;

              final porcion = data['porcion'];
              final unidad = data['unidad'];
              final disponible = data['disponibilidad'] ?? true;

              String texto = "+";

              if ((porcion != null && porcion.toString().isNotEmpty) ||
                  (unidad != null && unidad.toString().isNotEmpty)) {
                texto = "${porcion ?? ''} ${unidad ?? ''}".trim();
              }

              return GestureDetector(
                onTap: disponible
                    ? () async {
                        // ❌ BLOQUEAR toppings como producto independiente
                        if (data["nombre_cat"] == "Toppings") return;

                        final resultado = await showDialog(
                          context: context,
                          builder: (_) =>
                              AgregarEditarToppingsDialog(producto: data),
                        );

                        if (resultado == null) return;

                        final producto = resultado["producto"];
                        final toppings = resultado["toppings"] as List;
                        final observacion = resultado["observacion"];

                        final uniqueId =
                            "${DateTime.now().microsecondsSinceEpoch}_${Random().nextInt(9999)}";

                        setState(() {
                          /// 🟢 PRODUCTO PADRE
                          carrito.add({
                            ...producto,
                            "cantidad": 1,
                            "observacion": observacion,
                            "id_detalle_padre_temporal": uniqueId,
                          });

                          /// 🟣 TOPPINGS HIJOS
                          for (var t in toppings) {
                            carrito.add({
                              ...t,
                              "cantidad": 1,
                              "id_detalle_padre_temporal": uniqueId,
                            });
                          }
                        });

                        mostrarToast("${producto["grupo"]} agregado");
                      }
                    : null,
                child: Container(
                  constraints: const BoxConstraints(minWidth: 42),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    gradient: disponible
                        ? const LinearGradient(
                            colors: [Color(0xFF00C8AA), Color(0xFF00A896)],
                          )
                        : const LinearGradient(
                            colors: [
                              Color.fromARGB(255, 243, 59, 157),
                              Color.fromARGB(255, 200, 6, 109),
                            ],
                          ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    texto,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: disponible ? Colors.black : Colors.white70,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  void mostrarToast(String mensaje) {
    final overlay = Overlay.of(context);

    late OverlayEntry entry;

    entry = OverlayEntry(
      builder: (_) => Positioned(
        top: 60,
        left: 20,
        right: 20,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF00C8AA), Color(0xFF00A896)],
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              mensaje,
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );

    overlay.insert(entry);

    Future.delayed(const Duration(milliseconds: 500), () {
      entry.remove();
    });
  }

  void abrirCambiarMesaDialog() async {
    final resultado = await showDialog(
      context: context,
      builder: (_) => CambiarMesaDialog(uidMesaActual: uidMesaActual),
    );

    if (resultado != null) {
      setState(() {
        nombreMesaActual = resultado["nombre"];
        uidMesaActual = resultado["uid"];
      });

      mostrarToast("Mesa cambiada");
    }
  }

  Future<void> guardarPedido(
    double subtotal, {
    int? cantidadClientesManual,
  }) async {
    try {
      final firestore = FirebaseFirestore.instance;

      final mesaDoc = await firestore
          .collection('mesas')
          .doc(uidMesaActual)
          .get();

      final mesaData = mesaDoc.data() ?? {};

      final now = DateTime.now();
      final horaFormateada = DateFormat('HH:mm:ss').format(now);

      final contadorRef = firestore.collection('contadores').doc('global');

      final pedidoRef = await firestore.runTransaction((transaction) async {
        final contadorSnap = await transaction.get(contadorRef);

        final contadorActual = (contadorSnap.data()?['pedidos'] ?? 1) as int;

        final nuevoPedidoRef = firestore.collection('pedidos').doc();

        transaction.set(nuevoPedidoRef, {
          "cantidad_clientes":
              cantidadClientesManual ?? mesaData["capacidad"] ?? 0,
          "estado": "abierto",
          "fecha": Timestamp.now(),
          "hora_pedido": horaFormateada,
          "monto_delivery": 0.0,
          "monto_descuento": 0.0,
          "monto_subtotal": subtotal,
          "monto_pagado": 0.0,
          "monto_propina": 0.0,
          "monto_vuelto": 0.0,
          "num_pedido": contadorActual,
          "uid_usuario": widget.uidUsuarioAccion,
          "nombre_mesa": nombreMesaActual,
          "tipo_mesa": mesaData["tipo_mesa"] ?? "",
          "id_cliente": "",
          "nombre_cliente": "",
          "puntos_canjeados_total": 0,
        });

        transaction.update(contadorRef, {"pedidos": contadorActual + 1});

        return nuevoPedidoRef;
      });

      final Map<String, String> detalleIds = {};

      final carritoOrdenado = [
        ...carrito.where((e) => e["nombre_cat"] != "Toppings"),
        ...carrito.where((e) => e["nombre_cat"] == "Toppings"),
      ];

      for (final item in carritoOrdenado) {
        final cantidad = item["cantidad"] as int;

        for (int i = 0; i < cantidad; i++) {
          final detalleRef = await pedidoRef.collection("detalle").add({
            "nombre": item["nombre"] ?? item["grupo"] ?? "",
            "precio": (item["precio"] as num).toDouble(),
            "porcion": item["porcion"] ?? "",
            "unidad": item["unidad"] ?? "",
            "nombre_cat": item["nombre_cat"] ?? "",
            "nombre_subcat": item["nombre_subcat"] ?? "",
            "puntos": item["puntos"] ?? 0,
            "abreviado": item["abreviado"] ?? "",
            "observacion": item["observacion"] ?? "",
            "es_canjeable": true,
            "estado": "pendiente",
            "canjeado_por": "",
            "cuenta": 0,
            "id_detalle_padre": "",
            "grupo": item["grupo"] ?? "",
            "uid_usuario": widget.uidUsuarioAccion,
            "codigo_barra": "",
            "vence": "",
          });

          final temporal = item["id_detalle_padre_temporal"]?.toString() ?? "";

          if (item["nombre_cat"] != "Toppings") {
            detalleIds[temporal] = detalleRef.id;
          }

          if (item["nombre_cat"] == "Toppings") {
            await detalleRef.update({
              "id_detalle_padre": detalleIds[temporal] ?? "",
            });
          }
        }
      }

      // ✅ AQUÍ CAMBIA EL ESTADO DE LA MESA
      await firestore.collection('mesas').doc(uidMesaActual).update({
        "disponibilidad": false,
      });

      setState(() {
        carrito.clear();
      });

      mostrarToast("Pedido guardado");
    } catch (e) {
      debugPrint(e.toString());
      mostrarToast("Error al guardar");
    }
  }

  Future<void> guardarPedidoConValidacion(double subtotal) async {
    final firestore = FirebaseFirestore.instance;

    final mesaDoc = await firestore
        .collection('mesas')
        .doc(uidMesaActual)
        .get();

    final mesaData = mesaDoc.data() ?? {};

    final tipoMesa = mesaData["tipo_mesa"] ?? "";

    if (tipoMesa == "Mesa") {
      final cantidad = await showDialog<int>(
        context: context,
        builder: (_) => const CantidadPersonasDialog(),
      );

      if (cantidad == null) {
        return;
      }

      await guardarPedido(subtotal, cantidadClientesManual: cantidad);

      return;
    }

    await guardarPedido(subtotal);
  }

  void abrirCarrito() {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "",
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 300),

      pageBuilder: (context, animation, secondaryAnimation) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            // 🔥 AGRUPAR POR PRODUCTO PADRE
            final Map<String, Map<String, dynamic>> productosMap = {};

            for (final item in carrito) {
              final parentId = item["id_detalle_padre_temporal"];

              if (item["nombre_cat"] != "Toppings") {
                productosMap[parentId] = {
                  "producto": item,
                  "toppings": <Map<String, dynamic>>[],
                };
              }
            }

            // 🔥 ASIGNAR TOPPINGS A SU PADRE
            for (final item in carrito) {
              if (item["nombre_cat"] == "Toppings") {
                final parentId = item["id_detalle_padre_temporal"];

                if (productosMap.containsKey(parentId)) {
                  productosMap[parentId]!["toppings"].add(item);
                }
              }
            }

            final carritoVisual = productosMap.values.toList();
            double subtotal = carrito.fold(
              0.0,
              (double sum, item) =>
                  sum + ((item["precio"] as num).toDouble() * item["cantidad"]),
            );

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
                        "Carrito Pedido",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 10),

                      Expanded(
                        child: carrito.isEmpty
                            ? const Center(
                                child: Text(
                                  "Sin productos",
                                  style: TextStyle(color: Colors.white54),
                                ),
                              )
                            : ListView.builder(
                                itemCount: carritoVisual.length,
                                itemBuilder: (context, index) {
                                  final bloque = carritoVisual[index];

                                  final producto = bloque["producto"];
                                  final toppings =
                                      bloque["toppings"]
                                          as List<Map<String, dynamic>>;

                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      /// 🟢 PRODUCTO PADRE
                                      Container(
                                        margin: const EdgeInsets.only(
                                          bottom: 6,
                                        ),
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: GestureDetector(
                                                onTap: () async {
                                                  final temporal =
                                                      producto["id_detalle_padre_temporal"];

                                                  final resultado = await showDialog(
                                                    context: context,
                                                    builder: (_) =>
                                                        AgregarEditarToppingsDialog(
                                                          producto: producto,
                                                          toppingsIniciales:
                                                              toppings,
                                                          observacionInicial:
                                                              producto["observacion"] ??
                                                              "",
                                                        ),
                                                  );

                                                  if (resultado == null) return;

                                                  final nuevosToppings =
                                                      resultado["toppings"];
                                                  final observacion =
                                                      resultado["observacion"];

                                                  setState(() {
                                                    carrito.removeWhere(
                                                      (e) =>
                                                          e["id_detalle_padre_temporal"] ==
                                                          temporal,
                                                    );

                                                    carrito.add({
                                                      ...producto,
                                                      "cantidad": 1,
                                                      "observacion":
                                                          observacion,
                                                      "id_detalle_padre_temporal":
                                                          temporal,
                                                    });

                                                    for (var t
                                                        in nuevosToppings) {
                                                      carrito.add({
                                                        ...t,
                                                        "cantidad": 1,
                                                        "id_detalle_padre_temporal":
                                                            temporal,
                                                      });
                                                    }
                                                  });

                                                  setDialogState(() {});
                                                },
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      (producto["porcion"] !=
                                                                      null &&
                                                                  producto["porcion"]
                                                                      .toString()
                                                                      .isNotEmpty) ||
                                                              (producto["unidad"] !=
                                                                      null &&
                                                                  producto["unidad"]
                                                                      .toString()
                                                                      .isNotEmpty)
                                                          ? "${producto["grupo"] ?? producto["nombre"]} (${producto["porcion"] ?? ""} ${producto["unidad"] ?? ""})"
                                                                .trim()
                                                          : "${producto["grupo"] ?? producto["nombre"]}",
                                                      style: const TextStyle(
                                                        color: Colors.white,
                                                      ),
                                                    ),

                                                    if (producto["observacion"] !=
                                                            null &&
                                                        producto["observacion"]
                                                            .toString()
                                                            .isNotEmpty)
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets.only(
                                                              top: 4,
                                                            ),
                                                        child: Text(
                                                          "Obs: ${producto["observacion"]}",
                                                          style:
                                                              const TextStyle(
                                                                color: Color(
                                                                  0xFF00C8AA,
                                                                ),
                                                                fontSize: 12,
                                                              ),
                                                        ),
                                                      ),

                                                    const SizedBox(height: 5),

                                                    Text(
                                                      "S/ ${((producto["precio"] as num).toDouble()).toStringAsFixed(2)}",
                                                      style: const TextStyle(
                                                        color: Colors.white70,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),

                                            /// ❌ ELIMINAR TODO EL BLOQUE (padre + toppings)
                                            GestureDetector(
                                              onTap: () {
                                                final temporal =
                                                    producto["id_detalle_padre_temporal"] ??
                                                    "";

                                                setState(() {
                                                  carrito.removeWhere(
                                                    (e) =>
                                                        e["id_detalle_padre_temporal"] ==
                                                        temporal,
                                                  );
                                                });

                                                setDialogState(() {});
                                              },
                                              child: const Icon(
                                                Icons.delete_outline,
                                                color: Color.fromARGB(
                                                  255,
                                                  243,
                                                  59,
                                                  157,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),

                                      /// 🟣 TOPPINGS AGRUPADOS
                                      ..._buildToppingsAgrupados(toppings),
                                    ],
                                  );
                                },
                              ),
                      ),

                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),

                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Subtotal pedido",
                              style: TextStyle(color: Colors.white70),
                            ),

                            Text(
                              "S/ ${subtotal.toStringAsFixed(2)}",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 18),

                      Row(
                        children: [
                          Expanded(
                            child: SizedBox(
                              height: 48,
                              child: OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(
                                    color: Color(0xFF00C8AA),
                                    width: 1.2,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  backgroundColor: Colors.transparent,
                                ),
                                onPressed: () {
                                  setState(() {
                                    carrito.clear();
                                  });

                                  setDialogState(() {});
                                },
                                child: const Text(
                                  "Borrar Todo",
                                  style: TextStyle(color: Color(0xFF00C8AA)),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(width: 10),

                          Expanded(
                            child: Container(
                              height: 48,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF00C8AA),
                                    Color(0xFF00A896),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                ),
                                onPressed: isPrinting
                                    ? null
                                    : () async {
                                        setState(() => isPrinting = true);

                                        try {
                                          await guardarPedidoConValidacion(
                                            subtotal,
                                          );

                                          // 🔥 IMPRIMIR COCINA
                                          try {
                                            final printerService =
                                                PrinterService();
                                            final firebase =
                                                FirebasePrinterService();

                                            final config = await firebase
                                                .checkAndInitializeDevice();

                                            final bytes =
                                                await ImpresionCocina.generar(
                                                  mesa: "Mesa 1",
                                                  numPedido: 14,
                                                  hora: "14:59",
                                                  items: carrito.map((e) {
                                                    return {
                                                      "nombre": e["nombre"],
                                                      "cantidad":
                                                          e["cantidad"] ?? 1,
                                                      "observacion":
                                                          e["observacion"] ??
                                                          "",
                                                    };
                                                  }).toList(),
                                                );

                                            await printerService.sendBytes(
                                              bytes: bytes,
                                              type: config?["printer_type"],
                                              address: config?["printer_mac"],
                                            );
                                          } catch (e) {
                                            print(
                                              "Error imprimiendo cocina: $e",
                                            );
                                          }

                                          if (mounted) {
                                            Navigator.pop(context);
                                          }
                                        } finally {
                                          setState(() => isPrinting = false);
                                        }
                                      },
                                child: isPrinting
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.black,
                                        ),
                                      )
                                    : const Text(
                                        "Guardar",
                                        style: TextStyle(color: Colors.black),
                                      ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },

      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1, 0),
            end: Offset.zero,
          ).animate(animation),
          child: child,
        );
      },
    );
  }

  List<Widget> _buildToppingsAgrupados(List<Map<String, dynamic>> toppings) {
    final Map<String, List<Map<String, dynamic>>> agrupados = {};

    for (var t in toppings) {
      final key = "${t["nombre"]}_${t["precio"]}";
      agrupados.putIfAbsent(key, () => []);
      agrupados[key]!.add(t);
    }

    return agrupados.values.map((items) {
      final t = items.first;

      return Container(
        margin: const EdgeInsets.only(bottom: 8, left: 16),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Text(
          "↳ ${t["nombre"]} x${items.length} = S/${(items.length * (t["precio"] as num).toDouble()).toStringAsFixed(2)}",
          style: const TextStyle(color: Colors.white70),
        ),
      );
    }).toList();
  }
}
