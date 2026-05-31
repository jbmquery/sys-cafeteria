import 'package:cloud_firestore/cloud_firestore.dart';

class AgregarPagoMovimiento {
  static Future<void> registrar({
    required String pedidoId,
    required Map<String, dynamic> pedidoData,
    required Map<String, dynamic> pagoData,
  }) async {
    print("ENTRO A registrar movimiento");
    final firestore = FirebaseFirestore.instance;

    try {
      /// ==========================
      /// BUSCAR CAJA ACTIVA DEL DIA
      /// ==========================

      final ahora = DateTime.now();

      final inicioDia = DateTime(ahora.year, ahora.month, ahora.day);

      final finDia = DateTime(ahora.year, ahora.month, ahora.day, 23, 59, 59);

      final cajaQuery = await firestore
          .collection('caja')
          .where('estado', isEqualTo: true)
          .where('fecha', isGreaterThanOrEqualTo: Timestamp.fromDate(inicioDia))
          .where('fecha', isLessThanOrEqualTo: Timestamp.fromDate(finDia))
          .limit(1)
          .get();

      if (cajaQuery.docs.isEmpty) {
        print("NO SE ENCONTRO CAJA ACTIVA");
        return;
      }

      final cajaRef = cajaQuery.docs.first.reference;

      /// ==========================
      /// DATOS PEDIDO
      /// ==========================

      final uidPedido = pedidoData['uid_usuario'] ?? '';

      String apodoPedido = '';

      if (uidPedido.isNotEmpty) {
        final usuarioPedido = await firestore
            .collection('usuarios')
            .doc(uidPedido)
            .get();

        apodoPedido = usuarioPedido.data()?['apodo']?.toString() ?? '';
      }

      /// ==========================
      /// DATOS PAGO
      /// ==========================

      final uidPago = pagoData['uid_usuario'] ?? '';

      String apodoPago = '';

      if (uidPago.isNotEmpty) {
        final usuarioPago = await firestore
            .collection('usuarios')
            .doc(uidPago)
            .get();

        apodoPago = usuarioPago.data()?['apodo']?.toString() ?? '';
      }

      final descripcion =
          '''
pedido #: ${pagoData['num_pedido'] ?? ''}
mesa: ${pedidoData['nombre_mesa'] ?? ''}
cuenta #: ${pagoData['cuenta'] ?? ''}
''';

      /// ==========================
      /// MOVIMIENTO INGRESO
      /// ==========================

      await cajaRef.collection('movimientos').add({
        'fecha_pedido': pedidoData['fecha'],
        'fecha_pago': pagoData['hora_pago'],

        'tipo': 'ingreso',
        'categoria': 'venta',

        'descripcion': descripcion,

        'metodo_monetario': pagoData['modo_pago'],

        'monto': pagoData['monto_pagado'],

        'uid_usuario_pedido': uidPedido,
        'apodo_pedido': apodoPedido,

        'uid_usuario_pago': uidPago,
        'apodo_pago': apodoPago,

        'id_pedido': pedidoId,
      });

      /// ==========================
      /// MOVIMIENTO VUELTO
      /// ==========================

      final vuelto = (pagoData['monto_vuelto'] as num?)?.toDouble() ?? 0;

      if (vuelto > 0) {
        await cajaRef.collection('movimientos').add({
          'fecha_pedido': pedidoData['fecha'],
          'fecha_pago': pagoData['hora_pago'],

          'tipo': 'egreso',
          'categoria': 'vuelto',

          'descripcion': descripcion,

          'metodo_monetario': pagoData['modo_vuelto'],

          'monto': vuelto,

          'uid_usuario_pedido': uidPedido,
          'apodo_pedido': apodoPedido,

          'uid_usuario_pago': uidPago,
          'apodo_pago': apodoPago,

          'id_pedido': pedidoId,
        });
      }
    } catch (e) {
      print("Error registrando movimiento de caja: $e");
    }
  }
}
