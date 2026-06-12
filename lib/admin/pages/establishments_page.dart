import 'package:flutter/material.dart';
import '../admin_models.dart';
import '../admin_api_service.dart';

// ═══════════════════════════════════════════════════════════════════════════════
// ESTABLECIMIENTOS DE SALUD — conectado al backend /api/admin/establishments
// Soporte completo: Crear · Editar · Activar/Desactivar · Eliminar
// ═══════════════════════════════════════════════════════════════════════════════

class EstablishmentsPage extends StatefulWidget {
  const EstablishmentsPage({super.key});

  @override
  State<EstablishmentsPage> createState() => _EstablishmentsPageState();
}

class _EstablishmentsPageState extends State<EstablishmentsPage> {
  List<Establishment> _establishments = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final list = await AdminApiService.getEstablishments();
      setState(() { _establishments = list; _loading = false; });
    } catch (e) {
      setState(() { _error = e.toString(); _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildHeader(context),
        Expanded(child: _buildBody(context)),
      ],
    );
  }

  Widget _buildBody(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Color(0xFFE84B4B)),
            const SizedBox(height: 12),
            const Text('Error al cargar establecimientos', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
            const SizedBox(height: 4),
            Text(_error!, style: const TextStyle(color: Color(0xFF637995), fontSize: 13)),
            const SizedBox(height: 16),
            FilledButton.icon(onPressed: _load, icon: const Icon(Icons.refresh), label: const Text('Reintentar')),
          ],
        ),
      );
    }
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: LayoutBuilder(
        builder: (context, c) {
          if (c.maxWidth < 760) return _buildCards();
          return _buildTable(context);
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final activos = _establishments.where((e) => e.activo).length;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFD4E0EC))),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Establecimientos de Salud',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
                Text(
                  '${_establishments.length} establecimientos · $activos activos — RENIPRESS',
                  style: const TextStyle(color: Color(0xFF637995), fontSize: 14),
                ),
              ],
            ),
          ),
          IconButton(icon: const Icon(Icons.refresh_outlined), tooltip: 'Actualizar', onPressed: _load),
          const SizedBox(width: 8),
          FilledButton.icon(
            onPressed: () => _showForm(context, null),
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Nuevo establecimiento'),
          ),
        ],
      ),
    );
  }

  Widget _buildTable(BuildContext context) {
    if (_establishments.isEmpty) return _emptyState();
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFD4E0EC)),
        borderRadius: BorderRadius.circular(14),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            headingRowColor: WidgetStateProperty.all(const Color(0xFFF4F7FB)),
            dataRowMinHeight: 70,
            dataRowMaxHeight: 80,
            columnSpacing: 16,
            columns: const [
              DataColumn(label: _ColLabel('ESTABLECIMIENTO')),
              DataColumn(label: _ColLabel('RENIPRESS')),
              DataColumn(label: _ColLabel('RED / MICRORED')),
              DataColumn(label: _ColLabel('UBICACIÓN')),
              DataColumn(label: _ColLabel('RESPONSABLE')),
              DataColumn(label: _ColLabel('TELÉFONO')),
              DataColumn(label: _ColLabel('ESTADO')),
              DataColumn(label: _ColLabel('ACCIONES')),
            ],
            rows: _establishments.map((e) => _buildRow(e, context)).toList(),
          ),
        ),
      ),
    );
  }

  DataRow _buildRow(Establishment e, BuildContext context) {
    return DataRow(
      cells: [
        DataCell(
          Row(
            children: [
              Container(
                width: 38, height: 38,
                decoration: BoxDecoration(
                  color: const Color(0xFF173E63).withValues(alpha: .08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.local_hospital_outlined, size: 18, color: Color(0xFF173E63)),
              ),
              const SizedBox(width: 10),
              SizedBox(
                width: 170,
                child: Text(e.nombre, style: const TextStyle(fontWeight: FontWeight.w700)),
              ),
            ],
          ),
        ),
        DataCell(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: const Color(0xFFE3EDF9), borderRadius: BorderRadius.circular(6)),
            child: Text(e.codigoRenipress, style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF173E63), fontSize: 12)),
          ),
        ),
        DataCell(
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(e.red, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
              Text(e.microred, style: const TextStyle(fontSize: 11, color: Color(0xFF637995))),
            ],
          ),
        ),
        DataCell(
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(e.distrito, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
              Text('${e.provincia}, ${e.departamento}', style: const TextStyle(fontSize: 11, color: Color(0xFF637995))),
            ],
          ),
        ),
        DataCell(Text(e.responsable, style: const TextStyle(fontSize: 13))),
        DataCell(Text(e.telefono, style: const TextStyle(fontSize: 13))),
        DataCell(_EstabStatusBadge(e.activo)),
        DataCell(
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.edit_outlined, size: 18),
                tooltip: 'Editar',
                onPressed: () => _showForm(context, e),
              ),
              IconButton(
                icon: Icon(
                  e.activo ? Icons.toggle_on_outlined : Icons.toggle_off_outlined,
                  size: 22,
                  color: e.activo ? const Color(0xFF2F8A5B) : const Color(0xFF637995),
                ),
                tooltip: e.activo ? 'Desactivar' : 'Activar',
                onPressed: () => _toggleActive(e),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, size: 18, color: Color(0xFFE84B4B)),
                tooltip: 'Eliminar',
                onPressed: () => _confirmDelete(context, e),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCards() {
    if (_establishments.isEmpty) return _emptyState();
    return Column(
      children: _establishments.map((e) {
        return Container(
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: const Color(0xFFD4E0EC)),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF173E63).withValues(alpha: .08),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.local_hospital_outlined, size: 20, color: Color(0xFF173E63)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(e.nombre, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                        Container(
                          margin: const EdgeInsets.only(top: 4),
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(color: const Color(0xFFE3EDF9), borderRadius: BorderRadius.circular(6)),
                          child: Text(e.codigoRenipress, style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF173E63), fontSize: 12)),
                        ),
                      ],
                    ),
                  ),
                  _EstabStatusBadge(e.activo),
                ],
              ),
              const SizedBox(height: 12),
              _CardRow(Icons.account_tree_outlined, '${e.red} · ${e.microred}'),
              _CardRow(Icons.location_on_outlined, '${e.distrito}, ${e.provincia} — ${e.departamento}'),
              _CardRow(Icons.person_outline, e.responsable),
              _CardRow(Icons.phone_outlined, e.telefono),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _showForm(context, e),
                      icon: const Icon(Icons.edit_outlined, size: 16),
                      label: const Text('Editar'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: e.activo ? const Color(0xFFE84B4B) : const Color(0xFF2F8A5B),
                      ),
                      onPressed: () => _toggleActive(e),
                      icon: Icon(e.activo ? Icons.toggle_off_outlined : Icons.toggle_on_outlined, size: 16),
                      label: Text(e.activo ? 'Desactivar' : 'Activar'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Color(0xFFE84B4B)),
                    tooltip: 'Eliminar',
                    onPressed: () => _confirmDelete(context, e),
                  ),
                ],
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.local_hospital_outlined, size: 64, color: Color(0xFFD4E0EC)),
          const SizedBox(height: 16),
          const Text('No hay establecimientos registrados', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF637995))),
          const SizedBox(height: 8),
          FilledButton.icon(
            onPressed: () => _showForm(context, null),
            icon: const Icon(Icons.add),
            label: const Text('Nuevo establecimiento'),
          ),
        ],
      ),
    );
  }

  // ─── Actions ─────────────────────────────────────────────────────────────

  Future<void> _toggleActive(Establishment e) async {
    try {
      final updated = await AdminApiService.toggleEstablishmentActive(e.id);
      setState(() {
        final idx = _establishments.indexWhere((x) => x.id == updated.id);
        if (idx >= 0) _establishments[idx] = updated;
      });
    } catch (err) {
      if (mounted) _showError('Error al cambiar estado: $err');
    }
  }

  void _confirmDelete(BuildContext context, Establishment e) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Eliminar establecimiento', style: TextStyle(fontWeight: FontWeight.w800)),
        content: Text('¿Deseas eliminar "${e.nombre}"? Esta acción no se puede deshacer.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: const Color(0xFFE84B4B)),
            onPressed: () async {
              Navigator.pop(context);
              await _delete(e);
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  Future<void> _delete(Establishment e) async {
    try {
      await AdminApiService.deleteEstablishment(e.id);
      setState(() => _establishments.removeWhere((x) => x.id == e.id));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Establecimiento eliminado'), backgroundColor: Color(0xFF2F8A5B)),
        );
      }
    } catch (err) {
      if (mounted) _showError('Error al eliminar: $err');
    }
  }

  void _showForm(BuildContext context, Establishment? estab) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => _EstabFormDialog(
        establishment: estab,
        onSave: (updated) async {
          try {
            if (estab == null) {
              final created = await AdminApiService.createEstablishment(updated);
              setState(() => _establishments.add(created));
            } else {
              final saved = await AdminApiService.updateEstablishment(estab.id, updated);
              setState(() {
                final idx = _establishments.indexWhere((x) => x.id == saved.id);
                if (idx >= 0) _establishments[idx] = saved;
              });
            }
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(estab == null ? 'Establecimiento creado' : 'Establecimiento actualizado'),
                backgroundColor: const Color(0xFF2F8A5B),
              ));
            }
          } catch (err) {
            if (mounted) _showError('Error al guardar: $err');
          }
        },
      ),
    );
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: const Color(0xFFE84B4B)),
    );
  }
}

