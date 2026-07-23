import 'package:flutter/material.dart';
import '../core/models.dart';
import '../core/services.dart';
import '../core/app_state_widgets.dart';
import '../widgets/common_widgets.dart';
import 'clinical_history_detail_view.dart';

class ClinicalHistoryPage extends StatefulWidget {
  const ClinicalHistoryPage({super.key});

  @override
  State<ClinicalHistoryPage> createState() => _ClinicalHistoryPageState();
}

class _ClinicalHistoryPageState extends State<ClinicalHistoryPage> {
  final _searchCtrl = TextEditingController();
  List<Patient> _patients = [];
  Patient? _selectedPatient;
  List<ClinicalHistory> _histories = [];
  bool _loadingSearch = false;
  bool _loadingHistories = false;
  Object? _error;

  @override
  void initState() {
    super.initState();
    // Carga inicial de historias recientes de todo el sistema
    _loadGlobalRecent();
  }

  Future<void> _loadGlobalRecent() async {
    setState(() {
      _loadingHistories = true;
      _error = null;
      _selectedPatient = null;
    });
    try {
      final r = await ClinicalHistoryService.getAll();
      if (mounted) setState(() { _histories = r; _loadingHistories = false; });
    } catch (e) {
      if (mounted) setState(() { _error = e; _loadingHistories = false; });
    }
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _searchPatients(String q) async {
    if (q.trim().isEmpty) {
      setState(() { _patients = []; });
      return;
    }
    setState(() => _loadingSearch = true);
    try {
      final r = await PatientService.getAll(search: q.trim());
      if (mounted) setState(() { _patients = r; _loadingSearch = false; });
    } catch (e) {
      if (mounted) setState(() { _loadingSearch = false; });
    }
  }

  Future<void> _loadHistories(Patient p) async {
    setState(() {
      _selectedPatient = p;
      _patients = [];
      _searchCtrl.text = p.nombreCompleto;
      _loadingHistories = true;
      _error = null;
    });
    try {
      final r = await ClinicalHistoryService.getByPatient(p.id);
      if (mounted) setState(() { _histories = r; _loadingHistories = false; });
    } catch (e) {
      if (mounted) setState(() { _error = e; _loadingHistories = false; });
    }
  }

  Future<void> _signHistory(ClinicalHistory h) async {
    try {
      await ClinicalHistoryService.sign(h.id);
      if (mounted) {
        showSuccess(context, 'Historia firmada correctamente');
        await _loadHistories(_selectedPatient!);
      }
    } catch (e) {
      if (mounted) showError(context, e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppHeader(
          title: 'Historia Clínica',
          subtitle: _selectedPatient == null
              ? 'Atenciones recientes en el sistema'
              : '${_selectedPatient!.nombreCompleto} · HC ${_selectedPatient!.numeroHc}',
          actions: [
            if (_selectedPatient != null)
              FilledButton.icon(
                onPressed: () {
                  setState(() { _searchCtrl.clear(); });
                  _loadGlobalRecent();
                },
                icon: const Icon(Icons.close),
                label: const Text('Ver todas'),
              ),
          ],
        ),
        PageBody(
          child: Column(
            children: [
              // ── Buscador ────────────────────────────────────────────────
              Panel(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Buscar paciente',
                        style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                    const SizedBox(height: 10),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 360),
                      child: TextField(
                        controller: _searchCtrl,
                        decoration: InputDecoration(
                          prefixIcon: _loadingSearch
                              ? const Padding(
                                  padding: EdgeInsets.all(12),
                                  child: SizedBox(width: 18, height: 18,
                                      child: CircularProgressIndicator(strokeWidth: 2)))
                              : const Icon(Icons.search),
                          hintText: 'Nombre o DNI del paciente',
                          filled: true, fillColor: AppColors.bg, isDense: true,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none),
                          suffixIcon: _searchCtrl.text.isNotEmpty
                              ? IconButton(icon: const Icon(Icons.clear),
                                  onPressed: () {
                                    _searchCtrl.clear();
                                    setState(() { _patients = []; });
                                  })
                              : null,
                        ),
                        onChanged: (v) {
                          Future.delayed(const Duration(milliseconds: 400), () {
                            if (_searchCtrl.text == v) _searchPatients(v);
                          });
                        },
                      ),
                    ),
                    if (_patients.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Container(
                        constraints: const BoxConstraints(maxWidth: 360, maxHeight: 200),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: AppColors.line),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: _patients.length,
                          itemBuilder: (_, i) {
                            final p = _patients[i];
                            return ListTile(
                              dense: true,
                              leading: Avatar(p.initials),
                              title: Text(p.nombreCompleto,
                                  style: const TextStyle(fontWeight: FontWeight.w700)),
                              subtitle: Text('DNI: ${p.dni} · ${p.numeroHc}'),
                              onTap: () => _loadHistories(p),
                            );
                          },
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 14),
              // ── Lista de historias ───────────────────────────────────────
              if (_loadingHistories)
                const LoadingState(message: 'Cargando historias clínicas...')
              else if (_error != null)
                ErrorState(error: _error!, onRetry: () => _selectedPatient != null ? _loadHistories(_selectedPatient!) : _loadGlobalRecent())
              else if (_histories.isEmpty)
                const EmptyState(
                  message: 'No hay historias clínicas registradas',
                  icon: Icons.folder_open_outlined,
                )
              else
                Panel(
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: [
                      for (final h in _histories) ...[
                        _HistoryTile(
                          history: h,
                          isExpanded: false, // Force collapse for now
                          onTap: () {
                            // Si no hay paciente seleccionado (vista global), buscamos el paciente de la historia
                            if (_selectedPatient == null) {
                              _navigateToDetailFromGlobal(context, h);
                            } else {
                              Navigator.of(context).push(MaterialPageRoute(
                                builder: (_) => ClinicalHistoryDetailView(
                                  patient: _selectedPatient!,
                                  history: h,
                                  onBack: () => Navigator.of(context).pop(),
                                ),
                              ));
                            }
                          },
                          onSign: h.estado.toUpperCase() == 'COMPLETADA'
                              ? () => _signHistory(h)
                              : null,
                        ),
                      ],
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _navigateToDetailFromGlobal(BuildContext context, ClinicalHistory h) async {
    showDialog(context: context, builder: (_) => const Center(child: CircularProgressIndicator()));
    try {
      final p = await PatientService.getById(h.patientId);
      if (context.mounted) {
        Navigator.of(context).pop(); // Quitar loading
        Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => ClinicalHistoryDetailView(
            patient: p,
            history: h,
            onBack: () => Navigator.of(context).pop(),
          ),
        ));
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context).pop();
        showError(context, 'No se pudo cargar el detalle del paciente');
      }
    }
  }
}

class _HistoryTile extends StatelessWidget {
  const _HistoryTile({
    required this.history,
    required this.isExpanded,
    required this.onTap,
    this.onSign,
  });
  final ClinicalHistory history;
  final bool isExpanded;
  final VoidCallback onTap;
  final VoidCallback? onSign;

  Color get _statusColor {
    switch (history.estado.toUpperCase()) {
      case 'FIRMADA': return AppColors.green;
      case 'COMPLETADA': return AppColors.blue;
      default: return AppColors.orange;
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
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(history.fechaAtencion.length >= 10
                          ? history.fechaAtencion.substring(0, 10) : history.fechaAtencion,
                          style: const TextStyle(color: AppColors.muted, fontSize: 13)),
                      const SizedBox(height: 2),
                      Text(history.especialidad,
                          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                      Text(history.medico,
                          style: const TextStyle(color: AppColors.muted, fontSize: 13)),
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
                    history.estado,
                    style: TextStyle(color: _statusColor, fontWeight: FontWeight.w700, fontSize: 12),
                  ),
                ),
                const SizedBox(width: 8),
                if (onSign != null)
                  Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: FilledButton.icon(
                      onPressed: onSign,
                      style: FilledButton.styleFrom(backgroundColor: AppColors.green,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
                      icon: const Icon(Icons.draw_outlined, size: 16),
                      label: const Text('Firmar', style: TextStyle(fontSize: 13)),
                    ),
                  ),
                Icon(isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: AppColors.muted),
              ],
            ),
          ),
        ),
        if (isExpanded)
          Container(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            color: const Color(0xFFF7FAFE),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Divider(height: 1),
                const SizedBox(height: 14),
                if (history.motivoConsulta?.isNotEmpty == true) ...[
                  _DetailItem('MOTIVO DE CONSULTA', history.motivoConsulta!),
                  const SizedBox(height: 10),
                ],
                if (history.enfermedadActual?.isNotEmpty == true) ...[
                  _DetailItem('ENFERMEDAD ACTUAL', history.enfermedadActual!),
                  const SizedBox(height: 10),
                ],
                if (history.observaciones?.isNotEmpty == true) ...[
                  _DetailItem('OBSERVACIONES', history.observaciones!),
                  const SizedBox(height: 10),
                ],
                if (history.planTratamiento?.isNotEmpty == true) ...[
                  _DetailItem('PLAN DE TRATAMIENTO', history.planTratamiento!),
                  const SizedBox(height: 10),
                ],
                if (history.diagnosticos.isNotEmpty) ...[
                  const Text('DIAGNÓSTICOS', style: TextStyle(
                      color: AppColors.muted, fontWeight: FontWeight.w800, fontSize: 12)),
                  const SizedBox(height: 8),
                  for (final d in history.diagnosticos)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: DiagnosisRow(d.codigoCie10, d.descripcion, '', d.tipo),
                    ),
                ],
              ],
            ),
          ),
        const Divider(height: 1, color: AppColors.line),
      ],
    );
  }
}

