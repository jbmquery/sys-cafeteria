import 'dart:typed_data';

class ImpresionCocina {
  static Future<List<int>> generar({
    required String mesa,
    required int numPedido,
    required String hora,
    required List<Map<String, dynamic>> items,
  }) async {
    List<int> bytes = [];

    // Reset
    bytes += [27, 64];

    // 🔥 HEADER CENTRADO (estilo limpio como tu UI)
    bytes += [27, 97, 1];

    bytes += _bold(true);
    bytes += _text("PEDIDO COCINA\n");
    bytes += _bold(false);

    bytes += _text("------------------------\n");

    bytes += _text("Mesa: $mesa\n");
    bytes += _text("Pedido: #$numPedido\n");
    bytes += _text("Hora: $hora\n");

    bytes += _text("------------------------\n\n");

    // 🔻 CONTENIDO
    bytes += [27, 97, 0]; // izquierda

    for (var item in items) {
      final nombre = item["nombre"] ?? "";
      final cantidad = item["cantidad"] ?? 1;
      final observacion = item["observacion"] ?? "";

      // 🔥 estilo compacto tipo cocina
      bytes += _bold(true);
      bytes += _text("x$cantidad $nombre\n");
      bytes += _bold(false);

      if (observacion.toString().isNotEmpty) {
        bytes += _text("  * $observacion\n");
      }

      bytes += _text("\n");
    }

    bytes += _text("------------------------\n");

    bytes += [27, 97, 1];

    bytes += _text("ENVIAR A COCINA\n\n\n");

    // Corte
    bytes += [29, 86, 1];

    return bytes;
  }

  static List<int> _text(String text) {
    return Uint8List.fromList(text.codeUnits);
  }

  static List<int> _bold(bool enable) {
    return [27, 69, enable ? 1 : 0];
  }
}
