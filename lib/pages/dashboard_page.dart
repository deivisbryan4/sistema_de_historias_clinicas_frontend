import 'package:flutter/material.dart';
import '../core/models.dart';
import '../core/services.dart';
import '../core/app_state_widgets.dart';
import '../widgets/common_widgets.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Dashboard Principal — métricas del backend
// ─────────────────────────────────────────────────────────────────────────────
class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  DashboardStats? _stats;
  List<ClinicalHistory> _recent = [];
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
        ClinicalHistoryService.getRecent(),
      ]);
      if (mounted) {
        setState(() {
          _stats = results[0] as DashboardStats;
          _recent = results[1] as List<ClinicalHistory>;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() { _error = e; _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppHeader(
          title: 'Dashboard Médico',
          subtitle: 'Resumen clínico del día',
          actions: [
            IconButton(
              onPressed: _load,
              icon: const Icon(Icons.refresh),
              tooltip: 'Actualizar',
            ),
          ],
        ),
        PageBody(
          child: _loading
              ? const LoadingState(message: 'Cargando estadísticas...')
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
        // ── Métricas principales ────────────────────────────────────────
        LayoutBuilder(builder: (ctx, c) {
          final cols = c.maxWidth > 700 ? 4 : 2;
          final cards = [
            _DashMetric(
              '${s?.totalPatients ?? 0}',
              'Total Pacientes',
              Icons.people_outline,
              AppColors.blue,
            ),
            _DashMetric(
              '${s?.consultationsToday ?? 0}',
              'Consultas hoy',
              Icons.medical_services_outlined,
              AppColors.green,
            ),
            _DashMetric(
              '${s?.newPatientsThisMonth ?? 0}',
              'Nuevos este mes',
              Icons.person_add_alt_outlined,
              AppColors.orange,
            ),
            _DashMetric(
              '${s?.activeAreas ?? 0}',
              'Áreas activas',
              Icons.local_hospital_outlined,
              AppColors.purple,
            ),
          ];
          if (cols == 1) {
            return Column(
              children: cards
                  .map((c) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: c,
                      ))
                  .toList(),
            );
          }
          return GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: cols,
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
            childAspectRatio: cols == 4 ? 2.0 : 2.2,
            children: cards,
          );
        }),
        const SizedBox(height: 22),
        // ── Últimas consultas ───────────────────────────────────────────
        Panel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SectionTitle(
                Icons.history,
                'Últimas consultas',
                action: TextButton(
                  onPressed: _load,
                  child: const Text('Actualizar'),
                ),
              ),
              if (_recent.isEmpty)
                const EmptyState(
                  message: 'No hay consultas recientes',
                  icon: Icons.medical_services_outlined,
                )
              else
                ..._recent.map((h) => _HistoryRow(h)),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Tarjeta de métrica ────────────────────────────────────────────────────────
class _DashMetric extends StatelessWidget {
  const _DashMetric(this.value, this.label, this.icon, this.color);
  final String value;
  final String label;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Panel(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: color.withValues(alpha: .12),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                      fontSize: 26, fontWeight: FontWeight.w900, height: 1),
                ),
                Text(
                  label,
                  style: const TextStyle(
                      color: AppColors.muted, fontSize: 12),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Fila de historial reciente ────────────────────────────────────────────────
class _HistoryRow extends StatelessWidget {
  const _HistoryRow(this.h);
  final ClinicalHistory h;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          const CircleAvatar(
            backgroundColor: Color(0xFFE9F2FF),
            child: Icon(Icons.medical_services_outlined, color: AppColors.blue),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  h.patientNombre,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                Text(
                  '${h.especialidad} · ${h.medico}',
                  style: const TextStyle(
                      color: AppColors.muted, fontSize: 13),
                ),
              ],
            ),
          ),
          _StatusChip(h.estado),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip(this.status);
  final String status;

  @override
  Widget build(BuildContext context) {
    final (color, label) = switch (status.toUpperCase()) {
      'FIRMADA' => (AppColors.green, 'Firmada'),
      'COMPLETADA' => (AppColors.blue, 'Completada'),
      _ => (AppColors.orange, 'Borrador'),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(label,
          style: TextStyle(
              color: color, fontWeight: FontWeight.w700, fontSize: 12)),
    );
  }
}
