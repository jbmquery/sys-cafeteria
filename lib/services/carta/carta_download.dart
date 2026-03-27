//lib/services/carta/carta_download.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';

class CartaDownload {
  static Future<void> descargarExcel(BuildContext context) async {
    try {
      final excel = Excel.createExcel();
      final sheet = excel['Carta'];

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
        'estado',
        'disponibilidad',
        'uid_usuario',
        'fecha_creacion',
      ]);

      /// FIRESTORE
      final snapshot = await FirebaseFirestore.instance
          .collection('carta')
          .get();

      for (var doc in snapshot.docs) {
        final data = doc.data();

        sheet.appendRow([
          data['nombre_cat'] ?? '',
          data['nombre_subcat'] ?? '',
          data['nombre'] ?? '',
          data['grupo'] ?? '',
          data['abreviado'] ?? '',
          data['precio'] ?? 0,
          data['puntos'] ?? 0,
          data['porcion'] ?? '',
          data['unidad'] ?? '',
          data['observacion'] ?? '',
          data['estado'] ?? true,
          data['disponibilidad'] ?? true,
          data['uid_usuario'] ?? '',
          data['fecha_creacion'] != null
              ? (data['fecha_creacion'] as Timestamp).toDate().toString()
              : '',
        ]);
      }

      /// GUARDAR
      final dir = await getApplicationDocumentsDirectory();
      final filePath = '${dir.path}/carta.xlsx';

      final file = File(filePath);

      final bytes = excel.encode();

      if (bytes == null) {
        throw Exception("No se pudo generar el archivo");
      }

      await file.writeAsBytes(bytes, flush: true);

      /// MENSAJE VISUAL
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Archivo guardado en:\n$filePath")),
      );

      /// ABRIR
      await OpenFile.open(filePath);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error al descargar: $e")));
    }
  }
}
