//lib/widgets/usuarios/editar_usuarios_dialog.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../custom_textfield.dart';

class EditarUsuarioDialog extends StatefulWidget {
  final DocumentSnapshot usuario;

  const EditarUsuarioDialog({super.key, required this.usuario});

  @override
  State<EditarUsuarioDialog> createState() => _EditarUsuarioDialogState();
}

class _EditarUsuarioDialogState extends State<EditarUsuarioDialog> {
  final nombresController = TextEditingController();
  final apePaternoController = TextEditingController();
  final apeMaternoController = TextEditingController();
  final correoController = TextEditingController();
  final numDocumentoController = TextEditingController();
  final celularController = TextEditingController();

  String tipoDocumento = "DNI";
  String tipoUsuario = "encargado";

  bool estado = true;

  DateTime? fechaNacimiento;
  DateTime? fechaContratacion;
  DateTime? fechaCreacion;

  bool cargando = false;

  bool get protegido {
    final rol = widget.usuario['tipo_usuario'];
    return rol == "developer" || rol == "admin";
  }

  @override
  void initState() {
    super.initState();

    final data = widget.usuario.data() as Map<String, dynamic>;

    nombresController.text = data['nombres'] ?? '';
    apePaternoController.text = data['ape_paterno'] ?? '';
    apeMaternoController.text = data['ape_materno'] ?? '';
    correoController.text = data['correo'] ?? '';
    numDocumentoController.text = data['num_documento'] ?? '';
    celularController.text = data['celular'] ?? '';

    tipoDocumento = data['tipo_documento'] ?? 'DNI';
    tipoUsuario = data['tipo_usuario'] ?? 'encargado';
    estado = data['estado'] ?? true;

    fechaNacimiento = (data['fecha_nacimiento'] as Timestamp?)?.toDate();
    fechaContratacion = (data['fecha_contratacion'] as Timestamp?)?.toDate();
    fechaCreacion = (data['fecha_creacion'] as Timestamp?)?.toDate();
  }

