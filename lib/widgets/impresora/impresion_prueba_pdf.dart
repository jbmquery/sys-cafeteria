//lib/widgets/impresora/impresion_prueba_pdf.dart
import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:printing/printing.dart';

class ImpresionPruebaPDF {
  static Future<File> generarPDF() async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.roll80, // 👈 simula ticket
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              pw.Text(
                "PLUVIA CAFE",
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),

              pw.SizedBox(height: 10),
              pw.Divider(),

              pw.Text("IMPRESIÓN DE PRUEBA"),

              pw.Divider(),
              pw.SizedBox(height: 10),

              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [pw.Text("Producto"), pw.Text("Precio")],
              ),

              pw.Divider(),

              _item("Café Americano", "S/ 5.00"),
              _item("Capuccino", "S/ 7.00"),
              _item("Torta Chocolate", "S/ 6.00"),

              pw.Divider(),

              pw.SizedBox(height: 10),

              pw.Text(
                "TOTAL: S/ 18.00",
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),

              pw.SizedBox(height: 20),

              pw.Text("Gracias por su compra, visitanos."),
              pw.Text("www.pluviacafe.com"),
            ],
          );
        },
      ),
    );

    final dir = await getTemporaryDirectory();
    final file = File("${dir.path}/test_print.pdf");

    await file.writeAsBytes(await pdf.save());

    return file;
  }

  static pw.Widget _item(String name, String price) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [pw.Text(name), pw.Text(price)],
    );
  }

  /// 👇 Mostrar preview o imprimir PDF
  static Future<void> mostrarPDF(File file) async {
    await Printing.layoutPdf(onLayout: (format) async => file.readAsBytes());
  }
}
