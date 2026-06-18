//lib/services/caja/montos_resumen.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class MontosResumenService {
  static Future<Map<String, dynamic>?> obtenerResumenCaja() async {
    final firestore = FirebaseFirestore.instance;

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
      return null;
    }

    final cajaDoc = cajaQuery.docs.first;

    final cajaData = cajaDoc.data();

    final cajaRef = cajaDoc.reference;

    /// ============================
    /// RESUMEN
    /// ============================

    final resumenSnapshot = await cajaRef.collection('resumen').limit(1).get();

    double montoApertura = 0;

    double contadoReal = 0;

    if (resumenSnapshot.docs.isNotEmpty) {
      final resumen = resumenSnapshot.docs.first.data();

      montoApertura = (resumen['monto_apertura'] as num?)?.toDouble() ?? 0;

      contadoReal = (resumen['monto_cierre'] as num?)?.toDouble() ?? 0;
    }

    final mostrarMontos = contadoReal > 0;

    /// ============================
    /// MOVIMIENTOS
    /// ============================

    final movimientosSnapshot = await cajaRef.collection('movimientos').get();

    final movimientos = movimientosSnapshot.docs.map((e) => e.data()).toList();

    double ingresos = 0;
    double egresos = 0;
    double vueltos = 0;

    final Map<String, double> pagosPorMetodo = {};

    final Map<String, double> vueltosPorMetodo = {};

    Timestamp? primeraVenta;
    Timestamp? ultimaVenta;

    int ventasRealizadas = 0;

    for (final mov in movimientos) {
      final tipo = mov['tipo'] ?? '';

      final categoria = mov['categoria'] ?? '';

      final metodo = mov['metodo_monetario'] ?? 'Sin método';

      final monto = (mov['monto'] as num?)?.toDouble() ?? 0;

      final fechaPago = mov['fecha_pago'] as Timestamp?;

      if (tipo == 'ingreso') {
        ingresos += monto;
      }

      if (tipo == 'egreso') {
        egresos += monto;
      }

      /// ========================
      /// VENTAS
      /// ========================

      if (tipo == 'ingreso' && categoria == 'venta') {
        ventasRealizadas++;

        pagosPorMetodo[metodo] = (pagosPorMetodo[metodo] ?? 0) + monto;

        if (fechaPago != null) {
          if (primeraVenta == null ||
              fechaPago.toDate().isBefore(primeraVenta.toDate())) {
            primeraVenta = fechaPago;
          }

          if (ultimaVenta == null ||
              fechaPago.toDate().isAfter(ultimaVenta.toDate())) {
            ultimaVenta = fechaPago;
          }
        }
      }

      /// ========================
      /// VUELTOS
      /// ========================

      if (tipo == 'vuelto' && categoria == 'vuelto') {
        vueltos += monto;

        vueltosPorMetodo[metodo] = (vueltosPorMetodo[metodo] ?? 0) + monto;
      }
    }

    /// ============================
    /// PORCENTAJES
    /// ============================

    final Map<String, double> porcentajePagos = {};

    pagosPorMetodo.forEach((key, value) {
      porcentajePagos[key] = ingresos == 0 ? 0 : (value / ingresos) * 100;
    });

    final Map<String, double> porcentajeVueltos = {};

    vueltosPorMetodo.forEach((key, value) {
      porcentajeVueltos[key] = vueltos == 0 ? 0 : (value / vueltos) * 100;
    });

    /// ============================
    /// TIEMPO CAJA
    /// ============================

    final Timestamp? fechaApertura = cajaData['hora_apertura'];

    final Timestamp? horaCierre = cajaData['hora_cierre'];

    Duration tiempoCaja = Duration.zero;

    if (fechaApertura != null) {
      tiempoCaja = (horaCierre?.toDate() ?? DateTime.now()).difference(
        fechaApertura.toDate(),
      );
    }

    /// ============================
    /// DIFERENCIA
    /// ============================

    final diferencia = contadoReal - montoApertura;

    /// ============================
    /// PROMEDIOS
    /// ============================

    final ticketPromedio = ventasRealizadas == 0
        ? 0
        : ingresos / ventasRealizadas;

    return {
      'montoApertura': montoApertura,
      'contadoReal': contadoReal,
      'mostrarMontos': mostrarMontos,

      'ingresos': ingresos,
      'egresos': egresos,
      'vueltos': vueltos,

      'diferencia': diferencia,

      'ventasRealizadas': ventasRealizadas,

      'ticketPromedio': ticketPromedio,

      'pagosPorMetodo': pagosPorMetodo,
      'porcentajePagos': porcentajePagos,

      'vueltosPorMetodo': vueltosPorMetodo,
      'porcentajeVueltos': porcentajeVueltos,

      'primeraVenta': primeraVenta,
      'ultimaVenta': ultimaVenta,

      'tiempoCaja': tiempoCaja,
    };
  }
}
