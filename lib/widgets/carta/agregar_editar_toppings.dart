//lib/widgets/carta/agregar_editar_toppings.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AgregarEditarToppingsDialog extends StatefulWidget {
  final Map<String, dynamic> producto;
  final List<Map<String, dynamic>> toppingsIniciales;
  final String observacionInicial;

  const AgregarEditarToppingsDialog({
    super.key,
    required this.producto,
    this.toppingsIniciales = const [],
    this.observacionInicial = "",
  });

  @override
  State<AgregarEditarToppingsDialog> createState() =>
      _AgregarEditarToppingsDialogState();
}

class _AgregarEditarToppingsDialogState
    extends State<AgregarEditarToppingsDialog> {
  Map<String, int> toppingsSeleccionados = {};
  final TextEditingController observacionController = TextEditingController();

  List<QueryDocumentSnapshot> toppingsDisponibles = [];

  final List<String> sugerencias = [
    "Poco azucar",
    "Sin Chantilly",
    "Helado",
    "Leche sin Lactosa",
    "Poco cafe",
    "Sin azucar",
    "Fresco",
  ];

  @override
  void initState() {
    super.initState();

    observacionController.text = widget.observacionInicial;

    // cargar toppings iniciales (modo editar)
    for (var t in widget.toppingsIniciales) {
      final id = t["id"];
      toppingsSeleccionados[id] = (toppingsSeleccionados[id] ?? 0) + 1;
    }

    cargarToppings();
  }

  Future<void> cargarToppings() async {
    final snap = await FirebaseFirestore.instance
        .collection("carta")
        .where("nombre_cat", isEqualTo: "Toppings")
        .where("estado", isEqualTo: true) // 👈 FILTRO CLAVE
        .get();

    setState(() {
      toppingsDisponibles = snap.docs;
    });
  }

  void toggleTopping(QueryDocumentSnapshot doc) {
    final id = doc.id;

    setState(() {
      toppingsSeleccionados[id] = (toppingsSeleccionados[id] ?? 0) + 1;
    });
  }

  void longPressTopping(QueryDocumentSnapshot doc) {
    final id = doc.id;

    setState(() {
      if (!toppingsSeleccionados.containsKey(id)) return;

      if (toppingsSeleccionados[id]! <= 1) {
        toppingsSeleccionados.remove(id);
      } else {
        toppingsSeleccionados[id] = toppingsSeleccionados[id]! - 1;
      }
    });
  }

  void agregarSugerencia(String texto) {
    final actual = observacionController.text.trim();

    setState(() {
      observacionController.text = actual.isEmpty
          ? "$texto, "
          : "$actual, $texto, ";
    });
  }

  @override
  Widget build(BuildContext context) {
    final producto = widget.producto;

    final nombre = producto["grupo"] ?? producto["nombre"] ?? "";
    final porcion = producto["porcion"] ?? "";
    final unidad = producto["unidad"] ?? "";

    return Dialog(
      backgroundColor: const Color(0xFF111827),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.all(18),
        constraints: const BoxConstraints(maxHeight: 600),
        child: Column(
          children: [
            /// 🧱 HEADER FIJO
            const Text(
              "Agregar Toppings y Observaciones",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            Text(
              "$nombre ${porcion ?? ""} ${unidad ?? ""}",
              style: const TextStyle(color: Color.fromARGB(255, 0, 200, 170)),
            ),

            const SizedBox(height: 20),

            /// 🥪 CONTENIDO SCROLLEABLE
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Toppings",
                      style: const TextStyle(color: Colors.white70),
                    ),

                    const SizedBox(height: 20),

                    /// 🔥 TOPPINGS
                    Wrap(
                      spacing: 5,
                      runSpacing: 5,
                      children: toppingsDisponibles.map((doc) {
                        final data = doc.data() as Map<String, dynamic>;

                        final id = doc.id;
                        final nombre = data["nombre"] ?? "";

                        final count = toppingsSeleccionados[id] ?? 0;
                        final seleccionado = count > 0;

                        final disponible = data["disponibilidad"] ?? true;

                        return GestureDetector(
                          onTap: disponible ? () => toggleTopping(doc) : null,
                          onDoubleTap: disponible
                              ? () => longPressTopping(doc)
                              : null,
                          child: Stack(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 5,
                                ),
                                decoration: BoxDecoration(
                                  color: seleccionado
                                      ? const Color(0xFF00C8AA)
                                      : disponible
                                      ? Colors.white.withOpacity(0.2)
                                      : Colors.white.withOpacity(
                                          0.08,
                                        ), // 👈 más tenue si no disponible
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  nombre,
                                  style: TextStyle(
                                    color: seleccionado
                                        ? Colors.black
                                        : disponible
                                        ? Colors.white
                                        : Colors.white38, // 👈 apagado
                                    fontSize: 14,
                                  ),
                                ),
                              ),

                              if (count > 1)
                                Positioned(
                                  right: 0,
                                  top: 0,
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: const BoxDecoration(
                                      color: Colors.pink,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Text(
                                      count.toString(),
                                      style: const TextStyle(
                                        fontSize: 10,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 25),

                    Text(
                      "Observaciones y sugerencias",
                      style: const TextStyle(color: Colors.white70),
                    ),

                    const SizedBox(height: 20),

                    /// 💬 SUGERENCIAS
                    Wrap(
                      spacing: 5,
                      runSpacing: 5,
                      children: sugerencias.map((s) {
                        return GestureDetector(
                          onTap: () => agregarSugerencia(s),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              s,
                              style: const TextStyle(color: Colors.white70),
                            ),
                          ),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 10),

                    /// ✏️ INPUT
                    TextField(
                      controller: observacionController,
                      maxLines: 3,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: "Observaciones...",
                        hintStyle: const TextStyle(color: Colors.white54),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.05),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),

            /// 🧱 BOTONES FIJOS
            const SizedBox(height: 10),

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
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        "Cancelar",
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
                        colors: [Color(0xFF00C8AA), Color(0xFF00A896)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                      ),
                      onPressed: () {
                        final toppingsFinal = <Map<String, dynamic>>[];

                        for (var doc in toppingsDisponibles) {
                          final id = doc.id;
                          final cantidad = toppingsSeleccionados[id] ?? 0;

                          if (cantidad > 0) {
                            final data = doc.data() as Map<String, dynamic>;

                            for (int i = 0; i < cantidad; i++) {
                              toppingsFinal.add({...data, "id": id});
                            }
                          }
                        }

                        Navigator.pop(context, {
                          "producto": producto,
                          "toppings": toppingsFinal,
                          "observacion": observacionController.text.trim(),
                        });
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
          ],
        ),
      ),
    );
  }
}
