//lib/widgets/impresora/impresion_prueba.dart
import 'dart:typed_data';

class ImpresionPrueba {
  static Future<List<int>> generar() async {
    List<int> bytes = [];

    // Reset
    bytes += [27, 64];

    // Centrado
    bytes += [27, 97, 1];

    // Texto grande
    bytes += [29, 33, 16];
    bytes += _text("CAFETERIA APP\n");

    // Normal
    bytes += [29, 33, 0];
    bytes += _text("--------------------------\n");

    bytes += _text("IMPRESION DE PRUEBA\n");
    bytes += _text("--------------------------\n");

    // Alinear izquierda
    bytes += [27, 97, 0];

    bytes += _text("Producto        Precio\n");
    bytes += _text("--------------------------\n");
    bytes += _text("Café Americano  S/ 5.00\n");
    bytes += _text("Capuccino       S/ 7.00\n");
    bytes += _text("Torta Chocolate S/ 6.00\n");

    bytes += _text("--------------------------\n");

    // Centrado
    bytes += [27, 97, 1];

    bytes += _text("TOTAL: S/ 18.00\n\n");

    bytes += _text("Gracias por su compra ☕\n");
    bytes += _text("www.tuapp.com\n\n\n");

    // Corte de papel
    bytes += [29, 86, 1];

    return bytes;
  }

  static List<int> _text(String text) {
    return Uint8List.fromList(text.codeUnits);
  }
}
