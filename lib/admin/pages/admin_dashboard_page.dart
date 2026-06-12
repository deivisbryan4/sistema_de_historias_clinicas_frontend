import 'package:flutter/material.dart';
import '../admin_models.dart';
import '../admin_api_service.dart';
import '../widgets/admin_stat_card.dart';

// ═══════════════════════════════════════════════════════════════════════════════
// ADMIN DASHBOARD — conectado al backend /api/admin/dashboard/stats
// ═══════════════════════════════════════════════════════════════════════════════

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  Map<String, dynamic>? _stats;
  List<AuditRecord> _recentAudit = [];
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
      final statsRaw = await AdminApiService.getDashboardStats();
      final audit = await AdminApiService.getAuditRecords();
      setState(() {
        _stats = statsRaw;
        _recentAudit = audit
            .where((a) => a.accion == AuditActionType.login || a.accion == AuditActionType.logout)
            .take(6)
            .toList();
        _loading = false;
      });
    } catch (e) {
      setState(() { _error = e.toString(); _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
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
            Text('Error al cargar dashboard', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
            const SizedBox(height: 4),
            Text(_error!, style: const TextStyle(color: Color(0xFF637995), fontSize: 13)),
            const SizedBox(height: 16),
            FilledButton.icon(onPressed: _load, icon: const Icon(Icons.refresh), label: const Text('Reintentar')),
          ],
        ),
      );
    }

    final s = _stats ?? {};
    final activeUsers = s['activeUsers'] as int? ?? 0;
    final doctors = s['doctors'] as int? ?? 0;
    final nurses = s['nurses'] as int? ?? 0;
    final admins = s['admins'] as int? ?? 0;
    final inactiveUsers = s['inactiveUsers'] as int? ?? 0;
    final activeAreas = s['activeAreas'] as int? ?? 0;

    return Column(
      children: [
        _AdminPageHeader(
          title: 'Dashboard de Administración',
          subtitle: 'Resumen del sistema · Centro de Salud Juliaca',
          onRefresh: _load,
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Stat Cards ──────────────────────────────────────
                LayoutBuilder(
                  builder: (context, c) {
                    final cols = c.maxWidth > 900 ? 3 : c.maxWidth > 560 ? 2 : 1;
                    return GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: cols,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: cols == 1 ? 3.2 : 2.0,
                      children: [
                        AdminStatCard(
                          icon: Icons.verified_user_outlined,
                          label: 'Usuarios activos',
                          value: '$activeUsers',
                          color: const Color(0xFF2F8A5B),
                          subtitle: 'En el sistema ahora',
                        ),
                        AdminStatCard(
                          icon: Icons.medical_services_outlined,
                          label: 'Médicos',
                          value: '$doctors',
                          color: const Color(0xFF2F7DE1),
                          subtitle: 'Con CMP registrado',
                        ),
                        AdminStatCard(
                          icon: Icons.local_hospital_outlined,
                          label: 'Enfermeros/as',
                          value: '$nurses',
                          color: const Color(0xFF7A4FC3),
                          subtitle: 'Personal de enfermería',
                        ),
                        AdminStatCard(
                          icon: Icons.admin_panel_settings_outlined,
                          label: 'Administrativos',
                          value: '$admins',
                          color: const Color(0xFFFFA927),
                          subtitle: 'Gestión y soporte',
                        ),
                        AdminStatCard(
                          icon: Icons.person_off_outlined,
                          label: 'Usuarios inactivos',
                          value: '$inactiveUsers',
                          color: const Color(0xFFE84B4B),
                          subtitle: 'Inactivos o suspendidos',
                        ),
                        AdminStatCard(
                          icon: Icons.domain_outlined,
                          label: 'Áreas activas',
                          value: '$activeAreas',
                          color: const Color(0xFF173E63),
                          subtitle: 'Áreas de atención',
                        ),
                      ],
                    );
                  },
                ),

                const SizedBox(height: 28),

                // ── Bottom Row ───────────────────────────────────────
                LayoutBuilder(
                  builder: (context, c) {
                    if (c.maxWidth < 760) {
                      return Column(
                        children: [
                          _RecentAccessPanel(records: _recentAudit),
                          const SizedBox(height: 18),
                          _SecurityAlertsPanel(),
                        ],
                      );
                    }
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 6, child: _RecentAccessPanel(records: _recentAudit)),
                        const SizedBox(width: 18),
                        Expanded(flex: 4, child: _SecurityAlertsPanel()),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _RecentAccessPanel extends StatelessWidget {
  const _RecentAccessPanel({required this.records});
  final List<AuditRecord> records;

  @override
  Widget build(BuildContext context) {
    return _AdminCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CardHeader(icon: Icons.history_outlined, title: 'Últimos accesos al sistema'),
          const SizedBox(height: 16),
          if (records.isEmpty)
            const Text('Sin registros recientes', style: TextStyle(color: Color(0xFF637995)))
          else
            ...records.map((record) => _AccessRow(record)),
        ],
      ),
    );
  }
}

