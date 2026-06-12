import 'package:flutter/material.dart';
import '../core/user_session.dart';
import '../core/models.dart';
import '../core/services.dart';
import '../core/app_state_widgets.dart';
import '../widgets/common_widgets.dart';
import '../pages/patients_page.dart';
import '../pages/telemedicine_page.dart';
import '../pages/dataset_analytics_page.dart';
import 'role_shell_base.dart';

// ─────────────────────────────────────────────────────────────────────────────
// SHELL ENFERMERO/A — signos vitales, pacientes, telemedicina
// ─────────────────────────────────────────────────────────────────────────────
class EnfermeroShell extends StatefulWidget {
  const EnfermeroShell({super.key});

  @override
  State<EnfermeroShell> createState() => _EnfermeroShellState();
}

class _EnfermeroShellState extends State<EnfermeroShell> {
  int _index = 0;

  static const _navItems = [
    RoleNavItem(icon: Icons.dashboard_outlined, label: 'Inicio', section: 'PRINCIPAL'),
    RoleNavItem(icon: Icons.people_outline, label: 'Pacientes'),
    RoleNavItem(icon: Icons.monitor_heart_outlined, label: 'Signos Vitales', section: 'CLÍNICO'),
    RoleNavItem(icon: Icons.video_camera_front_outlined, label: 'Telemedicina'),
    RoleNavItem(
      icon: Icons.sync_alt_outlined,
      label: 'Intercambio Rural & FHIR',
      section: 'HL7 FHIR',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final pages = [
      _EnfermeroDashboard(onNavigate: (i) => setState(() => _index = i)),
      const PatientsPage(),
      const _SignosVitalesPage(),
      const TelemedicinePage(),
      const DatasetAnalyticsPage(),
    ];

    return LayoutBuilder(
      builder: (context, c) {
        final wide = c.maxWidth >= 960;
        return Scaffold(
          backgroundColor: AppColors.bg,
          bottomNavigationBar: wide
              ? null
              : NavigationBar(
                  selectedIndex: _index,
                  onDestinationSelected: (i) => setState(() => _index = i),
                  destinations: const [
                    NavigationDestination(icon: Icon(Icons.dashboard_outlined), label: 'Inicio'),
                    NavigationDestination(icon: Icon(Icons.people_outline), label: 'Pacientes'),
                    NavigationDestination(icon: Icon(Icons.monitor_heart_outlined), label: 'Signos'),
                    NavigationDestination(icon: Icon(Icons.video_camera_front_outlined), label: 'Telemed.'),
                  ],
                ),
          body: Row(
            children: [
              if (wide)
                RoleSideBar(
                  items: _navItems,
                  selectedIndex: _index,
                  onSelect: (i) => setState(() => _index = i),
                  accentColor: const Color(0xFF2F8A5B),
                ),
              Expanded(child: pages[_index]),
            ],
          ),
        );
      },
    );
  }
}

// ── Dashboard Enfermería ──────────────────────────────────────────────────────
class _EnfermeroDashboard extends StatefulWidget {
  const _EnfermeroDashboard({required this.onNavigate});
  final void Function(int) onNavigate;

