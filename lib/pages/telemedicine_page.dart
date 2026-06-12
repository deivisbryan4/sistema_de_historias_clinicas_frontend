import 'package:flutter/material.dart';
import '../core/models.dart';
import '../core/services.dart';
import '../core/app_state_widgets.dart';
import '../widgets/common_widgets.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Telemedicine Page — sesiones conectadas al API
// ─────────────────────────────────────────────────────────────────────────────
class TelemedicinePage extends StatefulWidget {
  const TelemedicinePage({super.key});

  @override
  State<TelemedicinePage> createState() => _TelemedicinePageState();
}

class _TelemedicinePageState extends State<TelemedicinePage> {
  List<TelemedicineSession> _sessions = [];
  bool _loading = true;
  Object? _error;
  String? _statusFilter;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final data = await TelemedicineService.getAll(status: _statusFilter);
      if (mounted) setState(() { _sessions = data; _loading = false; });
    } catch (e) {
      if (mounted) setState(() { _error = e; _loading = false; });
    }
  }

  Future<void> _openNewSession() async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const _TeleFormDialog(),
    );
    if (result == true) _load();
  }

  Future<void> _updateStatus(TelemedicineSession s, String newStatus) async {
    try {
      await TelemedicineService.updateStatus(s.id, newStatus);
      showSuccess(context, 'Estado actualizado');
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
          title: 'Telemedicina',
          subtitle: 'Teleconsultas y sesiones virtuales',
          actions: [
            FilledButton.icon(
              onPressed: _openNewSession,
              icon: const Icon(Icons.video_call_outlined),
              label: const Text('Nueva sesión'),
            ),
          ],
        ),
        PageBody(
          child: Column(
            children: [
              // Filtros
              Panel(
                padding: const EdgeInsets.all(14),
                child: Wrap(
                  spacing: 12,
                  runSpacing: 10,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    const Text('Estado:',
                        style: TextStyle(color: AppColors.muted)),
                    for (final (label, val) in [
                      ('Todas', null),
                      ('Programadas', 'PROGRAMADA'),
                      ('En curso', 'EN_CURSO'),
                      ('Completadas', 'COMPLETADA'),
                    ])
                      _FilterChip(
                        label: label,
                        selected: _statusFilter == val,
                        onTap: () =>
                            setState(() { _statusFilter = val; _load(); }),
                      ),
                    IconButton(
                      onPressed: _load,
                      icon: const Icon(Icons.refresh),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              // Lista de sesiones
              Panel(
                child: _loading
                    ? const LoadingState(message: 'Cargando sesiones...')
                    : _error != null
                        ? ErrorState(error: _error!, onRetry: _load)
                        : _sessions.isEmpty
                            ? const EmptyState(
                                message: 'No hay sesiones de telemedicina',
                                icon: Icons.videocam_off_outlined,
                              )
                            : Column(
                                children: _sessions
                                    .map((s) => _SessionTile(
                                          session: s,
                                          onUpdateStatus: _updateStatus,
                                        ))
                                    .toList(),
                              ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Tile de sesión ────────────────────────────────────────────────────────────
class _SessionTile extends StatelessWidget {
  const _SessionTile({required this.session, required this.onUpdateStatus});
  final TelemedicineSession session;
  final Future<void> Function(TelemedicineSession, String) onUpdateStatus;

  @override
  Widget build(BuildContext context) {
    final estado = session.estado.toUpperCase();
    final (color, label) = switch (estado) {
      'PROGRAMADA' => (AppColors.blue, 'Programada'),
      'EN_CURSO' => (AppColors.green, 'En curso'),
      'COMPLETADA' => (AppColors.muted, 'Completada'),
      _ => (AppColors.red, 'Cancelada'),
    };

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.bg,
        border: Border.all(color: AppColors.line),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: color.withValues(alpha: .15),
            child: Icon(Icons.videocam_outlined, color: color),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(session.patientNombre,
                    style: const TextStyle(fontWeight: FontWeight.w800)),
                Text(
                    '${session.especialidad} · ${session.medico}',
                    style: const TextStyle(
                        color: AppColors.muted, fontSize: 13)),
                Text(session.fechaProgramada,
                    style: const TextStyle(
                        color: AppColors.muted, fontSize: 12)),
              ],
            ),
          ),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: color.withValues(alpha: .12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(label,
                style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w700,
                    fontSize: 12)),
          ),
          if (estado == 'PROGRAMADA') ...[
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.play_circle_outline,
                  color: AppColors.green),
              tooltip: 'Iniciar sesión',
              onPressed: () =>
                  onUpdateStatus(session, 'EN_CURSO'),
            ),
          ],
          if (estado == 'EN_CURSO') ...[
            const SizedBox(width: 8),
            if (session.enlace != null && session.enlace!.isNotEmpty)
              IconButton(
                icon: const Icon(Icons.open_in_new, color: AppColors.blue),
                tooltip: 'Unirse',
                onPressed: () {
                  // TODO: url_launcher cuando se agregue
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('Enlace: ${session.enlace}'),
                    behavior: SnackBarBehavior.floating,
                  ));
                },
              ),
            IconButton(
              icon: const Icon(Icons.check_circle_outline,
                  color: AppColors.green),
              tooltip: 'Completar',
              onPressed: () =>
                  onUpdateStatus(session, 'COMPLETADA'),
            ),
          ],
        ],
      ),
    );
  }
}

