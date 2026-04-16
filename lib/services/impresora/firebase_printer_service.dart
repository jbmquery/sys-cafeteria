//lib/services/impresora/firebase_printer_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'dart:io';

class FirebasePrinterService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// 🔑 Obtener UID del usuario logueado
  String getUserId() {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception("Usuario no autenticado");
    }
    return user.uid;
  }

  /// 📱 Obtener ID único del dispositivo
  Future<String> getDeviceId() async {
    final deviceInfo = DeviceInfoPlugin();

    if (Platform.isAndroid) {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      return androidInfo.id; // 🔥 Android ID real
    }

    return "unknown_device";
  }

  /// 📦 Datos del dispositivo + app
  Future<Map<String, dynamic>> getDeviceData() async {
    final deviceInfo = DeviceInfoPlugin();
    final packageInfo = await PackageInfo.fromPlatform();

    String deviceName = "Unknown";

    if (Platform.isAndroid) {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      deviceName = "${androidInfo.brand} ${androidInfo.model}";
    }

    return {"device_name": deviceName, "version_app": packageInfo.version};
  }

  /// 🔥 GUARDAR CONFIGURACIÓN
  Future<void> registerDevice({
    required String printerName,
    required String printerMac,
    required String printerType,
    required String paperSize,
    required int copies,
  }) async {
    final uid = getUserId();
    final deviceData = await getDeviceData();
    final deviceId = await getDeviceId();

    final docRef = _firestore.collection("impresoras").doc(uid);

    await docRef.set({
      "user_id": uid,
      "device_id": deviceId, // 🔥 AQUÍ LO AGREGAMOS
      "device_name": deviceData["device_name"],
      "version_app": deviceData["version_app"],
      "ultimo_acceso": DateTime.now(),

      // 🖨️ CONFIG
      "printer_name": printerName,
      "printer_mac": printerMac,
      "printer_type": printerType,
      "paper_size": paperSize,
      "copies": copies,
    }, SetOptions(merge: true));
  }

  /// 🔄 OBTENER CONFIG
  Future<Map<String, dynamic>?> checkAndInitializeDevice() async {
    final uid = getUserId();
    final deviceData = await getDeviceData();
    final deviceId = await getDeviceId();

    final docRef = _firestore.collection("impresoras").doc(uid);
    final doc = await docRef.get();

    if (!doc.exists) {
      await docRef.set({
        "user_id": uid,
        "device_id": deviceId, // 🔥 TAMBIÉN AQUÍ
        "device_name": deviceData["device_name"],
        "version_app": deviceData["version_app"],
        "ultimo_acceso": DateTime.now(),

        // 🖨️ CONFIG DEFAULT
        "printer_name": null,
        "printer_mac": null,
        "printer_type": null,
        "paper_size": "58mm",
        "copies": 1,
      });

      return {
        "printer_name": null,
        "printer_mac": null,
        "printer_type": null,
        "paper_size": "58mm",
        "copies": 1,
      };
    }

    final data = doc.data()!;

    await docRef.update({
      "ultimo_acceso": DateTime.now(),
      "device_id": deviceId, // 🔄 se actualiza si cambia dispositivo
    });

    return data;
  }
}
