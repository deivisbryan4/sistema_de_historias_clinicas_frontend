import 'package:flutter/material.dart';
import '../core/models.dart';
import '../core/services.dart';
import '../core/app_state_widgets.dart';
import '../widgets/common_widgets.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Patients Page — conectada al API con CRUD completo
// ─────────────────────────────────────────────────────────────────────────────
class PatientsPage extends StatefulWidget {
  const PatientsPage({super.key});

  @override
  State<PatientsPage> createState() => _PatientsPageState();
}

class _PatientsPageState extends State<PatientsPage> {
  List<Patient> _patients = [];
  bool _loading = true;
  Object? _error;
  String _search = '';
  String? _statusFilter;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final data = await PatientService.getAll(
        search: _search.isEmpty ? null : _search,
        status: _statusFilter,
      );
      if (mounted) setState(() { _patients = data; _loading = false; });
    } catch (e) {
      if (mounted) setState(() { _error = e; _loading = false; });
    }
  }

  Future<void> _openForm([Patient? patient]) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _PatientFormDialog(patient: patient),
    );
    if (result == true) _load();
  }

  Future<void> _delete(Patient p) async {
    final ok = await confirmDialog(
      context,
      title: 'Eliminar paciente',
      content: '¿Eliminar a ${p.nombreCompleto}? Esta acción no se puede deshacer.',
      confirmLabel: 'Eliminar',
    );
    if (!ok || !mounted) return;
    try {
      await PatientService.delete(p.id);
      showSuccess(context, 'Paciente eliminado correctamente');
      _load();
    } catch (e) {
      showError(context, e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppHeader(
          title: 'Gestión de Pacientes',
          subtitle: 'Registro y seguimiento de pacientes',
          actions: [
            FilledButton.icon(
              onPressed: () => _openForm(),
              icon: const Icon(Icons.person_add_alt),
              label: const Text('Nuevo Paciente'),
            ),
          ],
        ),
        PageBody(
          child: Column(
            children: [
              // ── Barra de búsqueda y filtros ──────────────────────────────
              Panel(
                padding: const EdgeInsets.all(14),
                child: Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    ConstrainedBox(
                      constraints: const BoxConstraints(minWidth: 180, maxWidth: 320),
                      child: TextField(
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.search),
                          hintText: 'Buscar por nombre o DNI',
                          filled: true,
                          fillColor: AppColors.bg,
                          isDense: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        onChanged: (v) {
                          _search = v;
                          Future.delayed(const Duration(milliseconds: 500), _load);
                        },
                      ),
                    ),
                    DropdownButtonHideUnderline(
                      child: DropdownButton<String?>(
                        value: _statusFilter,
                        hint: const Text('Todos los estados'),
                        items: const [
                          DropdownMenuItem(value: null, child: Text('Todos')),
                          DropdownMenuItem(value: 'ACTIVO', child: Text('Activo')),
                          DropdownMenuItem(value: 'NUEVO', child: Text('Nuevo')),
                          DropdownMenuItem(value: 'CRONICO', child: Text('Crónico')),
                          DropdownMenuItem(value: 'INACTIVO', child: Text('Inactivo')),
                        ],
                        onChanged: (v) => setState(() { _statusFilter = v; _load(); }),
                      ),
                    ),
                    IconButton(
                      onPressed: _load,
                      icon: const Icon(Icons.refresh),
                      tooltip: 'Actualizar',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              // ── Tabla de pacientes ─────────────────────────────────────
              Panel(
                padding: EdgeInsets.zero,
                child: _loading
                    ? const LoadingState(message: 'Cargando pacientes...')
                    : _error != null
                        ? ErrorState(error: _error!, onRetry: _load)
                        : _patients.isEmpty
                            ? const EmptyState(
                                message: 'No hay pacientes registrados',
                                icon: Icons.people_outline,
                              )
                            : SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: DataTable(
                                  headingRowColor: WidgetStateProperty.all(
                                    const Color(0xFFF4F7FB),
                                  ),
                                  columns: const [
                                    DataColumn(label: Text('N° HC')),
                                    DataColumn(label: Text('PACIENTE')),
                                    DataColumn(label: Text('DNI')),
                                    DataColumn(label: Text('SEGURO')),
                                    DataColumn(label: Text('ESTADO')),
                                    DataColumn(label: Text('ACCIONES')),
                                  ],
                                  rows: _patients.map((p) {
                                    return DataRow(cells: [
                                      DataCell(Text(
                                        p.numeroHc,
                                        style: const TextStyle(
                                          color: AppColors.blue,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      )),
                                      DataCell(Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Avatar(p.initials),
                                          const SizedBox(width: 10),
                                          Text(
                                            p.nombreCompleto,
                                            style: const TextStyle(fontWeight: FontWeight.w700),
                                          ),
                                        ],
                                      )),
                                      DataCell(Text(p.dni)),
                                      DataCell(Text(p.asegurado)),
                                      DataCell(_PatientStatusPill(p.estado)),
                                      DataCell(Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            icon: const Icon(Icons.visibility_outlined,
                                                size: 18, color: AppColors.blue),
                                            tooltip: 'Ver historia',
                                            onPressed: () {},
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.edit_outlined, size: 18),
                                            tooltip: 'Editar',
                                            onPressed: () => _openForm(p),
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.delete_outline,
                                                size: 18, color: AppColors.red),
                                            tooltip: 'Eliminar',
                                            onPressed: () => _delete(p),
                                          ),
                                        ],
                                      )),
                                    ]);
                                  }).toList(),
                                ),
                              ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Formulario de paciente (crear / editar)
// ─────────────────────────────────────────────────────────────────────────────
class _PatientFormDialog extends StatefulWidget {
  const _PatientFormDialog({this.patient});
  final Patient? patient;

  @override
  State<_PatientFormDialog> createState() => _PatientFormDialogState();
}

class _PatientFormDialogState extends State<_PatientFormDialog> {
  final _formKey = GlobalKey<FormState>();
  bool _saving = false;

  late final TextEditingController _nombres;
  late final TextEditingController _apellidos;
  late final TextEditingController _dni;
  late final TextEditingController _telefono;
  late final TextEditingController _email;
  late final TextEditingController _direccion;
  late final TextEditingController _distrito;
  late final TextEditingController _alertas;
  String _sexo = 'Masculino';
  String _asegurado = 'SIS';
  String _grupoSanguineo = 'O+';
  String _estadoCivil = 'Soltero/a';
  String _estado = 'NUEVO';

  @override
  void initState() {
    super.initState();
    final p = widget.patient;
    _nombres = TextEditingController(text: p?.nombres ?? '');
    _apellidos = TextEditingController(text: p?.apellidos ?? '');
    _dni = TextEditingController(text: p?.dni ?? '');
    _telefono = TextEditingController(text: p?.telefono ?? '');
    _email = TextEditingController(text: p?.email ?? '');
    _direccion = TextEditingController();
    _distrito = TextEditingController(text: p?.distrito ?? '');
    _alertas = TextEditingController(text: p?.alertas ?? '');
    if (p != null) {
      _sexo = p.sexo.isNotEmpty ? p.sexo : 'Masculino';
      _asegurado = p.asegurado.isNotEmpty ? p.asegurado : 'SIS';
      _grupoSanguineo = p.grupoSanguineo ?? 'O+';
      _estado = p.estado.isNotEmpty ? p.estado : 'NUEVO';
    }
  }

  @override
  void dispose() {
    for (final c in [_nombres, _apellidos, _dni, _telefono, _email,
        _direccion, _distrito, _alertas]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      final body = {
        'nombres': _nombres.text.trim(),
        'apellidos': _apellidos.text.trim(),
        'dni': _dni.text.trim(),
        'sexo': _sexo,
        'telefono': _telefono.text.trim(),
        'email': _email.text.trim(),
        'asegurado': _asegurado,
        'grupoSanguineo': _grupoSanguineo,
        'estadoCivil': _estadoCivil,
        'estado': _estado,
        'distrito': _distrito.text.trim(),
        'alertas': _alertas.text.trim(),
      };
      if (widget.patient == null) {
        await PatientService.create(body);
      } else {
        await PatientService.update(widget.patient!.id, body);
      }
      if (mounted) {
        showSuccess(context,
            widget.patient == null ? 'Paciente creado correctamente' : 'Paciente actualizado');
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) showError(context, e);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.patient != null;
    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 640, maxHeight: 620),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
              decoration: const BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
              ),
              child: Row(
                children: [
                  Icon(
                    isEdit ? Icons.edit_outlined : Icons.person_add_alt,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    isEdit ? 'Editar Paciente' : 'Nuevo Paciente',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w800),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context, false),
                    icon: const Icon(Icons.close, color: Colors.white),
                  ),
                ],
              ),
            ),
            // Form
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    children: [
                      _field('Nombres *', _nombres, validator: _required),
                      _field('Apellidos *', _apellidos, validator: _required),
                      _field('DNI *', _dni,
                          validator: (v) => (v == null || v.length != 8)
                              ? 'DNI debe tener 8 dígitos'
                              : null,
                          keyboard: TextInputType.number),
                      _field('Teléfono', _telefono,
                          keyboard: TextInputType.phone),
                      _field('Correo', _email,
                          keyboard: TextInputType.emailAddress),
                      _field('Distrito', _distrito),
                      _dropdown('Sexo', _sexo,
                          ['Masculino', 'Femenino', 'Otro'],
                          (v) => setState(() => _sexo = v!)),
                      _dropdown('Seguro', _asegurado,
                          ['SIS', 'ESSALUD', 'Privado', 'Ninguno'],
                          (v) => setState(() => _asegurado = v!)),
                      _dropdown('Grupo sanguíneo', _grupoSanguineo,
                          ['O+', 'O-', 'A+', 'A-', 'B+', 'B-', 'AB+', 'AB-'],
                          (v) => setState(() => _grupoSanguineo = v!)),
                      _dropdown('Estado', _estado,
                          ['NUEVO', 'ACTIVO', 'CRONICO', 'INACTIVO'],
                          (v) => setState(() => _estado = v!)),
                      ConstrainedBox(
                        constraints: const BoxConstraints(minWidth: 400),
                        child: TextFormField(
                          controller: _alertas,
                          maxLines: 2,
                          decoration: const InputDecoration(
                            labelText: 'Alertas / Alergias',
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Actions
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: Color(0xFFD4E0EC))),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed:
                        _saving ? null : () => Navigator.pop(context, false),
                    child: const Text('Cancelar'),
                  ),
                  const SizedBox(width: 12),
                  FilledButton.icon(
                    onPressed: _saving ? null : _save,
                    icon: _saving
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white))
                        : Icon(isEdit ? Icons.save_outlined : Icons.add),
                    label: Text(isEdit ? 'Guardar cambios' : 'Crear paciente'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _field(
    String label,
    TextEditingController ctrl, {
    String? Function(String?)? validator,
    TextInputType? keyboard,
  }) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 240, maxWidth: 280),
      child: TextFormField(
        controller: ctrl,
        keyboardType: keyboard,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          isDense: true,
        ),
      ),
    );
  }

  Widget _dropdown(
    String label,
    String value,
    List<String> options,
    void Function(String?) onChanged,
  ) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 200, maxWidth: 280),
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          isDense: true,
        ),
        items: options
            .map((o) => DropdownMenuItem(value: o, child: Text(o)))
            .toList(),
        onChanged: onChanged,
      ),
    );
  }

  String? _required(String? v) =>
      (v == null || v.trim().isEmpty) ? 'Campo requerido' : null;
}

// ─────────────────────────────────────────────────────────────────────────────
// Widgets auxiliares
// ─────────────────────────────────────────────────────────────────────────────
class _PatientStatusPill extends StatelessWidget {
  const _PatientStatusPill(this.status);
  final String status;

  @override
  Widget build(BuildContext context) {
    final (color, label) = switch (status.toUpperCase()) {
      'ACTIVO' => (AppColors.green, 'Activo'),
      'NUEVO' => (AppColors.blue, 'Nuevo'),
      'CRONICO' => (AppColors.orange, 'Crónico'),
      _ => (AppColors.muted, 'Inactivo'),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
            color: color, fontWeight: FontWeight.w700, fontSize: 12),
      ),
    );
  }
}
