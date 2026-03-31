//lib/widgets/carta/toppings_dialog.dart
import 'package:flutter/material.dart';

class ToppingsDialog extends StatefulWidget {
  final List<Map<String, dynamic>> carrito;
  final Map<String, dynamic> topping;

  const ToppingsDialog({
    super.key,
    required this.carrito,
    required this.topping,
  });

  @override
  State<ToppingsDialog> createState() => _ToppingsDialogState();
}

class _ToppingsDialogState extends State<ToppingsDialog> {
  int? selectedIndex;

  @override
  Widget build(BuildContext context) {
    final productosBase = widget.carrito
        .where((item) => item["nombre_cat"] != "Toppings")
        .toList();

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFF111827),
          borderRadius: BorderRadius.circular(28),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Seleccionar producto",
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            if (productosBase.isEmpty)
              const Text(
                "Primero agrega un producto base",
                style: TextStyle(color: Colors.white70),
              )
            else
              SizedBox(
                height: 280,
                child: ListView.builder(
                  itemCount: productosBase.length,
                  itemBuilder: (context, index) {
                    final item = productosBase[index];

                    final temporal =
                        item["id_detalle_padre_temporal"]?.toString() ?? "";

                    final toppingsRelacionados = widget.carrito.where((e) {
                      return e["nombre_cat"] == "Toppings" &&
                          e["id_detalle_padre_temporal"] == temporal;
                    }).toList();

                    final nombre = item["grupo"] ?? "";
                    final porcion = item["porcion"]?.toString().trim() ?? "";
                    final unidad = item["unidad"]?.toString().trim() ?? "";

                    final detalle = "$porcion $unidad".trim();

                    final titulo = detalle.isNotEmpty
                        ? "$nombre - $detalle"
                        : nombre;

                    final selected = selectedIndex == index;

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedIndex = index;
                        });
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: selected
                              ? const Color.fromARGB(255, 111, 114, 255)
                              : Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              titulo,
                              style: const TextStyle(color: Colors.white),
                            ),

                            if (toppingsRelacionados.isNotEmpty)
                              ...toppingsRelacionados.map((topping) {
                                final toppingNombre = topping["grupo"] ?? "";

                                return Padding(
                                  padding: const EdgeInsets.only(
                                    left: 8,
                                    top: 4,
                                  ),
                                  child: Text(
                                    "↳ $toppingNombre",
                                    style: const TextStyle(
                                      color: Colors.greenAccent,
                                      fontSize: 12,
                                    ),
                                  ),
                                );
                              }),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

            const SizedBox(height: 20),

            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: selectedIndex == null
                        ? null
                        : () {
                            final padre = productosBase[selectedIndex!];

                            Navigator.pop(context, {
                              ...widget.topping,
                              "cantidad": 1,
                              "id_detalle_padre_temporal":
                                  padre["id_detalle_padre_temporal"],
                            });
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 111, 114, 255),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text("Guardar"),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.white24),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  "Cerrar",
                  style: TextStyle(color: Colors.white70),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