class _DetailItem extends StatelessWidget {
  const _DetailItem(this.label, this.value);
  final String label;
  final String value;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(
            color: AppColors.muted, fontWeight: FontWeight.w800, fontSize: 12)),
        const SizedBox(height: 4),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: AppColors.line),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(value, style: const TextStyle(fontSize: 15)),
        ),
      ],
    );
  }
}

class PatientProfileCard extends StatelessWidget {
  const PatientProfileCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Panel(
      child: Column(
        children: [
          const CircleAvatar(
            radius: 48,
            backgroundColor: Color(0xFFE3EDF9),
            child: Text(
              'RV',
              style: TextStyle(
                fontSize: 30,
                color: Color(0xFF0B55A1),
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            'Rosa Villanueva Quispe',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
          ),
          const Text(
            'DNI: 45782310',
            style: TextStyle(color: AppColors.muted, fontSize: 16),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFE8EC),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text('Femenino', style: TextStyle(color: Colors.red, fontWeight: FontWeight.w700, fontSize: 12)),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: .12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text('34 años', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFE5F5EC),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text('SIS', style: TextStyle(color: AppColors.green, fontWeight: FontWeight.w700, fontSize: 12)),
              ),
            ],
          ),
          const Divider(height: 34),
          const Text('N° HC', style: TextStyle(color: AppColors.muted)),
          const Text(
            'HC-2024-04521',
            style: TextStyle(
              fontSize: 22,
              color: AppColors.text,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class AlertCard extends StatelessWidget {
  const AlertCard({super.key});

  @override
  Widget build(BuildContext context) {
    return const Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionTitle(Icons.monitor_heart_outlined, 'Alertas'),
          Text(
            'Alergia penicilina',
            style: TextStyle(color: AppColors.red, fontSize: 16),
          ),
          Divider(),
          Text('HTA controlada', style: TextStyle(fontSize: 16)),
        ],
      ),
    );
  }
}

class ContactCard extends StatelessWidget {
  const ContactCard({super.key});

  @override
  Widget build(BuildContext context) {
    return const Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionTitle(Icons.phone_outlined, 'Contacto'),
          _InfoPair('Celular', '987-654-321'),
          _InfoPair('Distrito', 'Juliaca'),
          _InfoPair('Asegurado', 'SIS'),
        ],
      ),
    );
  }
}