// ─── Supporting Widgets ───────────────────────────────────────────────────────

class _EstabStatusBadge extends StatelessWidget {
  const _EstabStatusBadge(this.activo);
  final bool activo;

  @override
  Widget build(BuildContext context) {
    final color = activo ? const Color(0xFF2F8A5B) : const Color(0xFF637995);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .1),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: .3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 6, height: 6, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 5),
          Text(activo ? 'Activo' : 'Inactivo', style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 12)),
        ],
      ),
    );
  }
}

class _CardRow extends StatelessWidget {
  const _CardRow(this.icon, this.text);
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(icon, size: 14, color: const Color(0xFF637995)),
          const SizedBox(width: 6),
          Expanded(child: Text(text, style: const TextStyle(color: Color(0xFF637995), fontSize: 13))),
        ],
      ),
    );
  }
}

class _ColLabel extends StatelessWidget {
  const _ColLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(text, style: const TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF637995), fontSize: 12));
  }
}

// ─── Establishment Form Dialog ────────────────────────────────────────────────

class _EstabFormDialog extends StatefulWidget {
  const _EstabFormDialog({this.establishment, required this.onSave});
  final Establishment? establishment;
  final void Function(Establishment) onSave;

  @override
  State<_EstabFormDialog> createState() => _EstabFormDialogState();
}

