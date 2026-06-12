import 'package:flutter/material.dart';
import '../core/models.dart';
import '../core/services.dart';
import '../core/user_session.dart';
import '../core/app_state_widgets.dart';
import '../widgets/common_widgets.dart';

class PrescriptionPage extends StatefulWidget {
  const PrescriptionPage({super.key});

  @override
  State<PrescriptionPage> createState() => _PrescriptionPageState();
}

class _PrescriptionPageState extends State<PrescriptionPage> {
  List<Prescription> _prescriptions = [];
  bool _loading = true;
  Object? _error;
  String? _expandedId;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final r = await PrescriptionService.getAll();
      if (mounted) setState(() { _prescriptions = r; _loading = false; });
    } catch (e) {
      if (mounted) setState(() { _error = e; _loading = false; });
    }
  }

  Future<void> _voidPrescription(Prescription p) async {
    final ok = await confirmDialog(
      context,
      title: 'Anular receta',
      content: '¿Deseas anular la receta ${p.numeroReceta} de ${p.patientNombre}?',
      confirmLabel: 'Anular',
    );
    if (!ok || !mounted) return;
    try {
      await PrescriptionService.void_(p.id);
      if (mounted) {
        showSuccess(context, 'Receta anulada correctamente');
        _load();
      }
    } catch (e) {
      if (mounted) showError(context, e);
    }
  }

  Future<void> _openNewPrescription() async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const _PrescriptionFormDialog(),
    );
    if (result == true && mounted) _load();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppHeader(
          title: 'Recetas Médicas',
          subtitle: 'Gestión de recetas electrónicas',
          actions: [
            IconButton(
              onPressed: _load,
              icon: const Icon(Icons.refresh),
              tooltip: 'Actualizar',
            ),
            FilledButton.icon(
              onPressed: _openNewPrescription,
              icon: const Icon(Icons.add),
              label: const Text('Nueva Receta'),
            ),
          ],
        ),
        PageBody(
          child: _loading
              ? const LoadingState(message: 'Cargando recetas...')
              : _error != null
                  ? ErrorState(error: _error!, onRetry: _load)
                  : _prescriptions.isEmpty
                      ? const EmptyState(
                          message: 'No hay recetas registradas',
                          icon: Icons.medication_outlined,
                        )
                      : Panel(
                          padding: EdgeInsets.zero,
                          child: Column(
                            children: [
                              for (final p in _prescriptions)
                                _PrescriptionTile(
                                  prescription: p,
                                  isExpanded: _expandedId == p.id,
                                  onTap: () => setState(() =>
                                      _expandedId =
                                          (_expandedId == p.id) ? null : p.id),
                                  onVoid: p.estado.toUpperCase() != 'ANULADA'
                                      ? () => _voidPrescription(p)
                                      : null,
                                ),
                            ],
                          ),
                        ),
        ),
      ],
    );
  }
}

class _PrescriptionTile extends StatelessWidget {
  const _PrescriptionTile({
    required this.prescription,
    required this.isExpanded,
    required this.onTap,
    this.onVoid,
  });
  final Prescription prescription;
  final bool isExpanded;
  final VoidCallback onTap;
  final VoidCallback? onVoid;

  Color get _statusColor {
    switch (prescription.estado.toUpperCase()) {
      case 'VIGENTE': return AppColors.green;
      case 'DISPENSADA': return AppColors.blue;
      case 'ANULADA': return AppColors.red;
      default: return AppColors.muted;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            child: Row(
              children: [
                Avatar(prescription.patientNombre.isNotEmpty
                    ? prescription.patientNombre.split(' ').take(2)
                        .map((w) => w.isNotEmpty ? w[0] : '').join().toUpperCase()
                    : '??'),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(prescription.patientNombre,
                          style: const TextStyle(
                              fontWeight: FontWeight.w800, fontSize: 16)),
                      Text('${prescription.numeroReceta} · '
                          '${prescription.fecha.length >= 10 ? prescription.fecha.substring(0, 10) : prescription.fecha}'
                          ' · ${prescription.medico}',
                          style: const TextStyle(
                              color: AppColors.muted, fontSize: 13)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _statusColor.withValues(alpha: .12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    prescription.estado,
                    style: TextStyle(color: _statusColor, fontWeight: FontWeight.w700, fontSize: 12),
                  ),
                ),
                const SizedBox(width: 8),
                if (onVoid != null)
                  IconButton(
                    icon: const Icon(Icons.block, color: AppColors.red, size: 18),
                    tooltip: 'Anular receta',
                    onPressed: onVoid,
                  ),
                Icon(isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: AppColors.muted),
              ],
            ),
          ),
        ),
        if (isExpanded && prescription.items.isNotEmpty)
          Container(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            color: const Color(0xFFF7FAFE),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Divider(height: 1),
                const SizedBox(height: 12),
                const Text('MEDICAMENTOS',
                    style: TextStyle(color: AppColors.muted,
                        fontWeight: FontWeight.w800, fontSize: 12)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    for (final item in prescription.items)
                      MedicineBox(
                        item.medicamento,
                        '${item.dosis} · ${item.frecuencia} · ${item.duracion} · Cant: ${item.cantidad}',
                        item.dosis,
                      ),
                  ],
                ),
              ],
            ),
          ),
        const Divider(height: 1, color: AppColors.line),
      ],
    );
  }
}