class _InfoPair extends StatelessWidget {
  const _InfoPair(this.label, this.value);
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Expanded(
            child: Text(label, style: const TextStyle(color: AppColors.muted)),
          ),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}

class HistoryDetail extends StatelessWidget {
  const HistoryDetail({super.key});

  @override
  Widget build(BuildContext context) {
    return Panel(
      child: Column(
        children: [
          Wrap(
            spacing: 0,
            runSpacing: 0,
            children: const [
              _TabLabel(Icons.person_outline, 'Datos', true),
              _TabLabel(Icons.history, 'Antecedentes', false),
              _TabLabel(Icons.medical_services_outlined, 'Diagnósticos', false),
              _TabLabel(Icons.medication_outlined, 'Tratamientos', false),
              _TabLabel(Icons.show_chart, 'Evolución', false),
              _TabLabel(Icons.receipt_long_outlined, 'Recetas', false),
            ],
          ),
          const SizedBox(height: 22),
          const SectionTitle(Icons.account_circle_outlined, 'Datos generales'),
          const Wrap(
            spacing: 18,
            runSpacing: 18,
            children: [
              InfoBox('NOMBRE COMPLETO', 'Rosa Villanueva\nQuispe'),
              InfoBox('FECHA DE NACIMIENTO', '15/03/1992'),
              InfoBox('EDAD', '34 años'),
              InfoBox('SEXO', 'Femenino'),
              InfoBox('ESTADO CIVIL', 'Casada'),
              InfoBox('OCUPACIÓN', 'Agricultora'),
              InfoBox('DIRECCIÓN', 'Jr. Tahuantinsuyo\n245, Juliaca'),
              InfoBox('SEGURO', 'SIS — Activo'),
              InfoBox('GRUPO SANGUÍNEO', 'O+'),
            ],
          ),
          const SizedBox(height: 24),
          const SectionTitle(Icons.settings_outlined, 'Diagnósticos activos'),
          const DiagnosisRow(
            'I10',
            'Hipertensión esencial (primaria)',
            'Desde 2022',
            'Principal',
          ),
          const SizedBox(height: 10),
          const DiagnosisRow(
            'E11.9',
            'Diabetes mellitus tipo 2 sin complicaciones',
            'Desde 2023',
            'Secundario',
          ),
          const SizedBox(height: 24),
          const SectionTitle(Icons.receipt_long_outlined, 'Última receta'),
          Wrap(
            spacing: 14,
            runSpacing: 14,
            children: const [
              MedicineBox(
                'Metformina 850mg',
                '1 tableta c/12h con alimentos · 30 días',
                '850mg',
              ),
              MedicineBox(
                'Enalapril 10mg',
                '1 tableta c/24h en ayunas · 30 días',
                '10mg',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TabLabel extends StatelessWidget {
  const _TabLabel(this.icon, this.text, this.selected);
  final IconData icon;
  final String text;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      color: selected ? AppColors.primary : Colors.white,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: selected ? Colors.white : AppColors.muted),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              color: selected ? Colors.white : AppColors.muted,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
