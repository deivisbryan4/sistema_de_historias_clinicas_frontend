import 'package:flutter/material.dart';
import '../core/models.dart';
import '../core/services.dart';
import '../core/app_state_widgets.dart';
import '../widgets/common_widgets.dart';

class ReportsPage extends StatefulWidget {
  const ReportsPage({super.key});

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  DashboardStats? _stats;
  DashboardStats? _clinicalStats;
  bool _loading = true;
  Object? _error;
  String _filterPeriod = 'month';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final results = await Future.wait([
        DashboardService.getStats(),
        DashboardService.getClinicalStats(),
      ]);
      if (mounted) setState(() {
        _stats = results[0];
        _clinicalStats = results[1];
        _loading = false;
      });
    } catch (e) {
      if (mounted) setState(() { _error = e; _loading = false; });
    }
  }

  void _showComingSoon() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Función disponible próximamente')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = _clinicalStats ?? _stats;
    return Column(
      children: [
        AppHeader(
          title: 'Reportes y Estadísticas',
          subtitle: 'Indicadores de gestión · Centro de Salud Juliaca',
          actions: [
            IconButton(
              onPressed: _load,
              icon: const Icon(Icons.refresh),
              tooltip: 'Actualizar',
            ),
            FilledButton.icon(
              style: FilledButton.styleFrom(backgroundColor: AppColors.red),
              onPressed: _showComingSoon,
              icon: const Icon(Icons.picture_as_pdf),
              label: const Text('Exportar PDF'),
            ),
            FilledButton.icon(
              style: FilledButton.styleFrom(backgroundColor: AppColors.green),
              onPressed: _showComingSoon,
              icon: const Icon(Icons.table_chart),
              label: const Text('Exportar Excel'),
            ),
          ],
        ),
        PageBody(
          child: _loading
              ? const LoadingState(message: 'Cargando estadísticas...')
              : _error != null
                  ? ErrorState(error: _error!, onRetry: _load)
                  : Column(
                      children: [
                        // ── Filtros de período ───────────────────────
                        Panel(
                          padding: const EdgeInsets.all(14),
                          child: Row(
                            children: [
                              const Text('Filtrar por:',
                                  style: TextStyle(color: AppColors.muted)),
                              const SizedBox(width: 12),
                              _FilterChip('Hoy', 'today', _filterPeriod,
                                  () => setState(() { _filterPeriod = 'today'; _load(); })),
                              const SizedBox(width: 8),
                              _FilterChip('Esta semana', 'week', _filterPeriod,
                                  () => setState(() { _filterPeriod = 'week'; _load(); })),
                              const SizedBox(width: 8),
                              _FilterChip('Este mes', 'month', _filterPeriod,
                                  () => setState(() { _filterPeriod = 'month'; _load(); })),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),
                        // ── Métricas principales ─────────────────────
                        Wrap(
                          spacing: 14,
                          runSpacing: 14,
                          children: [
                            ReportMetric(
                              '${s?.totalPatients ?? 0}',
                              'Total Pacientes',
                              'Registrados en el sistema',
                              AppColors.blue,
                            ),
                            ReportMetric(
                              '${s?.consultationsToday ?? 0}',
                              'Consultas hoy',
                              'Atendidas en el día',
                              AppColors.green,
                            ),
                            ReportMetric(
                              '${s?.newPatientsThisMonth ?? 0}',
                              'Nuevos este mes',
                              'Pacientes nuevos registrados',
                              AppColors.orange,
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        const ResponsiveRow(
                            left: ServiceChartPanel(), right: AuditPanel()),
                        const SizedBox(height: 18),
                        const UsersAdminPanel(),
                      ],
                    ),
        ),
      ],
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip(this.label, this.value, this.selected, this.onTap);
  final String label;
  final String value;
  final String selected;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    final isSelected = value == selected;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.bg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.line),
        ),
        child: Text(label,
            style: TextStyle(
              color: isSelected ? Colors.white : AppColors.text,
              fontWeight: FontWeight.w700,
              fontSize: 13,
            )),
      ),
    );
  }
}

