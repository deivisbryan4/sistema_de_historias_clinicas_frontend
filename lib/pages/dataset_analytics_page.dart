import 'package:flutter/material.dart';
import '../core/models.dart';
import '../core/services.dart';
import '../core/app_state_widgets.dart';
import '../widgets/common_widgets.dart';

class DatasetAnalyticsPage extends StatefulWidget {
  const DatasetAnalyticsPage({super.key});

  @override
  State<DatasetAnalyticsPage> createState() => _DatasetAnalyticsPageState();
}

class _DatasetAnalyticsPageState extends State<DatasetAnalyticsPage> {
  List<ClinicalHistory> _allHistories = [];
  List<ClinicalHistory> _filteredHistories = [];
  bool _loading = true;
  Object? _error;

  final _searchCtrl = TextEditingController();
  String _selectedTipo = 'TODOS';
  String _selectedFhir = 'TODOS';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data = await ClinicalHistoryService.getAll();
      if (mounted) {
        setState(() {
          _allHistories = data;
          _filteredHistories = data;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e;
          _loading = false;
        });
      }
    }
  }

  void _applyFilters() {
    final query = _searchCtrl.text.toLowerCase();
    setState(() {
      _filteredHistories = _allHistories.where((h) {
        final matchesSearch = h.patientNombre.toLowerCase().contains(query) ||
            (h.diagnosticos.isNotEmpty &&
                h.diagnosticos.any((d) =>
                    d.descripcion.toLowerCase().contains(query) ||
                    d.codigoCie10.toLowerCase().contains(query))) ||
            (h.establecimientoOrigen?.toLowerCase().contains(query) ?? false) ||
            (h.medico.toLowerCase().contains(query));

        final matchesTipo = _selectedTipo == 'TODOS' ||
            h.tipoAtencion?.toUpperCase() == _selectedTipo.toUpperCase();

        final matchesFhir = _selectedFhir == 'TODOS' ||
            h.recursoFhir?.toUpperCase() == _selectedFhir.toUpperCase();

        return matchesSearch && matchesTipo && matchesFhir;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: LoadingState(message: 'Cargando análisis de dataset rural...'),
      );
    }

    if (_error != null) {
      return Scaffold(
        body: ErrorState(
          error: _error!,
          onRetry: _loadData,
        ),
      );
    }

    // Calcular estadísticas
    final total = _allHistories.length;
    final refs = _allHistories
        .where((h) => h.referencia?.toLowerCase() == 'si')
        .length;
    final contras = _allHistories
        .where((h) => h.contrarreferencia?.toLowerCase() == 'si')
        .length;

    double avgAccess = 0;
    double avgAttention = 0;
    if (total > 0) {
      final totalAccess = _allHistories.fold<int>(
          0, (sum, item) => sum + (item.tiempoAccesoHistoria ?? 0));
      final totalAtt = _allHistories.fold<int>(
          0, (sum, item) => sum + (item.tiempoAtencion ?? 0));
      avgAccess = totalAccess / total;
      avgAttention = totalAtt / total;
    }

    // FHIR resource counts
    final fhirCounts = <String, int>{};
    for (var h in _allHistories) {
      if (h.recursoFhir != null && h.recursoFhir!.isNotEmpty) {
        fhirCounts[h.recursoFhir!] = (fhirCounts[h.recursoFhir!] ?? 0) + 1;
      }
    }

    return Column(
      children: [
        AppHeader(
          title: 'Panel HL7 FHIR & Intercambio Rural',
          subtitle: 'Análisis de interoperabilidad y métricas de puestos de salud rurales',
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh, color: AppColors.primary),
              onPressed: _loadData,
              tooltip: 'Actualizar datos',
            ),
          ],
        ),
        PageBody(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── MÉTTRICAS RESUMEN ───────────────────────────────────────────
              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  _MetricCard(
                    title: 'Total Atenciones',
                    value: '$total',
                    subText: 'Registros en BD',
                    icon: Icons.assignment_outlined,
                    color: AppColors.primary,
                  ),
                  _MetricCard(
                    title: 'Acceso Promedio',
                    value: '${avgAccess.toStringAsFixed(1)} min',
                    subText: 'Tiempo de carga de HCE',
                    icon: Icons.speed_outlined,
                    color: AppColors.orange,
                  ),
                  _MetricCard(
                    title: 'Atención Promedio',
                    value: '${avgAttention.toStringAsFixed(1)} min',
                    subText: 'Duración de consulta',
                    icon: Icons.timer_outlined,
                    color: AppColors.blue,
                  ),
                  _MetricCard(
                    title: 'Referencias Activas',
                    value: '$refs / $contras',
                    subText: 'Referencia / Contra.',
                    icon: Icons.swap_calls_outlined,
                    color: AppColors.purple,
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // ── GRÁFICOS FHIR ────────────────────────────────────────────────
              ResponsiveRow(
                leftFlex: 3,
                rightFlex: 2,
                left: Panel(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SectionTitle(
                        Icons.settings_ethernet_outlined,
                        'Distribución de Recursos HL7 FHIR R4',
                      ),
                      const SizedBox(height: 10),
                      if (fhirCounts.isEmpty)
                        const Center(child: Text('Sin datos FHIR disponibles'))
                      else
                        Wrap(
                          spacing: 16,
                          runSpacing: 14,
                          children: fhirCounts.entries.map((entry) {
                            final pct = total > 0 ? (entry.value / total) * 100 : 0;
                            Color c = AppColors.blue;
                            if (entry.key == 'Encounter') c = AppColors.orange;
                            if (entry.key == 'Condition') c = AppColors.red;
                            if (entry.key == 'Observation') c = AppColors.green;
                            if (entry.key == 'Patient') c = AppColors.purple;

                            return Container(
                              width: 140,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF7FAFE),
                                border: Border.all(color: AppColors.line),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    entry.key,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w900,
                                      color: c,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    '${entry.value} (${pct.toStringAsFixed(1)}%)',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                    ],
                  ),
                ),
                right: Panel(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SectionTitle(
                        Icons.verified_user_outlined,
                        'Estado de Intercambio PDI',
                      ),
                      const SizedBox(height: 8),
                      _BarIndicator(
                        label: 'Intercambio Compartido',
                        val: _allHistories
                            .where((h) => h.estadoIntercambio == 'Compartido')
                            .length,
                        total: total,
                        color: AppColors.green,
                      ),
                      const SizedBox(height: 12),
                      _BarIndicator(
                        label: 'Pendiente de Sincronía',
                        val: _allHistories
                            .where((h) => h.estadoIntercambio != 'Compartido')
                            .length,
                        total: total,
                        color: AppColors.orange,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 18),

              // ── TABLA DE DATOS ──────────────────────────────────────────────
              Panel(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SectionTitle(
                      Icons.table_chart_outlined,
                      'Dataset de Interoperabilidad Rural',
                    ),
                    // Filtros
                    Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: TextField(
                            controller: _searchCtrl,
                            decoration: InputDecoration(
                              prefixIcon: const Icon(Icons.search),
                              hintText: 'Buscar por paciente, diagnóstico, CIE-10 u origen...',
                              filled: true,
                              fillColor: AppColors.bg,
                              isDense: true,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide.none,
                              ),
                            ),
                            onChanged: (_) => _applyFilters(),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: DropdownButtonFormField<String>(
                            value: _selectedTipo,
                            isDense: true,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: AppColors.bg,
                              isDense: true,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide.none,
                              ),
                            ),
                            items: const [
                              DropdownMenuItem(value: 'TODOS', child: Text('Tipo: Todos')),
                              DropdownMenuItem(value: 'Consulta Externa', child: Text('Consulta Externa')),
                              DropdownMenuItem(value: 'Emergencia', child: Text('Emergencia')),
                              DropdownMenuItem(value: 'Control', child: Text('Control')),
                            ],
                            onChanged: (v) {
                              if (v != null) {
                                _selectedTipo = v;
                                _applyFilters();
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: DropdownButtonFormField<String>(
                            value: _selectedFhir,
                            isDense: true,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: AppColors.bg,
                              isDense: true,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide.none,
                              ),
                            ),
                            items: const [
                              DropdownMenuItem(value: 'TODOS', child: Text('FHIR: Todos')),
                              DropdownMenuItem(value: 'Encounter', child: Text('Encounter')),
                              DropdownMenuItem(value: 'Condition', child: Text('Condition')),
                              DropdownMenuItem(value: 'Patient', child: Text('Patient')),
                              DropdownMenuItem(value: 'Observation', child: Text('Observation')),
                            ],
                            onChanged: (v) {
                              if (v != null) {
                                _selectedFhir = v;
                                _applyFilters();
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Tabla
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(minWidth: 950),
                        child: DataTable(
                          columnSpacing: 18,
                          headingRowColor: WidgetStateProperty.all(const Color(0xFFF7FAFE)),
                          columns: const [
                            DataColumn(label: Text('Paciente', style: TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(label: Text('DNI', style: TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(label: Text('Origen', style: TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(label: Text('Destino', style: TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(label: Text('Tipo Atenc.', style: TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(label: Text('Diagnóstico (CIE)', style: TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(label: Text('FHIR Resource', style: TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(label: Text('T. Acceso', style: TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(label: Text('T. Atenc.', style: TextStyle(fontWeight: FontWeight.bold))),
                          ],
                          rows: _filteredHistories.map((h) {
                            final String diagStr = h.diagnosticos.isNotEmpty
                                ? '${h.diagnosticos.first.descripcion} (${h.diagnosticos.first.codigoCie10})'
                                : '—';

                            Color fhirColor = AppColors.blue;
                            if (h.recursoFhir == 'Encounter') fhirColor = AppColors.orange;
                            if (h.recursoFhir == 'Condition') fhirColor = AppColors.red;
                            if (h.recursoFhir == 'Observation') fhirColor = AppColors.green;
                            if (h.recursoFhir == 'Patient') fhirColor = AppColors.purple;

                            return DataRow(
                              cells: [
                                DataCell(Text(h.patientNombre, style: const TextStyle(fontWeight: FontWeight.w600))),
                                DataCell(Text(h.id.replaceAll('hc-', ''))), // DNI/id de checkup
                                DataCell(Text(h.establecimientoOrigen ?? '—')),
                                DataCell(Text(h.establecimientoDestino ?? '—')),
                                DataCell(Text(h.tipoAtencion ?? '—')),
                                DataCell(Text(diagStr)),
                                DataCell(
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: fhirColor.withValues(alpha: .12),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      h.recursoFhir ?? 'Encounter',
                                      style: TextStyle(color: fhirColor, fontWeight: FontWeight.bold, fontSize: 11),
                                    ),
                                  ),
                                ),
                                DataCell(Text('${h.tiempoAccesoHistoria ?? 0}s')),
                                DataCell(Text('${h.tiempoAtencion ?? 0}m')),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.title,
    required this.value,
    required this.subText,
    required this.icon,
    required this.color,
  });
  final String title;
  final String value;
  final String subText;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.line),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: color.withValues(alpha: .1),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(color: AppColors.muted, fontSize: 13),
                ),
                Text(
                  value,
                  style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
                ),
                Text(
                  subText,
                  style: const TextStyle(color: AppColors.muted, fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BarIndicator extends StatelessWidget {
  const _BarIndicator({
    required this.label,
    required this.val,
    required this.total,
    required this.color,
  });
  final String label;
  final int val;
  final int total;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final pct = total > 0 ? val / total : 0.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            Text('$val / $total', style: TextStyle(color: color, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: pct,
            color: color,
            backgroundColor: color.withValues(alpha: .1),
            minHeight: 8,
          ),
        ),
      ],
    );
  }
}
