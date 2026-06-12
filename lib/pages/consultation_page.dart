import 'package:flutter/material.dart';
import '../core/models.dart';
import '../core/services.dart';
import '../core/user_session.dart';
import '../core/app_state_widgets.dart';
import '../widgets/common_widgets.dart';

class ConsultationPage extends StatefulWidget {
  const ConsultationPage({super.key, this.preselectedPatient});
  final Patient? preselectedPatient;

  @override
  State<ConsultationPage> createState() => _ConsultationPageState();
}

class _ConsultationPageState extends State<ConsultationPage> {
  final _formKey = GlobalKey<FormState>();
  bool _saving = false;
  bool _searchingPatient = false;

  // Patient
  Patient? _patient;
  final _patientSearchCtrl = TextEditingController();
  List<Patient> _patientResults = [];

  // SOAP fields
  final _motivoCtrl = TextEditingController();
  final _enfermedadCtrl = TextEditingController();
  final _obsCtrl = TextEditingController();
  final _planCtrl = TextEditingController();

  // Vital signs
  final _sistolicaCtrl = TextEditingController();
  final _diastolicaCtrl = TextEditingController();
  final _fcCtrl = TextEditingController();
  final _tempCtrl = TextEditingController();
  final _satO2Ctrl = TextEditingController();
  final _pesoCtrl = TextEditingController();
  final _tallaCtrl = TextEditingController();

  // Diagnoses
  final List<Map<String, String>> _diagnoses = [];
  final _dxCodeCtrl = TextEditingController();
  final _dxDescCtrl = TextEditingController();
  String _dxTipo = 'PRINCIPAL';

  @override
  void initState() {
    super.initState();
    if (widget.preselectedPatient != null) {
      _patient = widget.preselectedPatient;
      _patientSearchCtrl.text = _patient!.nombreCompleto;
    }
  }

