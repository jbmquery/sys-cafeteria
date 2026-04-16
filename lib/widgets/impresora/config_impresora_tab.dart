//lib/widgets/impresora/config_impresora_tab.dart
import 'package:flutter/material.dart';
import '../../services/impresora/firebase_printer_service.dart';
import '../../services/impresora/printer_service.dart';
import 'buscar_impresora_dialog.dart';
import 'impresion_prueba.dart';
import 'impresion_prueba_pdf.dart';

class ConfigImpresoraTab extends StatefulWidget {
  const ConfigImpresoraTab({super.key});

  @override
  State<ConfigImpresoraTab> createState() => _ConfigImpresoraTabState();
}

class _ConfigImpresoraTabState extends State<ConfigImpresoraTab> {
  final FirebasePrinterService _firebaseService = FirebasePrinterService();

  String selectedPaperSize = "58mm";
  int selectedCopies = 1;

  String printerName = "Ninguna seleccionada";
  String printerMac = "--:--:--:--:--:--";
  String printerType = "Bluetooth";

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadConfig();
  }

  Future<void> _loadConfig() async {
    final result = await _firebaseService.checkAndInitializeDevice();

    if (result != null) {
      setState(() {
        printerName = result["printer_name"] ?? printerName;
        printerMac = result["printer_mac"] ?? printerMac;
        printerType = result["printer_type"] ?? printerType;
        selectedPaperSize = result["paper_size"] ?? selectedPaperSize;
        selectedCopies = result["copies"] ?? selectedCopies;
      });
    }

    setState(() => isLoading = false);
  }

  void _openBuscarImpresora() async {
    final result = await showDialog<PrinterDevice>(
      context: context,
      builder: (_) => const BuscarImpresoraDialog(),
    );

    if (result != null) {
      setState(() {
        printerName = result.name;
        printerMac = result.address;
        printerType = result.type;
      });
    }
  }

  Future<void> _guardar() async {
    await _firebaseService.registerDevice(
      printerName: printerName,
      printerMac: printerMac,
      printerType: printerType,
      paperSize: selectedPaperSize,
      copies: selectedCopies,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Configuración guardada"),
        backgroundColor: Colors.green,
      ),
    );
  }

  Widget _card({required Widget child}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(18),
      ),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          /// 🔵 SELECCIONAR IMPRESORA
          _card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Seleccionar impresora",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 12),

                Row(
                  children: [
                    /// 🔍 BUSCAR IMPRESORA
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              Color.fromARGB(255, 132, 95, 221),
                              Color.fromARGB(255, 111, 114, 255),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: ElevatedButton.icon(
                          onPressed: _openBuscarImpresora,
                          icon: const Icon(Icons.print, color: Colors.black),
                          label: const Text(
                            "Buscar",
                            style: TextStyle(color: Colors.black),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 10),

                    /// 🧾 IMPRIMIR PRUEBA
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            try {
                              final printerService = PrinterService();
                              final bytes = await ImpresionPrueba.generar();

                              await printerService.sendBytes(
                                bytes: bytes,
                                type: printerType,
                                address: printerMac,
                              );

                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    "Impresión enviada correctamente",
                                  ),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            } catch (e) {
                              /// 🔥 FALLBACK A PDF
                              try {
                                final file =
                                    await ImpresionPruebaPDF.generarPDF();

                                await ImpresionPruebaPDF.mostrarPDF(file);

                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      "No se pudo imprimir, se generó PDF",
                                    ),
                                    backgroundColor: Colors.orange,
                                  ),
                                );
                              } catch (pdfError) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text("Error total: $pdfError"),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            }
                          },
                          icon: const Icon(
                            Icons.receipt_long,
                            color: Colors.white,
                          ),
                          label: const Text(
                            "Prueba",
                            style: TextStyle(color: Colors.white),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.print, color: Colors.white70),

                      const SizedBox(width: 12),

                      Expanded(
                        child: Text(
                          "$printerName\n$printerMac\n$printerType",
                          style: const TextStyle(color: Colors.white70),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          /// 🟣 CONFIGURACIÓN
          _card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Configuración de impresión",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 14),

                /// Tamaño papel
                DropdownButtonFormField<String>(
                  value: selectedPaperSize,
                  dropdownColor: const Color(0xFF111827),
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: "Tamaño de papel",
                    labelStyle: const TextStyle(color: Colors.white70),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.05),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  items: const [
                    DropdownMenuItem(value: "58mm", child: Text("58mm")),
                    DropdownMenuItem(value: "80mm", child: Text("80mm")),
                    DropdownMenuItem(value: "104mm", child: Text("104mm")),
                  ],
                  onChanged: (value) {
                    setState(() => selectedPaperSize = value!);
                  },
                ),

                const SizedBox(height: 16),

                /// Copias
                DropdownButtonFormField<int>(
                  value: selectedCopies,
                  dropdownColor: const Color(0xFF111827),
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: "Número de copias",
                    labelStyle: const TextStyle(color: Colors.white70),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.05),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  items: const [
                    DropdownMenuItem(value: 1, child: Text("1 copia")),
                    DropdownMenuItem(value: 2, child: Text("2 copias")),
                    DropdownMenuItem(value: 3, child: Text("3 copias")),
                    DropdownMenuItem(value: 4, child: Text("4 copias")),
                  ],
                  onChanged: (value) {
                    setState(() => selectedCopies = value!);
                  },
                ),
              ],
            ),
          ),

          const Spacer(),

          /// 🔥 BOTÓN GUARDAR
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color.fromARGB(255, 132, 95, 221),
                  Color.fromARGB(255, 111, 114, 255),
                ],
              ),
              borderRadius: BorderRadius.circular(18),
            ),
            child: ElevatedButton(
              onPressed: _guardar,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text(
                "GUARDAR CONFIGURACIÓN",
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