class _AccessRow extends StatelessWidget {
  const _AccessRow(this.record);
  final AuditRecord record;

  @override
  Widget build(BuildContext context) {
    final isLogin = record.accion == AuditActionType.login;
    final color = isLogin ? const Color(0xFF2F8A5B) : const Color(0xFFE84B4B);
    final hora = '${record.fecha.hour.toString().padLeft(2, '0')}:${record.fecha.minute.toString().padLeft(2, '0')}';

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFFF0F4FA)))),
      child: Row(
        children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: color.withValues(alpha: .1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(record.accion.icon, color: color, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(record.usuario, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                Text('${record.usuarioRol} · ${record.ip}', style: const TextStyle(color: Color(0xFF637995), fontSize: 12)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(hora, style: const TextStyle(fontWeight: FontWeight.w700)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(color: color.withValues(alpha: .1), borderRadius: BorderRadius.circular(6)),
                child: Text(record.accion.label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w700)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SecurityAlertsPanel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return _AdminCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CardHeader(icon: Icons.security_outlined, title: 'Alertas de seguridad'),
          const SizedBox(height: 16),
          _AlertItem(icon: Icons.lock_person_outlined, color: const Color(0xFFE84B4B), title: 'Intento de acceso no autorizado', subtitle: 'IP: 200.45.123.88 · Hace 1h'),
          _AlertItem(icon: Icons.person_off_outlined, color: const Color(0xFFFFA927), title: 'Usuario suspendido', subtitle: 'Tec. Rosa Ccopa · Suspendida hoy'),
          _AlertItem(icon: Icons.pending_actions_outlined, color: const Color(0xFF2F7DE1), title: 'Permisos pendientes de revisión', subtitle: '2 solicitudes en cola'),
          _AlertItem(icon: Icons.update_outlined, color: const Color(0xFF2F8A5B), title: 'Sistema actualizado', subtitle: 'v1.4.2 instalado correctamente'),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.visibility_outlined, size: 16),
              label: const Text('Ver auditoría completa'),
            ),
          ),
        ],
      ),
    );
  }
}

class _AlertItem extends StatelessWidget {
  const _AlertItem({required this.icon, required this.color, required this.title, required this.subtitle});
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .06),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: .2)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: color)),
                Text(subtitle, style: const TextStyle(color: Color(0xFF637995), fontSize: 11)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}



class _AdminPageHeader extends StatelessWidget {
  const _AdminPageHeader({required this.title, required this.subtitle, this.onRefresh});
  final String title;
  final String subtitle;
  final VoidCallback? onRefresh;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
      decoration: const BoxDecoration(color: Colors.white, border: Border(bottom: BorderSide(color: Color(0xFFD4E0EC)))),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
                Text(subtitle, style: const TextStyle(color: Color(0xFF637995), fontSize: 14)),
              ],
            ),
          ),
          if (onRefresh != null)
            IconButton(icon: const Icon(Icons.refresh_outlined), tooltip: 'Actualizar', onPressed: onRefresh),
        ],
      ),
    );
  }
}

class _AdminCard extends StatelessWidget {
  const _AdminCard({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFD4E0EC)),
        borderRadius: BorderRadius.circular(14),
      ),
      child: child,
    );
  }
}

class _CardHeader extends StatelessWidget {
  const _CardHeader({required this.icon, required this.title});
  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: const Color(0xFF173E63)),
        const SizedBox(width: 8),
        Expanded(child: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800))),
      ],
    );
  }
}
