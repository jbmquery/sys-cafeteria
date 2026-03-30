// lib/pages/carta_page.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

import '../widgets/app_sidebar.dart';
import '../widgets/app_navbar.dart';
import '../widgets/app_bottom_tabbar.dart';
import '../widgets/carta/toppings_dialog.dart';

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
  int currentTab = 0;

  String categoriaSeleccionada = "";
  String searchText = "";

  List<Map<String, dynamic>> carrito = [];
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

              const SizedBox(height: 14),

              mesaSection(),

              const SizedBox(height: 14),

              searchSection(),

              const SizedBox(height: 16),

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
              "Pedido para: ${widget.nombreMesa}",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.swap_horiz, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget categorySection() {
    return SizedBox(
      height: 46,
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('categorias')
            .orderBy('fecha_creacion')
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const SizedBox();
          }

          final categorias = snapshot.data!.docs;

          if (categorias.isNotEmpty && categoriaSeleccionada.isEmpty) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              final firstData = categorias.first.data() as Map<String, dynamic>;

              setState(() {
                categoriaSeleccionada = firstData['nombre_cat'] ?? '';
              });
            });
          }

          return ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            itemCount: categorias.length,
            itemBuilder: (context, index) {
              final data = categorias[index].data() as Map<String, dynamic>;
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
                  margin: const EdgeInsets.only(right: 10),
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  decoration: BoxDecoration(
                    gradient: selected
                        ? const LinearGradient(
                            colors: [Color(0xFF00C8AA), Color(0xFF00A896)],
                          )
                        : null,
                    color: selected ? null : Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: Text(
                      categoria,
                      style: TextStyle(
                        color: selected ? Colors.black : Colors.white70,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
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

          const SizedBox(width: 10),

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
                      color: Colors.red,
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

        final Map<String, List<QueryDocumentSnapshot>> agrupados = {};

        for (var doc in filtrados) {
          final data = doc.data() as Map<String, dynamic>;
          final grupo = data['grupo'] ?? '';

          agrupados.putIfAbsent(grupo, () => []);
          agrupados[grupo]!.add(doc);
        }

        return ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          children: agrupados.entries.map((entry) {
            return productCard(entry.key, entry.value);
          }).toList(),
        );
      },
    );
  }

  Widget productCard(String grupo, List<QueryDocumentSnapshot> items) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
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
            spacing: 6,
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
                        if (data["nombre_cat"] == "Toppings") {
                          final resultado = await showDialog(
                            context: context,
                            builder: (_) =>
                                ToppingsDialog(carrito: carrito, topping: data),
                          );

                          if (resultado != null) {
                            setState(() {
                              carrito.add(resultado);
                            });

                            mostrarToast("$grupo agregado");
                          }

                          return;
                        }

                        setState(() {
                          final index = carrito.indexWhere(
                            (item) =>
                                item["grupo"] == data["grupo"] &&
                                item["precio"] == data["precio"] &&
                                item["porcion"] == data["porcion"] &&
                                item["unidad"] == data["unidad"],
                          );

                          if (index != -1) {
                            carrito[index]["cantidad"] += 1;
                          } else {
                            carrito.add({
                              ...data,
                              "cantidad": 1,
                              "id_detalle_padre_temporal": data.hashCode
                                  .toString(),
                            });
                          }
                        });

                        mostrarToast("$grupo agregado");
                      }
                    : null,
                child: Container(
                  constraints: const BoxConstraints(minWidth: 42),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 12,
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

  Future<void> guardarPedido(double subtotal) async {
    try {
      final firestore = FirebaseFirestore.instance;

      final mesaDoc = await firestore
          .collection('mesas')
          .doc(widget.uidMesa)
          .get();

      final mesaData = mesaDoc.data() ?? {};

      final now = DateTime.now();
      final horaFormateada = DateFormat('HH:mm:ss').format(now);

      final pedidoRef = await firestore.collection('pedidos').add({
        "nombre_mesa": widget.nombreMesa,
        "nombre_cliente": "",
        "uid_usuario": widget.uidUsuarioAccion,
        "fecha": Timestamp.now(),
        "hora_pedido": horaFormateada,
        "hora_pago": "",
        "estado": "abierto",
        "cantidad_clientes": mesaData["capacidad"] ?? 0,
        "observacion": "",
        "forma_pago": "",
        "puntos_canjeados_total": 0,
        "monto_pagado": 0.0,
        "monto_vuelto": 0.0,
        "subtotal": subtotal,
      });

      final Map<String, String> detalleIds = {};

      for (final item in carrito) {
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
            "observacion": "",
            "es_canjeable": true,
            "estado": "pendiente",
            "canjeado_por": "",
            "cuenta": 0,
            "id_detalle_padre": "",
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
      await firestore.collection('mesas').doc(widget.uidMesa).update({
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
                        "Carrito",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 20),

                      Expanded(
                        child: carrito.isEmpty
                            ? const Center(
                                child: Text(
                                  "Sin productos",
                                  style: TextStyle(color: Colors.white54),
                                ),
                              )
                            : ListView.builder(
                                itemCount: carrito.length,
                                itemBuilder: (context, index) {
                                  final item = carrito[index];

                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 12),
                                    padding: const EdgeInsets.all(14),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.05),
                                      borderRadius: BorderRadius.circular(16),
                                    ),

                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                (() {
                                                  final nombre =
                                                      item["grupo"] ??
                                                      item["nombre"] ??
                                                      "";

                                                  final porcion =
                                                      item["porcion"]
                                                          ?.toString()
                                                          .trim() ??
                                                      "";
                                                  final unidad =
                                                      item["unidad"]
                                                          ?.toString()
                                                          .trim() ??
                                                      "";

                                                  final detalle =
                                                      "$porcion $unidad".trim();

                                                  return detalle.isNotEmpty
                                                      ? "$nombre - $detalle"
                                                      : nombre;
                                                })(),
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                ),
                                              ),

                                              const SizedBox(height: 4),

                                              Text(
                                                "S/ ${((item["precio"] as num).toDouble()).toStringAsFixed(2)}"
                                                " - x${item["cantidad"]}"
                                                " - S/ ${(((item["precio"] as num).toDouble()) * item["cantidad"]).toStringAsFixed(2)}",
                                                style: const TextStyle(
                                                  color: Colors.white70,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),

                                        GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              if (carrito[index]["cantidad"] >
                                                  1) {
                                                carrito[index]["cantidad"] -= 1;
                                              } else {
                                                carrito.removeAt(index);
                                              }
                                            });

                                            setDialogState(() {});
                                          },
                                          child: const Icon(
                                            Icons.delete_outline,
                                            color: Colors.redAccent,
                                          ),
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
                              "S/ ${subtotal.toStringAsFixed(2)}",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 18),

                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF374151),
                                    Color(0xFF1F2937),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(14),
                              ),

                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                ),
                                onPressed: () {
                                  setState(() {
                                    carrito.clear();
                                  });

                                  setDialogState(() {});
                                },
                                child: const Text("Cancelar"),
                              ),
                            ),
                          ),

                          const SizedBox(width: 10),

                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF00C8AA),
                                    Color(0xFF00A896),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(14),
                              ),

                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                ),
                                onPressed: () async {
                                  await guardarPedido(subtotal);

                                  if (mounted) {
                                    Navigator.pop(context);
                                  }
                                },
                                child: const Text(
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
}
