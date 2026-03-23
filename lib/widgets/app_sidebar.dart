import 'package:flutter/material.dart';

class AppSidebar extends StatelessWidget {
  const AppSidebar({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0B0F1A), Color(0xFF111827), Color(0xFF1E293B)],
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

            sectionTitle("Operación"),

            menuItem(Icons.table_restaurant, "Mesas"),
            menuItem(Icons.menu_book, "Carta"),
            menuItem(Icons.inventory_2_outlined, "Inventario"),
            menuItem(Icons.shopping_bag_outlined, "Compras"),
            menuItem(Icons.local_shipping_outlined, "Proveedores"),
            menuItem(Icons.people_outline, "Clientes"),

            const SizedBox(height: 14),

            sectionTitle("Administración"),

            menuItem(Icons.restaurant_menu, "Recetas"),
            menuItem(Icons.receipt_long, "Registros"),
            menuItem(Icons.bar_chart_outlined, "Dashboard"),
            menuItem(Icons.notifications_none, "Notificaciones"),
            menuItem(Icons.attach_money_outlined, "Bonos y Descuentos"),
            menuItem(Icons.assignment_turned_in_outlined, "Asistencias"),
            menuItem(Icons.settings_applications_outlined, "Configuraciones"),

            const SizedBox(height: 14),

            sectionTitle("Dueña"),

            menuItem(Icons.person_outline, "Usuarios"),
            menuItem(Icons.analytics_outlined, "Marketing"),
            menuItem(Icons.bar_chart_outlined, "Dashboard Maestro"),
          ],
        ),
      ),
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

  Widget menuItem(IconData icon, String titulo) {
    return ListTile(
      leading: Icon(icon, color: Colors.white70),

      title: Text(
        titulo,
        style: const TextStyle(color: Colors.white, fontSize: 16),
      ),

      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),

      onTap: () {},
    );
  }
}