class ReportMetric extends StatelessWidget {
  const ReportMetric(
    this.value,
    this.label,
    this.delta,
    this.color, {
    super.key,
  });
  final String value;
  final String label;
  final String delta;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 140, maxWidth: 320),
      child: Panel(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w900,
              ),
            ),
            Text(
              label,
              style: const TextStyle(color: AppColors.muted, fontSize: 13),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              delta,
              style: TextStyle(color: color, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}

class ServiceChartPanel extends StatelessWidget {
  const ServiceChartPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionTitle(Icons.bar_chart, 'Consultas por servicio'),
          SizedBox(
            height: 150,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                for (final b in [
                  ('Medicina', 120, AppColors.blue),
                  ('Pediatría', 82, AppColors.green),
                  ('Gineco.', 62, AppColors.purple),
                  ('Emerg.', 35, AppColors.red),
                  ('Otros', 24, AppColors.orange),
                ])
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          height: b.$2.toDouble(),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          decoration: BoxDecoration(
                            color: b.$3,
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          b.$1,
                          style: const TextStyle(
                            color: AppColors.muted,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class AuditPanel extends StatelessWidget {
  const AuditPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Panel(
      child: Column(
        children: [
          const SectionTitle(Icons.verified_user_outlined, 'Auditoría del sistema'),
          _ConsultRow(
            'I',
            'Inicio de sesión exitoso',
            'Dr. A. Martínez · IP 192.168.1.4',
            '08:01',
            Colors.green,
          ),
          _ConsultRow(
            'HC',
            'HC creada — Rosa Villanueva',
            'Dr. A. Martínez',
            '08:15',
            Colors.blue,
          ),
          _ConsultRow(
            'M',
            'HC modificada — Juan Condori',
            'Enf. Carmen Ramos',
            '08:32',
            Colors.orange,
          ),
          _ConsultRow(
            'C',
            'Cierre de sesión',
            'Adm. Luis Torres · IP 192.168.1.9',
            '08:45',
            Colors.red,
          ),
        ],
      ),
    );
  }
}

class _ConsultRow extends StatelessWidget {
  const _ConsultRow(this.initials, this.title, this.subtitle, this.badge, this.color);
  final String initials;
  final String title;
  final String subtitle;
  final String badge;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: color.withValues(alpha: .12),
            child: Text(initials, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(color: AppColors.muted, fontSize: 13),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: color.withValues(alpha: .12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(badge,
                style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 12)),
          ),
        ],
      ),
    );
  }
}

class UsersAdminPanel extends StatelessWidget {
  const UsersAdminPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionTitle(
            Icons.groups_outlined,
            'Administración de usuarios y roles',
          ),
          Wrap(
            spacing: 24,
            runSpacing: 18,
            children: [
              ConstrainedBox(
                constraints: const BoxConstraints(minWidth: 200, maxWidth: 300),
                child: const Column(
                  children: [
                    _ConsultRow(
                      'AM',
                      'Dr. Alejandro Martínez',
                      'Médico general',
                      'Activo',
                      Colors.green,
                    ),
                    _ConsultRow(
                      'CR',
                      'Enf. Carmen Ramos',
                      'Enfermera',
                      'Activo',
                      Colors.green,
                    ),
                    _ConsultRow(
                      'LT',
                      'Adm. Luis Torres',
                      'Administrativo',
                      'Inactivo',
                      Colors.grey,
                    ),
                  ],
                ),
              ),
              ConstrainedBox(
                constraints: const BoxConstraints(minWidth: 200, maxWidth: 300),
                child: const Text(
                  'Roles disponibles\n\nMédico — Acceso completo HC\nEnfermero/a — Signos vitales\nAdministrativo — Solo consulta\nAuditor — Solo lectura',
                  style: TextStyle(height: 1.55, fontSize: 13),
                ),
              ),
              ConstrainedBox(
                constraints: const BoxConstraints(minWidth: 200, maxWidth: 300),
                child: const Text(
                  'Permisos por módulo\n\nHistorias clínicas       ✓ Médico\nTeleconsultas           ✓ Médico + Enf.\nReportes                ✓ Todos\nAdministración          ✗ Solo Admin.',
                  style: TextStyle(height: 1.55, fontSize: 13),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
