import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CambiarMesaDialog extends StatefulWidget {
  final String uidMesaActual;

  const CambiarMesaDialog({super.key, required this.uidMesaActual});

  @override
  State<CambiarMesaDialog> createState() => _CambiarMesaDialogState();
}

class _CambiarMesaDialogState extends State<CambiarMesaDialog> {
  String? mesaSeleccionada;
  String? nombreMesaSeleccionada;

  @override
  Widget build(BuildContext context) {
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
              "Cambiar mesa",
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            SizedBox(
              height: 280,
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('mesas')
                    .where('disponibilidad', isEqualTo: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    );
                  }

                  final mesas = snapshot.data!.docs
                      .where((doc) => doc.id != widget.uidMesaActual)
                      .toList();

                  if (mesas.isEmpty) {
                    return const Center(
                      child: Text(
                        "No hay mesas disponibles",
                        style: TextStyle(color: Colors.white70),
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: mesas.length,
                    itemBuilder: (context, index) {
                      final data = mesas[index].data() as Map<String, dynamic>;

                      final uid = mesas[index].id;
                      final nombre = data["nombre_mesa"] ?? "";
                      final tipo = data["tipo_mesa"] ?? "";
                      final capacidad = data["capacidad"] ?? 0;

                      final selected = uid == mesaSeleccionada;

                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            mesaSeleccionada = uid;
                            nombreMesaSeleccionada = nombre;
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
                                nombre,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),

                              const SizedBox(height: 4),

                              Text(
                                "$tipo • Capacidad $capacidad",
                                style: const TextStyle(
                                  color: Colors.white54,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),

            const SizedBox(height: 20),

            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: mesaSeleccionada == null
                        ? null
                        : () {
                            Navigator.pop(context, {
                              "uid": mesaSeleccionada,
                              "nombre": nombreMesaSeleccionada,
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