class _EstabFormDialogState extends State<_EstabFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nombre;
  late final TextEditingController _codigo;
  late final TextEditingController _red;
  late final TextEditingController _microred;
  late final TextEditingController _distrito;
  late final TextEditingController _provincia;
  late final TextEditingController _departamento;
  late final TextEditingController _responsable;
  late final TextEditingController _telefono;
  bool _activo = true;

  @override
  void initState() {
    super.initState();
    final e = widget.establishment;
    _nombre = TextEditingController(text: e?.nombre ?? '');
    _codigo = TextEditingController(text: e?.codigoRenipress ?? '');
    _red = TextEditingController(text: e?.red ?? '');
    _microred = TextEditingController(text: e?.microred ?? '');
    _distrito = TextEditingController(text: e?.distrito ?? '');
    _provincia = TextEditingController(text: e?.provincia ?? '');
    _departamento = TextEditingController(text: e?.departamento ?? 'Puno');
    _responsable = TextEditingController(text: e?.responsable ?? '');
    _telefono = TextEditingController(text: e?.telefono ?? '');
    _activo = e?.activo ?? true;
  }

  @override
  void dispose() {
    for (final c in [_nombre, _codigo, _red, _microred, _distrito, _provincia, _departamento, _responsable, _telefono]) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600, maxHeight: 650),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(24, 20, 20, 16),
              decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFFEAF0F6)))),
              child: Row(
                children: [
                  const Icon(Icons.local_hospital_outlined, color: Color(0xFF173E63)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      widget.establishment == null ? 'Nuevo establecimiento' : 'Editar establecimiento',
                      style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
                    ),
                  ),
                  IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: LayoutBuilder(
                    builder: (context, c) {
                      final twoCol = c.maxWidth >= 400;
                      return Column(
                        children: [
                          _field('Nombre del establecimiento *', _nombre, required: true),
                          _field('Código RENIPRESS *', _codigo, required: true),
                          if (twoCol)
                            Row(children: [
                              Expanded(child: _field('Red de salud', _red)),
                              const SizedBox(width: 12),
                              Expanded(child: _field('Microred', _microred)),
                            ])
                          else ...[_field('Red de salud', _red), _field('Microred', _microred)],
                          if (twoCol)
                            Row(children: [
                              Expanded(child: _field('Distrito', _distrito)),
                              const SizedBox(width: 12),
                              Expanded(child: _field('Provincia', _provincia)),
                            ])
                          else ...[_field('Distrito', _distrito), _field('Provincia', _provincia)],
                          _field('Departamento', _departamento),
                          if (twoCol)
                            Row(children: [
                              Expanded(child: _field('Responsable', _responsable)),
                              const SizedBox(width: 12),
                              Expanded(child: _field('Teléfono', _telefono, keyboard: TextInputType.phone)),
                            ])
                          else ...[_field('Responsable', _responsable), _field('Teléfono', _telefono, keyboard: TextInputType.phone)],
                          SwitchListTile(
                            value: _activo,
                            onChanged: (v) => setState(() => _activo = v),
                            contentPadding: EdgeInsets.zero,
                            title: const Text('Establecimiento activo'),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
              child: Row(
                children: [
                  const Spacer(),
                  OutlinedButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
                  const SizedBox(width: 12),
                  FilledButton.icon(
                    onPressed: _save,
                    icon: const Icon(Icons.save_outlined, size: 16),
                    label: const Text('Guardar'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _field(String label, TextEditingController ctrl, {bool required = false, TextInputType? keyboard}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: ctrl,
        keyboardType: keyboard,
        validator: required ? (v) => (v == null || v.trim().isEmpty) ? 'Campo obligatorio' : null : null,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          filled: true,
          fillColor: const Color(0xFFF7FAFE),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        ),
      ),
    );
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final e = widget.establishment;
    widget.onSave(
      Establishment(
        id: e?.id ?? '',
        nombre: _nombre.text.trim(),
        codigoRenipress: _codigo.text.trim(),
        red: _red.text.trim(),
        microred: _microred.text.trim(),
        distrito: _distrito.text.trim(),
        provincia: _provincia.text.trim(),
        departamento: _departamento.text.trim(),
        responsable: _responsable.text.trim(),
        telefono: _telefono.text.trim(),
        activo: _activo,
      ),
    );
    Navigator.pop(context);
  }
}
