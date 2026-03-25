//lib/widgets/app_sidebar.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../pages/usuarios_page.dart';

class AppSidebar extends StatelessWidget {
  const AppSidebar({super.key});

  Future<Map<String, dynamic>> obtenerDatosUsuario() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    final doc = await FirebaseFirestore.instance
        .collection("usuarios")
        .doc(uid)
        .get();

    return doc.data() ?? {};
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: obtenerDatosUsuario(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Drawer(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF0B0F1A),
                    Color(0xFF111827),
                    Color(0xFF1E293B),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ),
          );
        }

        final data = snapshot.data!;
        final tipoUsuario = data["tipo_usuario"] ?? "";
        final permisos = Map<String, bool>.from(data["permisos"] ?? {});

        bool visible(String item) {
          if (tipoUsuario == "developer" || tipoUsuario == "admin") return true;
          return permisos[item] ?? false;
        }

        final operacionVisible =
            visible("Mesas") ||
            visible("Carta") ||
            visible("Inventario") ||
            visible("Compras") ||
            visible("Proveedores") ||
            visible("Clientes");

        final administracionVisible =
            visible("Recetas") ||
            visible("Registros") ||
            visible("Dashboard") ||
            visible("Notificaciones") ||
            visible("Bonos y Descuentos") ||
            visible("Asistencias") ||
            visible("Configuraciones");

        final fundadoraVisible =
            visible("Usuarios") ||
            visible("Marketing") ||
            visible("Dashboard Maestro");

        return Drawer(
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF0B0F1A),
                  Color(0xFF111827),
                  Color(0xFF1E293B),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                Container(
                  padding: const EdgeInsets.fromLTRB(20, 60, 20, 30),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.08),
                        ),
                        child: const Icon(
                          Icons.coffee_rounded,
                          color: Colors.white,
                          size: 36,
                        ),
                      ),

                      const SizedBox(height: 18),

                      const Text(
                        "Pluvia Café",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 6),

                      Text(
                        "Panel Administrativo",
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.55),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),

                if (operacionVisible) sectionTitle("Operación"),

                if (visible("Mesas")) menuItem(Icons.table_restaurant, "Mesas"),
                if (visible("Carta")) menuItem(Icons.menu_book, "Carta"),
                if (visible("Inventario"))
                  menuItem(Icons.inventory_2_outlined, "Inventario"),
                if (visible("Compras"))
                  menuItem(Icons.shopping_bag_outlined, "Compras"),
                if (visible("Proveedores"))
                  menuItem(Icons.local_shipping_outlined, "Proveedores"),
                if (visible("Clientes"))
                  menuItem(Icons.people_outline, "Clientes"),

                if (administracionVisible) const SizedBox(height: 14),
                if (administracionVisible) sectionTitle("Administración"),

                if (visible("Recetas"))
                  menuItem(Icons.restaurant_menu, "Recetas"),
                if (visible("Registros"))
                  menuItem(Icons.receipt_long, "Registros"),
                if (visible("Dashboard"))
                  menuItem(Icons.bar_chart_outlined, "Dashboard"),
                if (visible("Notificaciones"))
                  menuItem(Icons.notifications_none, "Notificaciones"),
                if (visible("Bonos y Descuentos"))
                  menuItem(Icons.attach_money_outlined, "Bonos y Descuentos"),
                if (visible("Asistencias"))
                  menuItem(Icons.assignment_turned_in_outlined, "Asistencias"),
                if (visible("Configuraciones"))
                  menuItem(
                    Icons.settings_applications_outlined,
                    "Configuraciones",
                  ),

                if (fundadoraVisible) const SizedBox(height: 14),
                if (fundadoraVisible) sectionTitle("fundadora"),

                if (visible("Usuarios"))
                  menuItem(
                    Icons.person_outline,
                    "Usuarios",
                    onTap: () {
                      Navigator.push(
                        context,
                        PageRouteBuilder(
                          pageBuilder: (_, __, ___) => const UsuariosPage(),
                          transitionsBuilder: (_, animation, __, child) {
                            return SlideTransition(
                              position: Tween(
                                begin: const Offset(1, 0),
                                end: Offset.zero,
                              ).animate(animation),
                              child: child,
                            );
                          },
                          transitionDuration: const Duration(milliseconds: 280),
                        ),
                      );
                    },
                  ),

                if (visible("Marketing"))
                  menuItem(Icons.analytics_outlined, "Marketing"),

                if (visible("Dashboard Maestro"))
                  menuItem(Icons.bar_chart_outlined, "Dashboard Maestro"),
              ],
            ),
          ),
        );
      },
    );
  }

  static Widget sectionTitle(String texto) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
      child: Text(
        texto,
        style: TextStyle(
          color: Colors.white.withOpacity(0.45),
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  static Widget menuItem(IconData icon, String titulo, {VoidCallback? onTap}) {
    return ListTile(
      leading: Icon(icon, color: Colors.white70),
      title: Text(
        titulo,
        style: const TextStyle(color: Colors.white, fontSize: 16),
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      onTap: onTap,
    );
  }
}