// ── Chip de filtro ────────────────────────────────────────────────────────────
class _FilterChip extends StatelessWidget {
  const _FilterChip(
      {required this.label, required this.selected, required this.onTap});
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : Colors.white,
          border: Border.all(
              color: selected ? AppColors.primary : AppColors.line),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(label,
            style: TextStyle(
                color: selected ? Colors.white : AppColors.muted,
                fontWeight: FontWeight.w600,
                fontSize: 13)),
      ),
    );
  }
}

// ── Formulario nueva sesión ───────────────────────────────────────────────────
class _TeleFormDialog extends StatefulWidget {
  const _TeleFormDialog();

  @override
  State<_TeleFormDialog> createState() => _TeleFormDialogState();
}

class _TeleFormDialogState extends State<_TeleFormDialog> {
  final _formKey = GlobalKey<FormState>();
  bool _saving = false;
  final _patientId = TextEditingController();
  final _motivo = TextEditingController();
  final _enlace = TextEditingController();
  String _especialidad = 'Medicina General';
  String _fecha = '';

  @override
  void dispose() {
    _patientId.dispose();
    _motivo.dispose();
    _enlace.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
    );
    if (picked != null) {
      setState(() => _fecha = picked.toIso8601String().split('T').first);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      await TelemedicineService.create({
        'patientId': _patientId.text.trim(),
        'especialidad': _especialidad,
        'fechaProgramada': _fecha,
        'motivoConsulta': _motivo.text.trim(),
        'enlace': _enlace.text.trim(),
        'estado': 'PROGRAMADA',
        'duracionMinutos': 30,
      });
      if (mounted) {
        showSuccess(context, 'Sesión programada correctamente');
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
        constraints: const BoxConstraints(maxWidth: 500),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
              decoration: const BoxDecoration(
                color: AppColors.primary,
                borderRadius:
                    BorderRadius.vertical(top: Radius.circular(12)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.video_call_outlined, color: Colors.white),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text('Nueva sesión de telemedicina',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.w800)),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context, false),
                    icon: const Icon(Icons.close, color: Colors.white),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _patientId,
                      decoration: const InputDecoration(
                        labelText: 'ID o N° HC del paciente *',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      validator: (v) => (v == null || v.isEmpty)
                          ? 'Campo requerido'
                          : null,
                    ),
                    const SizedBox(height: 14),
                    DropdownButtonFormField<String>(
                      value: _especialidad,
                      decoration: const InputDecoration(
                        labelText: 'Especialidad',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      items: const [
                        DropdownMenuItem(
                            value: 'Medicina General',
                            child: Text('Medicina General')),
                        DropdownMenuItem(
                            value: 'Pediatría',
                            child: Text('Pediatría')),
                        DropdownMenuItem(
                            value: 'Ginecología',
                            child: Text('Ginecología')),
                        DropdownMenuItem(
                            value: 'Cardiología',
                            child: Text('Cardiología')),
                      ],
                      onChanged: (v) =>
                          setState(() => _especialidad = v!),
                    ),
                    const SizedBox(height: 14),
                    InkWell(
                      onTap: _pickDate,
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Fecha programada *',
                          border: OutlineInputBorder(),
                          isDense: true,
                          suffixIcon: Icon(Icons.calendar_today_outlined),
                        ),
                        child: Text(
                          _fecha.isEmpty ? 'Seleccionar fecha' : _fecha,
                          style: TextStyle(
                            color: _fecha.isEmpty
                                ? AppColors.muted
                                : AppColors.text,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _enlace,
                      decoration: const InputDecoration(
                        labelText: 'Enlace de videollamada (Meet, Zoom...)',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _motivo,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        labelText: 'Motivo de consulta',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
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
                        : const Icon(Icons.save_outlined),
                    label: const Text('Programar sesión'),
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