  @override
  void dispose() {
    for (final c in [
      _patientSearchCtrl, _motivoCtrl, _enfermedadCtrl, _obsCtrl, _planCtrl,
      _sistolicaCtrl, _diastolicaCtrl, _fcCtrl, _tempCtrl, _satO2Ctrl,
      _pesoCtrl, _tallaCtrl, _dxCodeCtrl, _dxDescCtrl,
    ]) c.dispose();
    super.dispose();
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

  Map<String, dynamic> _buildBody(String estado) {
    final session = UserSession.instance;
    return {
      'patientId': _patient!.id,
      'medicoId': session.dni,
      'medico': session.nombre,
      'especialidad': session.area,
      'motivoConsulta': _motivoCtrl.text.trim(),
      'enfermedadActual': _enfermedadCtrl.text.trim(),
      'observaciones': _obsCtrl.text.trim(),
      'planTratamiento': _planCtrl.text.trim(),
      'estado': estado,
      'fecha': DateTime.now().toIso8601String(),
      'signosVitales': {
        if (_sistolicaCtrl.text.isNotEmpty)
          'presionSistolica': int.tryParse(_sistolicaCtrl.text),
        if (_diastolicaCtrl.text.isNotEmpty)
          'presionDiastolica': int.tryParse(_diastolicaCtrl.text),
        if (_fcCtrl.text.isNotEmpty)
          'frecuenciaCardiaca': int.tryParse(_fcCtrl.text),
        if (_tempCtrl.text.isNotEmpty)
          'temperatura': double.tryParse(_tempCtrl.text),
        if (_satO2Ctrl.text.isNotEmpty)
          'saturacionOxigeno': int.tryParse(_satO2Ctrl.text),
        if (_pesoCtrl.text.isNotEmpty)
          'peso': double.tryParse(_pesoCtrl.text),
        if (_tallaCtrl.text.isNotEmpty)
          'talla': double.tryParse(_tallaCtrl.text),
      },
      'diagnosticos': _diagnoses,
    };
  }

  Future<void> _save(String estado) async {
    if (_patient == null) {
      showError(context, 'Selecciona un paciente primero');
      return;
    }
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      final hc = await ClinicalHistoryService.create(_buildBody(estado));
      if (estado == 'FIRMADA') {
        await ClinicalHistoryService.sign(hc.id);
      }
      if (mounted) {
        showSuccess(context,
            estado == 'FIRMADA' ? 'Historia firmada correctamente' : 'Borrador guardado');
        _clearForm();
      }
    } catch (e) {
      if (mounted) showError(context, e);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _clearForm() {
    _formKey.currentState?.reset();
    for (final c in [
      _motivoCtrl, _enfermedadCtrl, _obsCtrl, _planCtrl,
      _sistolicaCtrl, _diastolicaCtrl, _fcCtrl, _tempCtrl,
      _satO2Ctrl, _pesoCtrl, _tallaCtrl,
    ]) c.clear();
    setState(() => _diagnoses.clear());
  }

  void _addDiagnosis() {
    if (_dxCodeCtrl.text.trim().isEmpty || _dxDescCtrl.text.trim().isEmpty) return;
    setState(() {
      _diagnoses.add({
        'codigoCie10': _dxCodeCtrl.text.trim(),
        'descripcion': _dxDescCtrl.text.trim(),
        'tipo': _dxTipo,
      });
      _dxCodeCtrl.clear();
      _dxDescCtrl.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final session = UserSession.instance;
    return Column(
      children: [
        AppHeader(
          title: 'Nueva Consulta Médica',
          subtitle: _patient != null
              ? '${_patient!.nombreCompleto} · DNI ${_patient!.dni} · ${_patient!.numeroHc}'
              : 'Formulario SOAP — ${session.nombre}',
          actions: [
            OutlinedButton.icon(
              onPressed: _saving ? null : () => _save('BORRADOR'),
              icon: _saving
                  ? const SizedBox(width: 16, height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.save_outlined),
              label: const Text('Guardar borrador'),
            ),
            FilledButton.icon(
              onPressed: _saving ? null : () => _save('FIRMADA'),
              icon: const Icon(Icons.draw_outlined),
              label: const Text('Firmar HC'),
            ),
          ],
        ),
        PageBody(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // ── Selector de paciente ────────────────────────────────
                Panel(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SectionTitle(Icons.person_search_outlined, 'Paciente'),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 400),
                        child: TextField(
                          controller: _patientSearchCtrl,
                          decoration: InputDecoration(
                            prefixIcon: _searchingPatient
                                ? const Padding(padding: EdgeInsets.all(12),
                                    child: SizedBox(width: 18, height: 18,
                                        child: CircularProgressIndicator(strokeWidth: 2)))
                                : const Icon(Icons.search),
                            hintText: 'Buscar paciente por nombre o DNI',
                            filled: true, fillColor: AppColors.bg, isDense: true,
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide.none),
                          ),
                          onChanged: (v) {
                            if (_patient != null) setState(() => _patient = null);
                            Future.delayed(const Duration(milliseconds: 400), () {
                              if (_patientSearchCtrl.text == v) _searchPatients(v);
                            });
                          },
                        ),
                      ),
                      if (_patientResults.isNotEmpty)
                        Container(
                          margin: const EdgeInsets.only(top: 8),
                          constraints: const BoxConstraints(maxWidth: 400, maxHeight: 180),
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
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE5F5EC),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '✓ ${_patient!.nombreCompleto} · HC ${_patient!.numeroHc}',
                            style: const TextStyle(color: AppColors.green, fontWeight: FontWeight.w700, fontSize: 12),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // ── Signos vitales ──────────────────────────────────────
                Panel(
                  child: Column(
                    children: [
                      const SectionTitle(Icons.monitor_heart_outlined, 'Signos vitales'),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          _VitalField('P. Sistólica', _sistolicaCtrl, 'mmHg'),
                          _VitalField('P. Diastólica', _diastolicaCtrl, 'mmHg'),
                          _VitalField('Frec. Cardiaca', _fcCtrl, 'lpm'),
                          _VitalField('Temperatura', _tempCtrl, '°C'),
                          _VitalField('Sat. O₂', _satO2Ctrl, '%'),
                          _VitalField('Peso', _pesoCtrl, 'kg'),
                          _VitalField('Talla', _tallaCtrl, 'cm'),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // ── Anamnesis ───────────────────────────────────────────
                Panel(
                  child: Column(
                    children: [
                      const SectionTitle(Icons.assignment_outlined, 'Anamnesis'),
                      _SoapField('Motivo de consulta *', _motivoCtrl,
                          validator: (v) => (v?.trim().isEmpty ?? true) ? 'Requerido' : null),
                      const SizedBox(height: 14),
                      _SoapField('Enfermedad actual', _enfermedadCtrl),
                      const SizedBox(height: 14),
                      _SoapField('Observaciones', _obsCtrl),
                      const SizedBox(height: 14),
                      _SoapField('Plan de tratamiento', _planCtrl),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // ── Diagnósticos ────────────────────────────────────────
                Panel(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SectionTitle(Icons.settings_outlined, 'Diagnóstico CIE-10'),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        crossAxisAlignment: WrapCrossAlignment.end,
                        children: [
                          ConstrainedBox(
                            constraints: const BoxConstraints(minWidth: 120, maxWidth: 140),
                            child: TextField(
                              controller: _dxCodeCtrl,
                              decoration: const InputDecoration(
                                labelText: 'Código CIE-10',
                                border: OutlineInputBorder(), isDense: true,
                              ),
                            ),
                          ),
                          ConstrainedBox(
                            constraints: const BoxConstraints(minWidth: 200, maxWidth: 340),
                            child: TextField(
                              controller: _dxDescCtrl,
                              decoration: const InputDecoration(
                                labelText: 'Descripción',
                                border: OutlineInputBorder(), isDense: true,
                              ),
                            ),
                          ),
                          ConstrainedBox(
                            constraints: const BoxConstraints(minWidth: 160, maxWidth: 200),
                            child: DropdownButtonFormField<String>(
                              value: _dxTipo,
                              decoration: const InputDecoration(
                                labelText: 'Tipo', border: OutlineInputBorder(), isDense: true),
                              items: const [
                                DropdownMenuItem(value: 'PRINCIPAL', child: Text('Principal')),
                                DropdownMenuItem(value: 'SECUNDARIO', child: Text('Secundario')),
                                DropdownMenuItem(value: 'PRESUNTIVO', child: Text('Presuntivo')),
                                DropdownMenuItem(value: 'DEFINITIVO', child: Text('Definitivo')),
                              ],
                              onChanged: (v) => setState(() => _dxTipo = v ?? 'PRINCIPAL'),
                            ),
                          ),
                          FilledButton.icon(
                            onPressed: _addDiagnosis,
                            icon: const Icon(Icons.add, size: 18),
                            label: const Text('Agregar'),
                          ),
                        ],
                      ),
                      if (_diagnoses.isNotEmpty) ...[
                        const SizedBox(height: 14),
                        for (int i = 0; i < _diagnoses.length; i++)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              children: [
                                Expanded(
                                  child: DiagnosisRow(
                                    _diagnoses[i]['codigoCie10']!,
                                    _diagnoses[i]['descripcion']!,
                                    '',
                                    _diagnoses[i]['tipo']!,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline,
                                      color: AppColors.red, size: 18),
                                  onPressed: () => setState(() => _diagnoses.removeAt(i)),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _VitalField extends StatelessWidget {
  const _VitalField(this.label, this.controller, this.unit);
  final String label;
  final TextEditingController controller;
  final String unit;
  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 110, maxWidth: 150),
      child: TextField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: InputDecoration(
          labelText: label,
          suffixText: unit,
          border: const OutlineInputBorder(),
          isDense: true,
        ),
      ),
    );
  }
}

class _SoapField extends StatelessWidget {
  const _SoapField(this.label, this.controller, {this.validator});
  final String label;
  final TextEditingController controller;
  final String? Function(String?)? validator;
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: validator,
      maxLines: 3,
      decoration: InputDecoration(
        labelText: label,
        alignLabelWithHint: true,
        border: const OutlineInputBorder(),
        isDense: true,
      ),
    );
  }
}