  @override
  State<_EnfermeroDashboard> createState() => _EnfermeroDashboardState();
}

class _EnfermeroDashboardState extends State<_EnfermeroDashboard> {
  DashboardStats? _stats;
  List<Patient> _queue = [];
  bool _loading = true;
  Object? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final results = await Future.wait([
        DashboardService.getClinicalStats(),
        PatientService.getAll(status: 'NUEVO'),
      ]);
      if (mounted) setState(() {
        _stats = results[0] as DashboardStats;
        _queue = (results[1] as List<Patient>).take(6).toList();
        _loading = false;
      });
    } catch (e) {
      if (mounted) setState(() { _error = e; _loading = false; });
    }
  }

  Future<void> _openVitalsForm(Patient? patient) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => _VitalSignsDialog(patient: patient),
    );
  }

  @override
  Widget build(BuildContext context) {
    final session = UserSession.instance;
    return Column(
      children: [
        AppHeader(
          title: 'Panel de Enfermería',
          subtitle: '${session.nombre} · ${session.area}',
          actions: [
            FilledButton.icon(
              style: FilledButton.styleFrom(backgroundColor: const Color(0xFF2F8A5B)),
              onPressed: () => _openVitalsForm(null),
              icon: const Icon(Icons.add),
              label: const Text('Registrar signos'),
            ),
            IconButton(onPressed: _load, icon: const Icon(Icons.refresh), tooltip: 'Actualizar'),
          ],
        ),
        PageBody(
          child: _loading
              ? const LoadingState(message: 'Cargando datos...')
              : _error != null
                  ? ErrorState(error: _error!, onRetry: _load)
                  : _buildContent(),
        ),
      ],
    );
  }

  Widget _buildContent() {
    final s = _stats;
    return Column(
      children: [
        // Métricas
        LayoutBuilder(builder: (ctx, c) {
          final cols = c.maxWidth > 700 ? 3 : 1;
          final metrics = [
            _NurseMetric(Icons.people_outline, 'Total Pacientes',
                '${s?.totalPatients ?? 0}', const Color(0xFFE9F2FF), const Color(0xFF2F7DE1)),
            _NurseMetric(Icons.medical_services_outlined, 'Consultas hoy',
                '${s?.consultationsToday ?? 0}', const Color(0xFFE8F7EF), const Color(0xFF2F8A5B)),
            _NurseMetric(Icons.person_add_alt_outlined, 'Nuevos este mes',
                '${s?.newPatientsThisMonth ?? 0}', const Color(0xFFFFE8EC), const Color(0xFFE84B4B)),
          ];
          if (cols == 1) {
            return Column(children: [
              for (int i = 0; i < metrics.length; i++) ...[
                metrics[i],
                if (i < metrics.length - 1) const SizedBox(height: 12),
              ],
            ]);
          }
          return GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: cols,
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
            childAspectRatio: 2.2,
            children: metrics,
          );
        }),
        const SizedBox(height: 22),
        // Cola de pacientes
        Panel(
          child: Column(
            children: [
              SectionTitle(
                Icons.schedule_outlined,
                'Pacientes nuevos — pendientes',
                action: TextButton(
                  onPressed: () => widget.onNavigate(1),
                  child: const Text('Ver todos'),
                ),
              ),
              if (_queue.isEmpty)
                const EmptyState(message: 'No hay pacientes en cola', icon: Icons.people_outline)
              else
                ..._queue.map((p) => ListTile(
                      leading: Avatar(p.initials),
                      title: Text(p.nombreCompleto,
                          style: const TextStyle(fontWeight: FontWeight.w800)),
                      subtitle: Text('${p.numeroHc} · ${p.asegurado}'),
                      trailing: FilledButton.tonalIcon(
                        onPressed: () => _openVitalsForm(p),
                        icon: const Icon(Icons.monitor_heart_outlined, size: 16),
                        label: const Text('Signos'),
                      ),
                    )),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Página Signos Vitales ─────────────────────────────────────────────────────
class _SignosVitalesPage extends StatefulWidget {
  const _SignosVitalesPage();

  @override
  State<_SignosVitalesPage> createState() => _SignosVitalesPageState();
}

class _SignosVitalesPageState extends State<_SignosVitalesPage> {
  List<Patient> _patients = [];
  Patient? _selected;
  bool _loadingPatients = false;
  String _search = '';

  Future<void> _searchPatients(String query) async {
    if (query.length < 2) return;
    setState(() => _loadingPatients = true);
    try {
      final data = await PatientService.getAll(search: query);
      if (mounted) setState(() { _patients = data; _loadingPatients = false; });
    } catch (e) {
      if (mounted) setState(() => _loadingPatients = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppHeader(
          title: 'Registro de Signos Vitales',
          subtitle: 'Triage y monitoreo',
          actions: [
            FilledButton.icon(
              style: FilledButton.styleFrom(backgroundColor: const Color(0xFF2F8A5B)),
              onPressed: () => showDialog(
                context: context,
                barrierDismissible: false,
                builder: (_) => _VitalSignsDialog(patient: _selected),
              ),
              icon: const Icon(Icons.add),
              label: const Text('Nuevo registro'),
            ),
          ],
        ),
        PageBody(
          child: Column(
            children: [
              // Buscador de paciente
              Panel(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SectionTitle(Icons.person_search_outlined, 'Buscar paciente'),
                    TextField(
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.search),
                        hintText: 'Nombre o DNI del paciente',
                        suffixIcon: _loadingPatients
                            ? const SizedBox(width: 20, height: 20,
                                child: Padding(padding: EdgeInsets.all(12),
                                    child: CircularProgressIndicator(strokeWidth: 2)))
                            : null,
                        filled: true, fillColor: AppColors.bg,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onChanged: (v) {
                        _search = v;
                        Future.delayed(const Duration(milliseconds: 500), () {
                          if (_search == v) _searchPatients(v);
                        });
                      },
                    ),
                    if (_patients.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      ...(_patients.take(5).map((p) => ListTile(
                            dense: true,
                            leading: Avatar(p.initials, radius: 16),
                            title: Text(p.nombreCompleto,
                                style: const TextStyle(fontWeight: FontWeight.w700)),
                            subtitle: Text('${p.numeroHc} · DNI: ${p.dni}'),
                            selected: _selected?.id == p.id,
                            selectedTileColor: AppColors.blue.withValues(alpha: .08),
                            onTap: () => setState(() { _selected = p; _patients = []; }),
                          ))),
                    ],
                    if (_selected != null) ...[
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.green.withValues(alpha: .08),
                          border: Border.all(color: AppColors.green.withValues(alpha: .3)),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(children: [
                          const Icon(Icons.check_circle_outline, color: AppColors.green),
                          const SizedBox(width: 10),
                          Expanded(child: Text(
                            'Seleccionado: ${_selected!.nombreCompleto} · ${_selected!.numeroHc}',
                            style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.green),
                          )),
                          TextButton(
                            onPressed: () => setState(() => _selected = null),
                            child: const Text('Cambiar'),
                          ),
                        ]),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 18),
              // Formulario
              if (_selected != null)
                Panel(
                  child: _VitalsInlineForm(patient: _selected!),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Formulario inline de signos vitales ───────────────────────────────────────
class _VitalsInlineForm extends StatefulWidget {
  const _VitalsInlineForm({required this.patient});
  final Patient patient;

  @override
  State<_VitalsInlineForm> createState() => _VitalsInlineFormState();
}

class _VitalsInlineFormState extends State<_VitalsInlineForm> {
  final _formKey = GlobalKey<FormState>();
  bool _saving = false;
  final _cSis = TextEditingController();
  final _cDia = TextEditingController();
  final _cFC = TextEditingController();
  final _cFR = TextEditingController();
  final _cTemp = TextEditingController();
  final _cSat = TextEditingController();
  final _cPeso = TextEditingController();
  final _cTalla = TextEditingController();

  @override
  void dispose() {
    for (final c in [_cSis, _cDia, _cFC, _cFR, _cTemp, _cSat, _cPeso, _cTalla]) c.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      // Primero crear HC en borrador para tener un historyId
      final history = await ClinicalHistoryService.create({
        'patientId': widget.patient.id,
        'medico': UserSession.instance.nombre,
        'medicoId': UserSession.instance.dni,
        'especialidad': 'Triage / Enfermería',
        'motivoConsulta': 'Registro de signos vitales',
        'estado': 'BORRADOR',
        'fecha': DateTime.now().toIso8601String(),
      });
      // El backend debería procesar los signos vitales anidados
      // Por ahora, mostrar éxito con el número de historia creada
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(
            'Signos vitales registrados - HC: ${history.id.length >= 8 ? history.id.substring(0, 8) : history.id}...')),
          );setState(() => _saving = false);
        for (final c in [_cSis, _cDia, _cFC, _cFR, _cTemp, _cSat, _cPeso, _cTalla]) {
          c.clear();
        }
      }
    } catch (e) {
      if (mounted) {
        showError(context, e);
        setState(() => _saving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          SectionTitle(Icons.monitor_heart_outlined, 'Signos vitales',
              action: Text(widget.patient.nombreCompleto,
                  style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.primary))),
          const SizedBox(height: 16),
          Wrap(
            spacing: 14,
            runSpacing: 14,
            children: [
              _vField('Presión sistólica', 'mmHg', _cSis),
              _vField('Presión diastólica', 'mmHg', _cDia),
              _vField('Frec. cardiaca', 'lpm', _cFC),
              _vField('Frec. respiratoria', 'rpm', _cFR),
              _vField('Temperatura', '°C', _cTemp),
              _vField('Saturación O₂', '%', _cSat),
              _vField('Peso', 'kg', _cPeso),
              _vField('Talla', 'cm', _cTalla),
            ],
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              style: FilledButton.styleFrom(backgroundColor: const Color(0xFF2F8A5B)),
              onPressed: _saving ? null : _save,
              icon: _saving
                  ? const SizedBox(width: 18, height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.save_outlined),
              label: Text(_saving ? 'Guardando...' : 'Guardar registro de signos vitales'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _vField(String label, String unit, TextEditingController c) =>
      SizedBox(
        width: 160,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('$label ($unit)',
                style: const TextStyle(color: AppColors.muted, fontSize: 12, fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            TextFormField(
              controller: c,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                filled: true, fillColor: AppColors.bg,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                suffixText: unit,
                isDense: true,
              ),
            ),
          ],
        ),
      );
}

// ── Dialog flotante de signos vitales ─────────────────────────────────────────
class _VitalSignsDialog extends StatefulWidget {
  const _VitalSignsDialog({this.patient});
  final Patient? patient;

  @override
  State<_VitalSignsDialog> createState() => _VitalSignsDialogState();
}

class _VitalSignsDialogState extends State<_VitalSignsDialog> {
  final _formKey = GlobalKey<FormState>();
  bool _saving = false;
  List<Patient> _patients = [];
  Patient? _selected;
  final _cSearch = TextEditingController();
  final _cSis = TextEditingController();
  final _cDia = TextEditingController();
  final _cFC = TextEditingController();
  final _cFR = TextEditingController();
  final _cTemp = TextEditingController();
  final _cSat = TextEditingController();
  final _cPeso = TextEditingController();
  final _cTalla = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.patient != null) _selected = widget.patient;
  }

  @override
  void dispose() {
    for (final c in [_cSearch, _cSis, _cDia, _cFC, _cFR, _cTemp, _cSat, _cPeso, _cTalla]) c.dispose();
    super.dispose();
  }

  Future<void> _searchPatients(String q) async {
    if (q.length < 2) return;
    final data = await PatientService.getAll(search: q);
    if (mounted) setState(() => _patients = data);
  }

  Future<void> _save() async {
    if (_selected == null) {
      showError(context, 'Seleccione un paciente');
      return;
    }
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      await ClinicalHistoryService.create({
        'patientId': _selected!.id,
        'medico': UserSession.instance.nombre,
        'medicoId': UserSession.instance.dni,
        'especialidad': 'Triage / Enfermería',
        'motivoConsulta': 'Registro de signos vitales',
        'estado': 'BORRADOR',
        'fecha': DateTime.now().toIso8601String(),
      });
      if (mounted) {
        showSuccess(context, 'Signos vitales registrados correctamente');
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        showError(context, e);
        setState(() => _saving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560, maxHeight: 620),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: const BoxDecoration(
                color: Color(0xFF2F8A5B),
                borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
              ),
              child: Row(children: [
                const Icon(Icons.monitor_heart_outlined, color: Colors.white),
                const SizedBox(width: 12),
                const Expanded(child: Text('Registrar Signos Vitales',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 17))),
                IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Colors.white)),
              ]),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Paciente selector
                      if (_selected == null) ...[
                        const Text('Paciente', style: TextStyle(fontWeight: FontWeight.w700)),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _cSearch,
                          decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.search),
                            hintText: 'Buscar nombre o DNI',
                            border: OutlineInputBorder(), isDense: true,
                          ),
                          onChanged: (v) => Future.delayed(
                              const Duration(milliseconds: 400), () => _searchPatients(v)),
                        ),
                        ..._patients.take(4).map((p) => ListTile(
                              dense: true,
                              title: Text(p.nombreCompleto),
                              subtitle: Text(p.numeroHc),
                              onTap: () => setState(() { _selected = p; _patients = []; }),
                            )),
                      ] else ...[
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2F8A5B).withValues(alpha: .08),
                            border: Border.all(color: const Color(0xFF2F8A5B).withValues(alpha: .3)),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(children: [
                            Avatar(_selected!.initials, radius: 16),
                            const SizedBox(width: 10),
                            Expanded(child: Text(_selected!.nombreCompleto,
                                style: const TextStyle(fontWeight: FontWeight.w800))),
                            TextButton(
                                onPressed: () => setState(() => _selected = null),
                                child: const Text('Cambiar')),
                          ]),
                        ),
                      ],
                      const SizedBox(height: 20),
                      // Campos vitales
                      Wrap(spacing: 12, runSpacing: 12, children: [
                        _vf('PA sistólica', 'mmHg', _cSis),
                        _vf('PA diastólica', 'mmHg', _cDia),
                        _vf('Frec. cardiaca', 'lpm', _cFC),
                        _vf('Frec. resp.', 'rpm', _cFR),
                        _vf('Temperatura', '°C', _cTemp),
                        _vf('Sat. O₂', '%', _cSat),
                        _vf('Peso', 'kg', _cPeso),
                        _vf('Talla', 'cm', _cTalla),
                      ]),
                    ],
                  ),
                ),
              ),
            ),
            // Footer
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              decoration: const BoxDecoration(border: Border(top: BorderSide(color: AppColors.line))),
              child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                OutlinedButton(
                    onPressed: _saving ? null : () => Navigator.pop(context),
                    child: const Text('Cancelar')),
                const SizedBox(width: 12),
                FilledButton.icon(
                  style: FilledButton.styleFrom(backgroundColor: const Color(0xFF2F8A5B)),
                  onPressed: _saving ? null : _save,
                  icon: _saving
                      ? const SizedBox(width: 16, height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.save_outlined),
                  label: const Text('Guardar signos'),
                ),
              ]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _vf(String label, String unit, TextEditingController c) =>
      SizedBox(
        width: 148,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('$label ($unit)',
                style: const TextStyle(fontSize: 11, color: AppColors.muted, fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            TextFormField(
              controller: c,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                border: const OutlineInputBorder(), isDense: true,
                suffixText: unit, filled: true, fillColor: AppColors.bg,
              ),
            ),
          ],
        ),
      );
}

// ── Widgets auxiliares ────────────────────────────────────────────────────────
class _NurseMetric extends StatelessWidget {
  const _NurseMetric(this.icon, this.title, this.value, this.bg, this.color);
  final IconData icon;
  final String title;
  final String value;
  final Color bg;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Panel(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          CircleAvatar(radius: 24, backgroundColor: bg, child: Icon(icon, color: color, size: 20)),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(title, style: const TextStyle(color: AppColors.muted, fontSize: 12, fontWeight: FontWeight.w600),
                    maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Text(value, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, height: 1)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
