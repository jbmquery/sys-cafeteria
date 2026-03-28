import 'dart:io';
import 'package:flutter/material.dart';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';

class CartaUploadPlantilla {
  static Future<void> descargarPlantilla(BuildContext context) async {
    try {
      final excel = Excel.createExcel();
      final sheet = excel['Plantilla'];

      /// CABECERAS EXACTAS
      sheet.appendRow([
        'nombre_cat',
        'nombre_subcat',
        'nombre',
        'grupo',
        'abreviado',
        'precio',
        'puntos',
        'porcion',
        'unidad',
        'observacion',
        'uid_usuario',
      ]);

      /// FILA EJEMPLO
      sheet.appendRow([
        'Bebidas',
        'Gaseosas',
        'Coca Cola 500ml',
        'Bebida fría',
        'Coca',
        8,
        2,
        '500',
        'ml',
        '',
        'UID123456',
      ]);

      final dir = await getApplicationDocumentsDirectory();
      final filePath = '${dir.path}/carta_upload_plantilla.xlsx';

      final file = File(filePath);

      final bytes = excel.encode();

      if (bytes == null) {
        throw Exception("No se pudo generar plantilla");
      }

      await file.writeAsBytes(bytes, flush: true);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Plantilla guardada en:\n$filePath")),
      );

      await OpenFile.open(filePath);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error al generar plantilla: $e")));
    }
  }
}
