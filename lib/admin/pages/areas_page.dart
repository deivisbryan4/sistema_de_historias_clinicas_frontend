import 'package:flutter/material.dart';
import '../admin_models.dart';
import '../admin_api_service.dart';

// ═══════════════════════════════════════════════════════════════════════════════
// ÁREAS MÉDICAS — conectada al backend /api/admin/areas
// Soporte completo: Crear · Editar · Activar/Desactivar · Eliminar
// ═══════════════════════════════════════════════════════════════════════════════

class AreasPage extends StatefulWidget {
  const AreasPage({super.key});

  @override
  State<AreasPage> createState() => _AreasPageState();
}

class _AreasPageState extends State<AreasPage> {
  List<MedicalArea> _areas = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadAreas();
  }

  Future<void> _loadAreas() async {
    setState(() { _loading = true; _error = null; });
    try {
      final areas = await AdminApiService.getAreas();
      setState(() { _areas = areas; _loading = false; });
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
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Color(0xFFE84B4B)),
            const SizedBox(height: 12),
            Text('Error al cargar áreas', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
            const SizedBox(height: 4),
            Text(_error!, style: const TextStyle(color: Color(0xFF637995), fontSize: 13)),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: _loadAreas,
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: LayoutBuilder(
        builder: (context, c) {
          if (c.maxWidth < 720) return _buildCards();
          return _buildTable(context);
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final activas = _areas.where((a) => a.estado == AreaStatus.activa).length;
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
                const Text(
                  'Áreas y Servicios Médicos',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
                ),
                Text(
                  '${_areas.length} áreas registradas · $activas activas',
                  style: const TextStyle(color: Color(0xFF637995), fontSize: 14),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.refresh_outlined),
            tooltip: 'Actualizar',
            onPressed: _loadAreas,
          ),
          const SizedBox(width: 8),
          FilledButton.icon(
            onPressed: () => _showAreaForm(context, null),
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Nueva área'),
          ),
        ],
      ),
    );
  }

  Widget _buildTable(BuildContext context) {
    if (_areas.isEmpty) return _emptyState();
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
            dataRowMinHeight: 60,
            dataRowMaxHeight: 72,
            columnSpacing: 20,
            columns: const [
              DataColumn(label: _ColLabel('ÁREA')),
              DataColumn(label: _ColLabel('CÓDIGO')),
              DataColumn(label: _ColLabel('RESPONSABLE')),
              DataColumn(label: _ColLabel('PERSONAL')),
              DataColumn(label: _ColLabel('HORARIO')),
              DataColumn(label: _ColLabel('ESTADO')),
              DataColumn(label: _ColLabel('ACCIONES')),
            ],
            rows: _areas.map((area) => _buildRow(area, context)).toList(),
          ),
        ),
      ),
    );
  }

  DataRow _buildRow(MedicalArea area, BuildContext context) {
    return DataRow(
      cells: [
        DataCell(
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFF173E63).withValues(alpha: .08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.domain_outlined, size: 18, color: Color(0xFF173E63)),
              ),
              const SizedBox(width: 10),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(area.nombre, style: const TextStyle(fontWeight: FontWeight.w700)),
                  Text(
                    area.descripcion.length > 35
                        ? '${area.descripcion.substring(0, 35)}…'
                        : area.descripcion,
                    style: const TextStyle(color: Color(0xFF637995), fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
        ),
        DataCell(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: const Color(0xFFE3EDF9), borderRadius: BorderRadius.circular(6)),
            child: Text(area.codigo, style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF173E63), fontSize: 12)),
          ),
        ),
        DataCell(Text(area.responsable, style: const TextStyle(fontSize: 13))),
        DataCell(
          Row(children: [
            const Icon(Icons.people_outline, size: 16, color: Color(0xFF637995)),
            const SizedBox(width: 4),
            Text('${area.personalAsignado}'),
          ]),
        ),
        DataCell(SizedBox(width: 180, child: Text(area.horario, style: const TextStyle(fontSize: 12)))),
        DataCell(_AreaStatusBadge(area.estado)),
        DataCell(
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.edit_outlined, size: 18),
                tooltip: 'Editar',
                onPressed: () => _showAreaForm(context, area),
              ),
              IconButton(
                icon: Icon(
                  area.estado == AreaStatus.activa ? Icons.toggle_on_outlined : Icons.toggle_off_outlined,
                  size: 22,
                  color: area.estado == AreaStatus.activa ? const Color(0xFF2F8A5B) : const Color(0xFF637995),
                ),
                tooltip: area.estado == AreaStatus.activa ? 'Desactivar' : 'Activar',
                onPressed: () => _toggleStatus(area),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, size: 18, color: Color(0xFFE84B4B)),
                tooltip: 'Eliminar',
                onPressed: () => _confirmDelete(context, area),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCards() {
    if (_areas.isEmpty) return _emptyState();
    return Column(
      children: _areas.map((area) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: const Color(0xFFD4E0EC)),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: const Color(0xFFE3EDF9), borderRadius: BorderRadius.circular(6)),
                    child: Text(area.codigo, style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF173E63), fontSize: 12)),
                  ),
                  const Spacer(),
                  _AreaStatusBadge(area.estado),
                ],
              ),
              const SizedBox(height: 10),
              Text(area.nombre, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
              Text(area.descripcion, style: const TextStyle(color: Color(0xFF637995), fontSize: 13)),
              const SizedBox(height: 10),
              _CardRow(Icons.person_outline, area.responsable),
              _CardRow(Icons.people_outline, '${area.personalAsignado} personas asignadas'),
              _CardRow(Icons.schedule_outlined, area.horario),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _showAreaForm(context, area),
                      icon: const Icon(Icons.edit_outlined, size: 16),
                      label: const Text('Editar'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: area.estado == AreaStatus.activa ? const Color(0xFFE84B4B) : const Color(0xFF2F8A5B),
                      ),
                      onPressed: () => _toggleStatus(area),
                      icon: Icon(area.estado == AreaStatus.activa ? Icons.toggle_off_outlined : Icons.toggle_on_outlined, size: 16),
                      label: Text(area.estado == AreaStatus.activa ? 'Desactivar' : 'Activar'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Color(0xFFE84B4B)),
                    tooltip: 'Eliminar',
                    onPressed: () => _confirmDelete(context, area),
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
          const Icon(Icons.domain_outlined, size: 64, color: Color(0xFFD4E0EC)),
          const SizedBox(height: 16),
          const Text('No hay áreas registradas', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF637995))),
          const SizedBox(height: 8),
          FilledButton.icon(
            onPressed: () => _showAreaForm(context, null),
            icon: const Icon(Icons.add),
            label: const Text('Nueva área'),
          ),
        ],
      ),
    );
  }

  // ─── Actions ─────────────────────────────────────────────────────────────

  Future<void> _toggleStatus(MedicalArea area) async {
    try {
      final updated = await AdminApiService.toggleAreaStatus(area.id);
      setState(() {
        final idx = _areas.indexWhere((a) => a.id == updated.id);
        if (idx >= 0) _areas[idx] = updated;
      });
    } catch (e) {
      if (mounted) _showError('Error al cambiar estado: $e');
    }
  }

  void _confirmDelete(BuildContext context, MedicalArea area) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Eliminar área', style: TextStyle(fontWeight: FontWeight.w800)),
        content: Text('¿Deseas eliminar "${area.nombre}"? Esta acción no se puede deshacer.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: const Color(0xFFE84B4B)),
            onPressed: () async {
              Navigator.pop(context);
              await _deleteArea(area);
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteArea(MedicalArea area) async {
    try {
      await AdminApiService.deleteArea(area.id);
      setState(() => _areas.removeWhere((a) => a.id == area.id));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Área eliminada'), backgroundColor: Color(0xFF2F8A5B)),
        );
      }
    } catch (e) {
      if (mounted) _showError('Error al eliminar: $e');
    }
  }

  void _showAreaForm(BuildContext context, MedicalArea? area) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => _AreaFormDialog(
        area: area,
        onSave: (updated) async {
          try {
            if (area == null) {
              final created = await AdminApiService.createArea(updated);
              setState(() => _areas.add(created));
            } else {
              final saved = await AdminApiService.updateArea(area.id, updated);
              setState(() {
                final idx = _areas.indexWhere((a) => a.id == saved.id);
                if (idx >= 0) _areas[idx] = saved;
              });
            }
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(area == null ? 'Área creada correctamente' : 'Área actualizada correctamente'),
                backgroundColor: const Color(0xFF2F8A5B),
              ));
            }
          } catch (e) {
            if (mounted) _showError('Error al guardar: $e');
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

// ─── Status Badge ─────────────────────────────────────────────────────────────

class _AreaStatusBadge extends StatelessWidget {
  const _AreaStatusBadge(this.status);
  final AreaStatus status;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: status.color.withValues(alpha: .1),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: status.color.withValues(alpha: .3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 6, height: 6, decoration: BoxDecoration(color: status.color, shape: BoxShape.circle)),
          const SizedBox(width: 5),
          Text(status.label, style: TextStyle(color: status.color, fontWeight: FontWeight.w700, fontSize: 12)),
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

// ─── Area Form Dialog ─────────────────────────────────────────────────────────

class _AreaFormDialog extends StatefulWidget {
  const _AreaFormDialog({this.area, required this.onSave});
  final MedicalArea? area;
  final void Function(MedicalArea) onSave;

  @override
  State<_AreaFormDialog> createState() => _AreaFormDialogState();
}

class _AreaFormDialogState extends State<_AreaFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nombre;
  late final TextEditingController _codigo;
  late final TextEditingController _descripcion;
  late final TextEditingController _responsable;
  late final TextEditingController _horario;
  AreaStatus _estado = AreaStatus.activa;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final a = widget.area;
    _nombre = TextEditingController(text: a?.nombre ?? '');
    _codigo = TextEditingController(text: a?.codigo ?? '');
    _descripcion = TextEditingController(text: a?.descripcion ?? '');
    _responsable = TextEditingController(text: a?.responsable ?? '');
    _horario = TextEditingController(text: a?.horario ?? '');
    _estado = a?.estado ?? AreaStatus.activa;
  }

  @override
  void dispose() {
    for (final c in [_nombre, _codigo, _descripcion, _responsable, _horario]) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.area != null;
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(24, 20, 20, 16),
              decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFFEAF0F6)))),
              child: Row(
                children: [
                  const Icon(Icons.domain_outlined, color: Color(0xFF173E63)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      isEdit ? 'Editar área' : 'Nueva área médica',
                      style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
                    ),
                  ),
                  IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    _field('Nombre del área *', _nombre, required: true),
                    Row(
                      children: [
                        Expanded(child: _field('Código *', _codigo, required: true)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: DropdownButtonFormField<AreaStatus>(
                            value: _estado,
                            decoration: InputDecoration(
                              labelText: 'Estado',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                              filled: true,
                              fillColor: const Color(0xFFF7FAFE),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                            ),
                            items: AreaStatus.values
                                .map((s) => DropdownMenuItem(value: s, child: Text(s.label)))
                                .toList(),
                            onChanged: (v) => setState(() => _estado = v ?? _estado),
                          ),
                        ),
                      ],
                    ),
                    _field('Descripción', _descripcion),
                    _field('Responsable', _responsable),
                    _field('Horario de atención', _horario),
                  ],
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
                    onPressed: _saving ? null : _save,
                    icon: _saving
                        ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Icon(Icons.save_outlined, size: 16),
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

  Widget _field(String label, TextEditingController ctrl, {bool required = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: ctrl,
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
    setState(() => _saving = true);
    final a = widget.area;
    final updated = MedicalArea(
      id: a?.id ?? '',
      nombre: _nombre.text.trim(),
      codigo: _codigo.text.trim(),
      descripcion: _descripcion.text.trim(),
      responsable: _responsable.text.trim(),
      personalAsignado: a?.personalAsignado ?? 0,
      estado: _estado,
      horario: _horario.text.trim(),
    );
    Navigator.pop(context);
    widget.onSave(updated);
  }
}
