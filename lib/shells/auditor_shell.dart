import 'package:flutter/material.dart';
import '../widgets/common_widgets.dart';
import '../pages/reports_page.dart';
import '../pages/dataset_analytics_page.dart';
import '../core/user_session.dart';
import 'role_shell_base.dart';

// ─────────────────────────────────────────────────────────────────────────────
// SHELL AUDITOR — solo lectura: auditoría, reportes, estadísticas
// ─────────────────────────────────────────────────────────────────────────────
class AuditorShell extends StatefulWidget {
  const AuditorShell({super.key});

  @override
  State<AuditorShell> createState() => _AuditorShellState();
}

class _AuditorShellState extends State<AuditorShell> {
  int _index = 0;

  static const _navItems = [
    RoleNavItem(
      icon: Icons.dashboard_outlined,
      label: 'Panel de auditoría',
      section: 'PRINCIPAL',
    ),
    RoleNavItem(
      icon: Icons.fact_check_outlined,
      label: 'Registros de acceso',
      badge: '142',
    ),
    RoleNavItem(
      icon: Icons.bar_chart_outlined,
      label: 'Reportes',
      section: 'ANÁLISIS',
    ),
    RoleNavItem(
      icon: Icons.security_outlined,
      label: 'Alertas de seguridad',
    ),
    RoleNavItem(
      icon: Icons.sync_alt_outlined,
      label: 'Intercambio Rural & FHIR',
      section: 'HL7 FHIR',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final pages = [
      _AuditorDashboard(),
      _RegistrosAccesoPage(),
      const ReportsPage(),
      _AlertasSegPage(),
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
                  selectedIndex: _index.clamp(0, 3),
                  onDestinationSelected: (i) => setState(() => _index = i),
                  destinations: const [
                    NavigationDestination(
                      icon: Icon(Icons.dashboard_outlined),
                      label: 'Panel',
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.fact_check_outlined),
                      label: 'Registros',
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.bar_chart_outlined),
                      label: 'Reportes',
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.security_outlined),
                      label: 'Alertas',
                    ),
                  ],
                ),
          body: Row(
            children: [
              if (wide)
                RoleSideBar(
                  items: _navItems,
                  selectedIndex: _index,
                  onSelect: (i) => setState(() => _index = i),
                  accentColor: const Color(0xFF7A4FC3),
                ),
              Expanded(child: pages[_index]),
            ],
          ),
        );
      },
    );
  }
}

