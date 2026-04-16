//lib/widgets/impresora/config_impresora_tab.dart
import 'package:flutter/material.dart';
import '../../services/impresora/firebase_printer_service.dart';
import '../../services/impresora/printer_service.dart';
import 'buscar_impresora_dialog.dart';

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

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// 1️⃣ Seleccionar impresora
          const Text(
            "1. Seleccionar impresora",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),

          ElevatedButton(
            onPressed: _openBuscarImpresora,
            child: const Text("Seleccionar impresora"),
          ),

          const SizedBox(height: 10),

          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Text(
              "$printerName\nMAC/IP: $printerMac\nTipo: $printerType",
              style: const TextStyle(color: Colors.white70),
            ),
          ),

          const SizedBox(height: 25),

          /// 2️⃣ Tamaño papel
          const Text(
            "2. Tamaño de impresión",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),

          DropdownButtonFormField<String>(
            value: selectedPaperSize,
            dropdownColor: const Color(0xFF111827),
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
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

          const SizedBox(height: 25),

          /// 3️⃣ Copias
          const Text(
            "3. Número de copias",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),

          DropdownButtonFormField<int>(
            value: selectedCopies,
            dropdownColor: const Color(0xFF111827),
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
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

          const Spacer(),

          /// 🔥 GUARDAR
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _guardar,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueGrey,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text("GUARDAR"),
            ),
          ),
        ],
      ),
    );
  }
}