class _PrescriptionFormDialog extends StatefulWidget {
  const _PrescriptionFormDialog();

  @override
  State<_PrescriptionFormDialog> createState() =>
      _PrescriptionFormDialogState();
}

class _PrescriptionFormDialogState extends State<_PrescriptionFormDialog> {
  bool _saving = false;
  bool _searchingPatient = false;
  Patient? _patient;
  final _patientSearchCtrl = TextEditingController();
  List<Patient> _patientResults = [];
  final _obsCtrl = TextEditingController();

  // Medication items
  final List<Map<String, TextEditingController>> _items = [];

  @override
  void initState() {
    super.initState();
    _addItem();
  }

  @override
  void dispose() {
    _patientSearchCtrl.dispose();
    _obsCtrl.dispose();
    for (final m in _items) m.values.forEach((c) => c.dispose());
    super.dispose();
  }

  void _addItem() {
    setState(() {
      _items.add({
        'medicamento': TextEditingController(),
        'dosis': TextEditingController(),
        'frecuencia': TextEditingController(),
        'duracion': TextEditingController(),
        'cantidad': TextEditingController(text: '1'),
      });
    });
  }

  Future<void> _searchPatients(String q) async {
    if (q.trim().isEmpty) { setState(() => _patientResults = []); return; }
    setState(() => _searchingPatient = true);
    try {
      final r = await PatientService.getAll(search: q.trim());
      if (mounted) setState(() { _patientResults = r; _searchingPatient = false; });
    } catch (_) {
      if (mounted) setState(() { _searchingPatient = false; });
    }
  }