// ── Dashboard del Auditor ─────────────────────────────────────────────────────
class _AuditorDashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final session = UserSession.instance;
    return Column(
      children: [
        AppHeader(
          title: 'Panel de Auditoría',
          subtitle: '${session.nombre} · ${session.area} · C.S. Juliaca',
          actions: [
            OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.download_outlined),
              label: const Text('Exportar log'),
            ),
            FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF7A4FC3),
              ),
              onPressed: () {},
              icon: const Icon(Icons.picture_as_pdf),
              label: const Text('Informe PDF'),
            ),
          ],
        ),
        PageBody(
          child: Column(
            children: [
              LayoutBuilder(
                builder: (context, c) {
                  final cols = c.maxWidth > 700 ? 4 : 2;
                  final metrics = [
                    _AuditMetric('Accesos hoy', '142', Icons.login_outlined, const Color(0xFFE9F2FF), const Color(0xFF2F7DE1)),
                    _AuditMetric('Alertas activas', '3', Icons.warning_amber_outlined, const Color(0xFFFFE8EC), const Color(0xFFE84B4B)),
                    _AuditMetric('Exportaciones', '8', Icons.upload_outlined, const Color(0xFFFFF1D9), const Color(0xFFFFA927)),
                    _AuditMetric('Usuarios activos', '12', Icons.people_outline, const Color(0xFFF2E9FA), const Color(0xFF7A4FC3)),
                  ];
                  return GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: cols,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                    childAspectRatio: cols == 4 ? 1.6 : 1.8,
                    children: metrics,
                  );
                },
              ),
              const SizedBox(height: 22),
              ResponsiveRow(
                leftFlex: 6,
                rightFlex: 5,
                left: Panel(
                  child: Column(
                    children: [
                      SectionTitle(
                        Icons.history,
                        'Últimas acciones del sistema',
                        action: TextButton(
                          onPressed: () {},
                          child: const Text('Ver todo'),
                        ),
                      ),
                      for (final a in [
                        ('dr.martinez', 'Creó HC', 'Historias Clínicas', '08:15', const Color(0xFF2F8A5B), Icons.add_circle_outline),
                        ('adm.huanca', 'Registró paciente', 'Pacientes', '08:22', const Color(0xFF2F7DE1), Icons.person_add_alt),
                        ('admin.sistema', 'Exportó usuarios', 'Administración', '08:30', const Color(0xFFFFA927), Icons.upload_outlined),
                        ('dr.martinez', 'Firmó receta', 'Recetas', '09:01', const Color(0xFF7A4FC3), Icons.receipt_long_outlined),
                        ('SISTEMA', 'Acceso fallido ×3', 'Seguridad', '09:14', const Color(0xFFE84B4B), Icons.block_outlined),
                      ])
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 7),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 16,
                                backgroundColor: a.$5.withValues(alpha: .12),
                                child: Icon(a.$6, color: a.$5, size: 14),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(a.$2, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                                    Text('${a.$1} · ${a.$3}', style: const TextStyle(color: AppColors.muted, fontSize: 12)),
                                  ],
                                ),
                              ),
                              Text(a.$4, style: const TextStyle(color: AppColors.muted, fontSize: 12)),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
                right: Panel(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SectionTitle(Icons.security_outlined, 'Alertas de seguridad'),
                      _AuditAlert(
                        'Accesos fallidos repetidos',
                        'Usuario: unknown · 09:14 am · 3 intentos',
                        const Color(0xFFE84B4B),
                      ),
                      _AuditAlert(
                        'Exportación masiva detectada',
                        'adm.huanca · Exportó 320 registros',
                        const Color(0xFFFFA927),
                      ),
                      _AuditAlert(
                        'Sesión fuera de horario',
                        'dr.backup · Acceso 02:31 am',
                        const Color(0xFFFFA927),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFF7A4FC3),
                          ),
                          onPressed: () {},
                          icon: const Icon(Icons.send_outlined),
                          label: const Text('Reportar incidente'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Registros de acceso (Log) ─────────────────────────────────────────────────
class _RegistrosAccesoPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppHeader(
          title: 'Registros de Acceso',
          subtitle: 'Log completo de auditoría del sistema — solo lectura',
          actions: [
            OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.filter_alt_outlined),
              label: const Text('Filtrar'),
            ),
            FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF7A4FC3),
              ),
              onPressed: () {},
              icon: const Icon(Icons.download_outlined),
              label: const Text('Exportar CSV'),
            ),
          ],
        ),
        PageBody(
          child: Panel(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      SizedBox(
                        width: 280,
                        child: TextField(
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.search),
                            hintText: 'Buscar usuario o módulo',
                            filled: true,
                            fillColor: const Color(0xFFF5F8FC),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            isDense: true,
                          ),
                        ),
                      ),
                      for (final label in ['Todos', 'Login', 'Crear', 'Editar', 'Eliminar', 'Exportar'])
                        OutlinedButton(
                          onPressed: () {},
                          child: Text(label),
                        ),
                    ],
                  ),
                ),
                DataTable(
                  headingRowColor: WidgetStateProperty.all(const Color(0xFFF4F7FB)),
                  columnSpacing: 20,
                  columns: const [
                    DataColumn(label: Text('USUARIO')),
                    DataColumn(label: Text('ACCIÓN')),
                    DataColumn(label: Text('MÓDULO')),
                    DataColumn(label: Text('DETALLE')),
                    DataColumn(label: Text('IP')),
                    DataColumn(label: Text('FECHA')),
                  ],
                  rows: [
                    for (final r in [
                      ('dr.martinez', 'CREAR', 'HC', 'Nueva HC para Rosa Villanueva', '192.168.1.10', '09/06 · 08:15'),
                      ('adm.huanca', 'CREAR', 'Pacientes', 'Registró Ana Cáceres Ticona', '192.168.1.14', '09/06 · 08:22'),
                      ('admin.sistema', 'EXPORTAR', 'Admin', 'Exportó lista de usuarios (CSV)', '192.168.1.1', '09/06 · 08:30'),
                      ('dr.martinez', 'EDITAR', 'Recetas', 'Firmó receta RX-2026-00142', '192.168.1.10', '09/06 · 09:01'),
                      ('enf.flores', 'CREAR', 'Signos', 'Reg. signos: Rosa Villanueva', '192.168.1.12', '09/06 · 09:10'),
                      ('SISTEMA', 'LOGIN_FAIL', 'Seguridad', 'Intento #3 fallido usuario unknown', '192.168.5.22', '09/06 · 09:14'),
                    ])
                      DataRow(
                        color: r.$2 == 'LOGIN_FAIL'
                            ? WidgetStateProperty.all(const Color(0xFFFFF0F0))
                            : null,
                        cells: [
                          DataCell(Text(r.$1, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13))),
                          DataCell(_AccionBadge(r.$2)),
                          DataCell(Text(r.$3)),
                          DataCell(SizedBox(width: 200, child: Text(r.$4, style: const TextStyle(color: AppColors.muted, fontSize: 12)))),
                          DataCell(Text(r.$5, style: const TextStyle(fontFamily: 'monospace', fontSize: 12))),
                          DataCell(Text(r.$6, style: const TextStyle(color: AppColors.muted, fontSize: 12))),
                        ],
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ── Alertas de seguridad ──────────────────────────────────────────────────────
class _AlertasSegPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppHeader(
          title: 'Alertas de Seguridad',
          subtitle: 'Eventos críticos y anomalías detectadas',
          actions: [
            FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFE84B4B),
              ),
              onPressed: () {},
              icon: const Icon(Icons.send_outlined),
              label: const Text('Reportar incidente'),
            ),
          ],
        ),
        PageBody(
          child: Column(
            children: [
              for (final alert in [
                ('CRÍTICO', 'Accesos fallidos múltiples', 'El usuario desconocido realizó 3 intentos fallidos de acceso desde IP externa (192.168.5.22). Posible ataque de fuerza bruta.', const Color(0xFFE84B4B), '09/06/2026 · 09:14 am'),
                ('ADVERTENCIA', 'Exportación masiva detectada', 'El usuario adm.huanca exportó 320 registros de pacientes en una sola operación. Se requiere justificación.', const Color(0xFFFFA927), '09/06/2026 · 08:30 am'),
                ('ADVERTENCIA', 'Sesión fuera de horario laboral', 'El usuario dr.backup accedió al sistema a las 02:31 am, fuera del horario habitual (07:00–20:00).', const Color(0xFFFFA927), '08/06/2026 · 02:31 am'),
                ('INFO', 'Cambio de contraseña pendiente', '5 usuarios no han cambiado su contraseña en más de 90 días. Acción requerida.', const Color(0xFF2F7DE1), '08/06/2026'),
              ])
                Column(
                  children: [
                    Panel(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: alert.$4.withValues(alpha: .12),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              alert.$1,
                              style: TextStyle(
                                color: alert.$4,
                                fontWeight: FontWeight.w900,
                                fontSize: 11,
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(alert.$2, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                                const SizedBox(height: 6),
                                Text(alert.$3, style: const TextStyle(color: AppColors.muted, height: 1.4)),
                                const SizedBox(height: 8),
                                Text(alert.$5, style: const TextStyle(color: AppColors.muted, fontSize: 12)),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.check_circle_outline, color: AppColors.green),
                            tooltip: 'Marcar como revisada',
                            onPressed: () {},
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Widgets auxiliares ────────────────────────────────────────────────────────
class _AuditMetric extends StatelessWidget {
  const _AuditMetric(this.label, this.value, this.icon, this.bg, this.color);
  final String label;
  final String value;
  final IconData icon;
  final Color bg;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Panel(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: bg,
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: AppColors.muted,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    height: 1,
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

class _AuditAlert extends StatelessWidget {
  const _AuditAlert(this.title, this.detail, this.color);
  final String title;
  final String detail;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .06),
        border: Border.all(color: color.withValues(alpha: .3)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(fontWeight: FontWeight.w800, color: color)),
          Text(detail, style: const TextStyle(color: AppColors.muted, fontSize: 12)),
        ],
      ),
    );
  }
}

class _AccionBadge extends StatelessWidget {
  const _AccionBadge(this.accion);
  final String accion;

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (accion) {
      case 'CREAR':
        color = AppColors.green;
        break;
      case 'EDITAR':
        color = AppColors.blue;
        break;
      case 'ELIMINAR':
        color = AppColors.red;
        break;
      case 'EXPORTAR':
        color = AppColors.orange;
        break;
      case 'LOGIN_FAIL':
        color = AppColors.red;
        break;
      default:
        color = AppColors.muted;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .12),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        accion,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w800,
          fontSize: 11,
        ),
      ),
    );
  }
}
