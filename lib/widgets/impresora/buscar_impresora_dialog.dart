//lib/widgets/impresora/buscar_impresora_dialog.dart
import 'package:flutter/material.dart';
import '../../services/impresora/printer_service.dart';

class BuscarImpresoraDialog extends StatefulWidget {
  const BuscarImpresoraDialog({super.key});

  @override
  State<BuscarImpresoraDialog> createState() => _BuscarImpresoraDialogState();
}

class _BuscarImpresoraDialogState extends State<BuscarImpresoraDialog> {
  final PrinterService _printerService = PrinterService();

  String? selectedType;
  Future<List<PrinterDevice>>? futureDevices;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Buscar impresora"),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            /// Tipo conexión
            DropdownButtonFormField<String>(
              value: selectedType,
              hint: const Text("Tipo de conexión"),
              items: const [
                DropdownMenuItem(value: "Bluetooth", child: Text("Bluetooth")),
                DropdownMenuItem(value: "USB", child: Text("USB")),
                DropdownMenuItem(value: "WiFi", child: Text("WiFi")),
              ],
              onChanged: (value) {
                setState(() {
                  selectedType = value;

                  if (value == "Bluetooth") {
                    futureDevices = _printerService.scanBluetoothPrinters();
                  } else if (value == "USB") {
                    futureDevices = _printerService.scanUsbPrinters();
                  } else if (value == "WiFi") {
                    futureDevices = _printerService.scanWifiPrinter();
                  }
                });
              },
            ),

            const SizedBox(height: 20),

            if (futureDevices != null)
              FutureBuilder<List<PrinterDevice>>(
                future: futureDevices,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Padding(
                      padding: EdgeInsets.all(20),
                      child: CircularProgressIndicator(),
                    );
                  }

                  if (snapshot.hasError) {
                    return const Text(
                      "Error al buscar",
                      style: TextStyle(color: Colors.red),
                    );
                  }

                  final devices = snapshot.data ?? [];

                  if (devices.isEmpty) {
                    return const Text("No se encontraron dispositivos");
                  }

                  return SizedBox(
                    height: 200,
                    child: ListView.builder(
                      itemCount: devices.length,
                      itemBuilder: (_, index) {
                        final d = devices[index];

                        return ListTile(
                          leading: const Icon(Icons.print),
                          title: Text(d.name),
                          subtitle: Text(d.address),
                          onTap: () {
                            Navigator.pop(context, d);
                          },
                        );
                      },
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