  Future<void> _save() async {
    if (_patient == null) {
      showError(context, 'Selecciona un paciente');
      return;
    }
    if (_items.isEmpty || _items.every((m) =>
        m['medicamento']!.text.trim().isEmpty)) {
      showError(context, 'Agrega al menos un medicamento');
      return;
    }
    setState(() => _saving = true);
    final session = UserSession.instance;
    try {
      final body = {
        'patientId': _patient!.id,
        'medico': session.nombre,
        'medicoId': session.dni,
        'especialidad': session.area,
        'observaciones': _obsCtrl.text.trim(),
        'fecha': DateTime.now().toIso8601String(),
        'items': _items
            .where((m) => m['medicamento']!.text.trim().isNotEmpty)
            .map((m) => {
                  'medicamento': m['medicamento']!.text.trim(),
                  'dosis': m['dosis']!.text.trim(),
                  'frecuencia': m['frecuencia']!.text.trim(),
                  'duracion': m['duracion']!.text.trim(),
                  'cantidad': int.tryParse(m['cantidad']!.text) ?? 1,
                })
            .toList(),
      };
      await PrescriptionService.create(body);
      if (mounted) {
        showSuccess(context, 'Receta creada correctamente');
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
    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 680, maxHeight: 640),
        child: Column(
          children: [
            // ── Header ───────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
              decoration: const BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.medication_outlined, color: Colors.white),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text('Nueva Receta Médica',
                        style: TextStyle(color: Colors.white,
                            fontSize: 18, fontWeight: FontWeight.w800)),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context, false),
                    icon: const Icon(Icons.close, color: Colors.white),
                  ),
                ],
              ),
            ),
            // ── Body ─────────────────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Paciente
                    const Text('Paciente *',
                        style: TextStyle(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _patientSearchCtrl,
                      decoration: InputDecoration(
                        prefixIcon: _searchingPatient
                            ? const Padding(padding: EdgeInsets.all(12),
                                child: SizedBox(width: 18, height: 18,
                                    child: CircularProgressIndicator(strokeWidth: 2)))
                            : const Icon(Icons.search),
                        hintText: 'Buscar paciente por nombre o DNI',
                        border: const OutlineInputBorder(), isDense: true,
                      ),
                      onChanged: (v) {
                        if (_patient != null) setState(() => _patient = null);
                        Future.delayed(const Duration(milliseconds: 400), () {
                          if (_patientSearchCtrl.text == v) _searchPatients(v);
                        });
                      },
                    ),
                    if (_patientResults.isNotEmpty)
                      Container(
                        margin: const EdgeInsets.only(top: 6),
                        constraints: const BoxConstraints(maxHeight: 160),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: AppColors.line),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: _patientResults.length,
                          itemBuilder: (_, i) {
                            final p = _patientResults[i];
                            return ListTile(
                              dense: true,
                              leading: Avatar(p.initials),
                              title: Text(p.nombreCompleto,
                                  style: const TextStyle(fontWeight: FontWeight.w700)),
                              subtitle: Text('DNI: ${p.dni}'),
                              onTap: () => setState(() {
                                _patient = p;
                                _patientSearchCtrl.text = p.nombreCompleto;
                                _patientResults = [];
                              }),
                            );
                          },
                        ),
                      ),
                    if (_patient != null) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE3EDF9),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          '✓ ${_patient!.nombreCompleto}',
                          style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w800),
                        ),
                      ),
                    ],
                    const SizedBox(height: 20),
                    // Medicamentos
                    Row(
                      children: [
                        const Text('Medicamentos',
                            style: TextStyle(fontWeight: FontWeight.w700)),
                        const Spacer(),
                        TextButton.icon(
                          onPressed: _addItem,
                          icon: const Icon(Icons.add, size: 18),
                          label: const Text('+ Agregar medicamento'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    for (int i = 0; i < _items.length; i++) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(bottom: 10),
                        decoration: BoxDecoration(
                          color: AppColors.bg,
                          border: Border.all(color: AppColors.line),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text('Medicamento ${i + 1}',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 13)),
                                ),
                                if (_items.length > 1)
                                  IconButton(
                                    icon: const Icon(Icons.remove_circle_outline,
                                        color: AppColors.red, size: 18),
                                    onPressed: () {
                                      _items[i].values.forEach((c) => c.dispose());
                                      setState(() => _items.removeAt(i));
                                    },
                                  ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 10,
                              runSpacing: 10,
                              children: [
                                _MedField('Medicamento *', _items[i]['medicamento']!, minW: 200),
                                _MedField('Dosis', _items[i]['dosis']!, minW: 100),
                                _MedField('Frecuencia', _items[i]['frecuencia']!, minW: 120),
                                _MedField('Duración', _items[i]['duracion']!, minW: 100),
                                _MedField('Cantidad', _items[i]['cantidad']!,
                                    minW: 80,
                                    keyboardType: TextInputType.number),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _obsCtrl,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        labelText: 'Observaciones',
                        border: OutlineInputBorder(), isDense: true,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // ── Footer ───────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              decoration: const BoxDecoration(
                  border: Border(top: BorderSide(color: AppColors.line))),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: _saving ? null : () => Navigator.pop(context, false),
                    child: const Text('Cancelar'),
                  ),
                  const SizedBox(width: 12),
                  FilledButton.icon(
                    onPressed: _saving ? null : _save,
                    icon: _saving
                        ? const SizedBox(width: 16, height: 16,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white))
                        : const Icon(Icons.check),
                    label: const Text('Crear receta'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MedField extends StatelessWidget {
  const _MedField(this.label, this.controller,
      {this.minW = 140, this.keyboardType});
  final String label;
  final TextEditingController controller;
  final double minW;
  final TextInputType? keyboardType;
  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(minWidth: minW, maxWidth: minW + 80),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          isDense: true,
          filled: true,
          fillColor: Colors.white,
        ),
      ),
    );
  }
}
