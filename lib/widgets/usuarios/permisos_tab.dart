//lib/widgets/usuarios/permisos_tab.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PermisosTab extends StatefulWidget {
  const PermisosTab({super.key});

  @override
  State<PermisosTab> createState() => _PermisosTabState();
}

class _PermisosTabState extends State<PermisosTab> {
  String? usuarioSeleccionado;
  String tipoUsuario = "";

  List<QueryDocumentSnapshot> usuarios = [];

  Map<String, bool> permisos = {};

  final List<String> menuItems = [
    "Mesas",
    "Carta",
    "Inventario",
    "Compras",
    "Proveedores",
    "Clientes",
    "Recetas",
    "Registros",
    "Dashboard",
    "Notificaciones",
    "Bonos y Descuentos",
    "Asistencias",
    "Configuraciones",
    "Usuarios",
    "Marketing",
    "Dashboard Maestro",
  ];

  final List<String> fundadoraItems = [
    "Usuarios",
    "Marketing",
    "Dashboard Maestro",
  ];

  @override
  void initState() {
    super.initState();
    cargarUsuarios();
  }

  Future<void> cargarUsuarios() async {
    final snapshot = await FirebaseFirestore.instance
        .collection("usuarios")
        .where("estado", isEqualTo: true)
        .get();

    setState(() {
      usuarios = snapshot.docs;
    });
  }

  Future<void> cargarPermisos(String uid) async {
    final doc = await FirebaseFirestore.instance
        .collection("usuarios")
        .doc(uid)
        .get();

    final data = doc.data()!;

    setState(() {
      tipoUsuario = data["tipo_usuario"] ?? "";
      permisos = Map<String, bool>.from(data["permisos"] ?? {});
    });
  }

  Future<void> guardarPermiso(String key, bool value) async {
    if (usuarioSeleccionado == null) return;

    permisos[key] = value;

    await FirebaseFirestore.instance
        .collection("usuarios")
        .doc(usuarioSeleccionado)
        .update({"permisos": permisos});

    setState(() {});
  }

  bool bloqueado(String item) {
    if (tipoUsuario == "developer" || tipoUsuario == "admin") return true;

    if (fundadoraItems.contains(item)) return true;

    return false;
  }

  Widget permisoTile(String nombre) {
    final activo = permisos[nombre] ?? false;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.lock_outline, color: Colors.white70),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Text(
              nombre,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          Switch(
            value: tipoUsuario == "developer" || tipoUsuario == "admin"
                ? true
                : activo,
            activeColor: const Color.fromARGB(255, 111, 114, 255),
            onChanged: tipoUsuario == "developer" || tipoUsuario == "admin"
                ? (_) {}
                : bloqueado(nombre)
                ? null
                : (v) {
                    guardarPermiso(nombre, v);
                  },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color.fromARGB(255, 111, 114, 255)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              dropdownColor: const Color(0xFF111827),
              value: usuarioSeleccionado,
              isExpanded: true,
              hint: const Text(
                "Seleccionar usuario",
                style: TextStyle(color: Colors.white70),
              ),
              items: usuarios.map((u) {
                return DropdownMenuItem(
                  value: u.id,
                  child: Text(
                    u["nombres"],
                    style: const TextStyle(color: Colors.white),
                  ),
                );
              }).toList(),
              onChanged: (v) {
                setState(() {
                  usuarioSeleccionado = v;
                });
                cargarPermisos(v!);
              },
            ),
          ),
        ),

        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: menuItems.map((e) => permisoTile(e)).toList(),
          ),
        ),
      ],
    );
  }
}
