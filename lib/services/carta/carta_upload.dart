import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:excel/excel.dart';

class CartaUpload {
  static Future<void> subirExcel(BuildContext context) async {
    try {
      /// SELECCIONAR ARCHIVO
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx'],
      );

      if (result == null) return;

      final file = File(result.files.single.path!);
      final bytes = file.readAsBytesSync();

      final excel = Excel.decodeBytes(bytes);
      final sheet = excel.tables.values.first;

      if (sheet == null) {
        throw Exception("No se encontró hoja en el archivo");
      }

      final firestore = FirebaseFirestore.instance;
      final batch = firestore.batch();

      /// FILA 2 EN ADELANTE
      for (int i = 1; i < sheet.rows.length; i++) {
        final row = sheet.rows[i];

        String texto(dynamic value) {
          if (value == null) return '';
          return value.value.toString().trim();
        }

        int numero(dynamic value) {
          if (value == null) return 0;

          final raw = value.value;

          if (raw == null) return 0;

          /// SI YA ES NUMERO REAL
          if (raw is int) return raw;

          /// SI ES DOUBLE
          if (raw is double) return raw.toInt();

          /// SI VIENE COMO STRING
          final limpio = raw.toString().replaceAll(',', '.');

          return double.tryParse(limpio)?.toInt() ?? 0;
        }

        final nombreCat = texto(row[0]);
        final nombreSubcat = texto(row[1]);
        final nombre = texto(row[2]);
        final grupo = texto(row[3]);
        final abreviado = texto(row[4]);
        final precio = row.length > 5 ? numero(row[5]) : 0;
        final puntos = row.length > 6 ? numero(row[6]) : 0;

        final porcionTexto = texto(row[7]);
        final unidadTexto = texto(row[8]);
        final observacionTexto = texto(row[9]);
        final uidUsuario = texto(row[10]);

        /// SI NOMBRE VACÍO -> SALTAR FILA
        if (nombre.isEmpty) continue;

        /// BUSCAR SI EXISTE POR NOMBRE
        final query = await firestore
            .collection('carta')
            .where('nombre', isEqualTo: nombre)
            .limit(1)
            .get();

        final data = {
          'nombre_cat': nombreCat,
          'nombre_subcat': nombreSubcat,
          'nombre': nombre,
          'grupo': grupo,
          'abreviado': abreviado,
          'precio': precio,
          'puntos': puntos,

          /// NULL SI VACÍO
          'porcion': porcionTexto.isEmpty ? null : porcionTexto,
          'unidad': unidadTexto.isEmpty ? null : unidadTexto,

          /// STRING VACÍO SI VACÍO
          'observacion': observacionTexto.isEmpty ? '' : observacionTexto,

          /// CAMPOS FIJOS
          'estado': true,
          'disponibilidad': true,
          'uid_usuario': uidUsuario,
        };

        /// EXISTE -> UPDATE
        if (query.docs.isNotEmpty) {
          final docRef = query.docs.first.reference;

          batch.update(docRef, data);
        }
        /// NO EXISTE -> CREATE
        else {
          final docRef = firestore.collection('carta').doc();

          batch.set(docRef, {...data, 'fecha_creacion': Timestamp.now()});
        }
      }

      /// EJECUTAR TODO
      await batch.commit();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Carga completada correctamente")),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error al subir archivo: $e")));
    }
  }
}