  Future<void> seleccionarFecha(
    BuildContext context,
    Function(DateTime) onSelect,
  ) async {
    final fecha = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1980),
      lastDate: DateTime(2100),
    );

    if (fecha != null) {
      onSelect(fecha);
    }
  }

  Future<void> actualizarUsuario() async {
    setState(() {
      cargando = true;
    });

    await FirebaseFirestore.instance
        .collection('usuarios')
        .doc(widget.usuario.id)
        .update({
          'nombres': nombresController.text.trim(),
          'ape_paterno': apePaternoController.text.trim(),
          'ape_materno': apeMaternoController.text.trim(),
          'tipo_documento': tipoDocumento,
          'num_documento': numDocumentoController.text.trim(),
          'tipo_usuario': tipoUsuario,
          'estado': estado,
          'celular': celularController.text.trim(),
          'fecha_nacimiento': fechaNacimiento,
          'fecha_contratacion': fechaContratacion,
        });

    setState(() {
      cargando = false;
    });

    Navigator.pop(context);
  }

  Future<void> eliminarUsuario() async {
    await FirebaseFirestore.instance
        .collection('usuarios')
        .doc(widget.usuario.id)
        .delete();

    Navigator.pop(context);
  }

  Widget fechaTile(
    String titulo,
    DateTime? fecha,
    VoidCallback onTap,
    bool enabled,
  ) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(titulo, style: const TextStyle(color: Colors.white70)),
      subtitle: Text(
        fecha != null
            ? "${fecha.day}/${fecha.month}/${fecha.year}"
            : "Seleccionar",
        style: const TextStyle(color: Colors.white),
      ),
      trailing: enabled
          ? const Icon(Icons.calendar_month, color: Colors.white54)
          : null,
      onTap: enabled ? onTap : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.80,
        ),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFF111827),
          borderRadius: BorderRadius.circular(28),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Editar Usuario",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                "Actualización de información",
                style: TextStyle(color: Colors.white54, fontSize: 13),
              ),

              const SizedBox(height: 24),

              CustomTextField(
                controller: nombresController,
                hint: "Nombres",
                icon: Icons.person_outline,
                enabled: !protegido,
                borderColor: const Color.fromARGB(255, 111, 114, 255),
              ),

              const SizedBox(height: 12),

              CustomTextField(
                controller: apePaternoController,
                hint: "Apellido paterno",
                icon: Icons.person_outline,
                enabled: !protegido,
                borderColor: const Color.fromARGB(255, 111, 114, 255),
              ),

              const SizedBox(height: 12),

              CustomTextField(
                controller: apeMaternoController,
                hint: "Apellido materno",
                icon: Icons.person_outline,
                enabled: !protegido,
                borderColor: const Color.fromARGB(255, 111, 114, 255),
              ),

              const SizedBox(height: 12),

              CustomTextField(
                controller: correoController,
                hint: "Correo",
                icon: Icons.mail_outline,
                enabled: false,
                borderColor: const Color.fromARGB(255, 111, 114, 255),
              ),

              const SizedBox(height: 12),

              CustomTextField(
                controller: numDocumentoController,
                hint: "Número documento",
                icon: Icons.badge_outlined,
                enabled: !protegido,
                borderColor: const Color.fromARGB(255, 111, 114, 255),
              ),

              const SizedBox(height: 12),

              CustomTextField(
                controller: celularController,
                hint: "Celular",
                icon: Icons.phone_android,
                enabled: !protegido,
                borderColor: const Color.fromARGB(255, 111, 114, 255),
              ),

              const SizedBox(height: 12),

              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color.fromARGB(255, 111, 114, 255),
                  ),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    dropdownColor: const Color(0xFF111827),
                    value: tipoUsuario,
                    isExpanded: true,
                    style: const TextStyle(color: Colors.white),
                    icon: Icon(
                      protegido ? Icons.lock : Icons.keyboard_arrow_down,
                      color: Colors.white,
                    ),
                    items: [
                      if (protegido)
                        const DropdownMenuItem(
                          value: "developer",
                          child: Text("Developer"),
                        ),

                      if (protegido)
                        const DropdownMenuItem(
                          value: "admin",
                          child: Text("Admin"),
                        ),

                      const DropdownMenuItem(
                        value: "encargado",
                        child: Text("Encargado"),
                      ),
                      const DropdownMenuItem(
                        value: "barista",
                        child: Text("Barista"),
                      ),
                      const DropdownMenuItem(
                        value: "mesero",
                        child: Text("Mesero"),
                      ),
                      const DropdownMenuItem(
                        value: "auxiliar",
                        child: Text("Auxiliar"),
                      ),
                    ],
                    onChanged: protegido
                        ? null
                        : (value) {
                            setState(() {
                              tipoUsuario = value!;
                            });
                          },
                  ),
                ),
              ),

              const SizedBox(height: 12),

              SwitchListTile(
                value: estado,
                activeColor: Colors.greenAccent,
                onChanged: protegido
                    ? null
                    : (v) {
                        setState(() {
                          estado = v;
                        });
                      },
                title: const Text(
                  "Estado",
                  style: TextStyle(color: Colors.white),
                ),
              ),

              fechaTile(
                "Fecha nacimiento",
                fechaNacimiento,
                () => seleccionarFecha(context, (f) {
                  setState(() {
                    fechaNacimiento = f;
                  });
                }),
                !protegido,
              ),

              fechaTile(
                "Fecha contratación",
                fechaContratacion,
                () => seleccionarFecha(context, (f) {
                  setState(() {
                    fechaContratacion = f;
                  });
                }),
                !protegido,
              ),

              fechaTile("Fecha creación", fechaCreacion, () {}, false),

              const SizedBox(height: 24),

              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: protegido ? null : eliminarUsuario,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text("Eliminar"),
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: ElevatedButton(
                      onPressed: protegido ? null : actualizarUsuario,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(
                          255,
                          111,
                          114,
                          255,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: cargando
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text("Actualizar"),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.white24),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    "Cerrar",
                    style: TextStyle(color: Colors.white70),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
