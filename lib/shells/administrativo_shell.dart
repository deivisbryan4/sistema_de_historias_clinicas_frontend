import 'package:flutter/material.dart';
import '../widgets/common_widgets.dart';
import '../pages/patients_page.dart';
import '../pages/reports_page.dart';
import '../pages/dataset_analytics_page.dart';
import '../core/user_session.dart';
import 'role_shell_base.dart';

// ─────────────────────────────────────────────────────────────────────────────
// SHELL ADMINISTRATIVO — admisión, registro de pacientes, citas, reportes
// ─────────────────────────────────────────────────────────────────────────────
class AdministrativoShell extends StatefulWidget {
  const AdministrativoShell({super.key});

  @override
  State<AdministrativoShell> createState() => _AdministrativoShellState();
}

class _AdministrativoShellState extends State<AdministrativoShell> {
  int _index = 0;

  static const _navItems = [
    RoleNavItem(
      icon: Icons.dashboard_outlined,
      label: 'Panel principal',
      section: 'PRINCIPAL',
    ),
    RoleNavItem(
      icon: Icons.person_add_alt_outlined,
      label: 'Admisión / Registro',
      badge: '7',
    ),
    RoleNavItem(
      icon: Icons.people_outline,
      label: 'Pacientes',
      section: 'GESTIÓN',
    ),
    RoleNavItem(
      icon: Icons.calendar_month_outlined,
      label: 'Citas programadas',
    ),
    RoleNavItem(
      icon: Icons.bar_chart_outlined,
      label: 'Reportes',
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
      _AdministrativoDashboard(),
      _AdmisionPage(),
      const PatientsPage(),
      _CitasPage(),
      const ReportsPage(),
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
                      label: 'Inicio',
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.person_add_alt_outlined),
                      label: 'Admisión',
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.people_outline),
                      label: 'Pacientes',
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.calendar_month_outlined),
                      label: 'Citas',
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
                  accentColor: const Color(0xFFFFA927),
                ),
              Expanded(child: pages[_index]),
            ],
          ),
        );
      },
    );
  }
}

// ── Dashboard administrativo ──────────────────────────────────────────────────
class _AdministrativoDashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final session = UserSession.instance;
    return Column(
      children: [
        AppHeader(
          title: 'Panel Administrativo',
          subtitle: '${session.nombre} · ${session.area} · C.S. Juliaca',
          actions: [
            FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFFFA927),
              ),
              onPressed: () {},
              icon: const Icon(Icons.person_add_alt),
              label: const Text('Nueva admisión'),
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
                    _AdminMetric('En espera', '7', Icons.hourglass_top_outlined, const Color(0xFFFFF1D9), const Color(0xFFFFA927)),
                    _AdminMetric('Atendidos hoy', '18', Icons.check_circle_outline, const Color(0xFFE8F7EF), const Color(0xFF2F8A5B)),
                    _AdminMetric('Citas hoy', '24', Icons.calendar_today_outlined, const Color(0xFFE9F2FF), const Color(0xFF2F7DE1)),
                    _AdminMetric('Nuevos', '5', Icons.person_add_alt_outlined, const Color(0xFFFFE8EC), const Color(0xFFE84B4B)),
                  ];
                  // En móvil 2 cols: usar Column si cols==1, sino GridView
                  if (cols == 1) {
                    return Column(
                      children: [
                        for (int i = 0; i < metrics.length; i++) ...[
                          metrics[i],
                          if (i < metrics.length - 1) const SizedBox(height: 12),
                        ],
                      ],
                    );
                  }
                  return GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: cols,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                    childAspectRatio: cols == 4 ? 1.8 : 2.0,
                    children: metrics,
                  );
                },
              ),
              const SizedBox(height: 22),
              ResponsiveRow(
                left: Panel(
                  child: Column(
                    children: [
                      SectionTitle(
                        Icons.queue_outlined,
                        'Cola de espera — turno actual',
                        action: TextButton(
                          onPressed: () {},
                          child: const Text('Llamar siguiente'),
                        ),
                      ),
                      for (final p in [
                        ('7', 'Rosa Villanueva Quispe', 'Medicina General', 'En espera'),
                        ('8', 'Juan Condori Mamani', 'Pediatría', 'En espera'),
                        ('9', 'Ana Cáceres Ticona', 'Medicina', 'Llamado'),
                        ('10', 'Esteban Puma Chura', 'Cardiología', 'En espera'),
                      ])
                        ListTile(
                          leading: CircleAvatar(
                            backgroundColor: const Color(0xFFE3EDF9),
                            child: Text(p.$1, style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.primary)),
                          ),
                          title: Text(p.$2, style: const TextStyle(fontWeight: FontWeight.w800)),
                          subtitle: Text(p.$3),
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: p.$4 == 'Llamado'
                                  ? const Color(0xFFE8F7EF)
                                  : const Color(0xFFFFF1D9),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              p.$4,
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: p.$4 == 'Llamado'
                                    ? AppColors.green
                                    : AppColors.orange,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                right: Panel(
                  child: Column(
                    children: [
                      SectionTitle(
                        Icons.calendar_month_outlined,
                        'Próximas citas — hoy',
                        action: TextButton(
                          onPressed: () {},
                          child: const Text('Ver agenda'),
                        ),
                      ),
                      for (final c in [
                        ('09:30', 'Ana Cáceres', 'Medicina'),
                        ('10:00', 'Luis Mamani', 'Pediatría'),
                        ('11:00', 'Carmen Ríos', 'Ginecología'),
                        ('12:00', 'Pedro Apaza', 'Cardiología'),
                      ])
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE9F2FF),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  c.$1,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.blue,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(c.$2, style: const TextStyle(fontWeight: FontWeight.w800)),
                                    Text(c.$3, style: const TextStyle(color: AppColors.muted, fontSize: 12)),
                                  ],
                                ),
                              ),
                            ],
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

// ── Admisión / Registro de paciente ──────────────────────────────────────────
class _AdmisionPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppHeader(
          title: 'Admisión y Registro',
          subtitle: 'Registro de nuevos pacientes y asignación de turnos',
          actions: [
            FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFFFA927),
              ),
              onPressed: () {},
              icon: const Icon(Icons.save_outlined),
              label: const Text('Guardar admisión'),
            ),
          ],
        ),
        PageBody(
          child: ResponsiveRow(
            leftFlex: 6,
            rightFlex: 5,
            left: Panel(
              child: Column(
                children: [
                  const SectionTitle(Icons.person_outlined, 'Datos del paciente'),
                  Wrap(
                    spacing: 14,
                    runSpacing: 14,
                    children: [
                      InfoBox('NOMBRES', ''),
                      InfoBox('APELLIDOS', ''),
                      InfoBox('DNI', ''),
                      InfoBox('FECHA DE NACIMIENTO', ''),
                      InfoBox('SEXO', ''),
                      InfoBox('TELÉFONO', ''),
                    ],
                  ),
                  const SizedBox(height: 18),
                  const SectionTitle(Icons.location_on_outlined, 'Procedencia'),
                  const Wrap(
                    spacing: 14,
                    runSpacing: 14,
                    children: [
                      InfoBox('DISTRITO', ''),
                      InfoBox('PROVINCIA', ''),
                      InfoBox('DEPARTAMENTO', ''),
                    ],
                  ),
                ],
              ),
            ),
            right: Column(
              children: [
                Panel(
                  child: Column(
                    children: [
                      const SectionTitle(Icons.local_hospital_outlined, 'Asignación'),
                      Wrap(
                        spacing: 14,
                        runSpacing: 14,
                        children: const [
                          InfoBox('SEGURO', ''),
                          InfoBox('SERVICIO', ''),
                          InfoBox('TIPO ATENCIÓN', ''),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Panel(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SectionTitle(Icons.queue_outlined, 'Número de turno'),
                      Center(
                        child: Text(
                          'A-009',
                          style: const TextStyle(
                            fontSize: 64,
                            fontWeight: FontWeight.w900,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                      Center(
                        child: const Text(
                          'Medicina General · Turno asignado',
                          style: TextStyle(color: AppColors.muted),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ── Citas programadas ─────────────────────────────────────────────────────────
class _CitasPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppHeader(
          title: 'Citas Programadas',
          subtitle: 'Agenda del día · miércoles 10 jun 2026',
          actions: [
            FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFFFA927),
              ),
              onPressed: () {},
              icon: const Icon(Icons.add),
              label: const Text('Nueva cita'),
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
                      // Campo búsqueda: no usa SizedBox fijo, usa ConstrainedBox
                      ConstrainedBox(
                        constraints: const BoxConstraints(minWidth: 180, maxWidth: 320),
                        child: TextField(
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.search),
                            hintText: 'Buscar paciente o médico',
                            filled: true,
                            fillColor: const Color(0xFFF5F8FC),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            isDense: true,
                          ),
                        ),
                      ),
                      OutlinedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.filter_alt_outlined),
                        label: const Text('Todos los servicios'),
                      ),
                    ],
                  ),
                ),
                // DataTable en scroll horizontal para no desbordar en móvil
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    headingRowColor: WidgetStateProperty.all(
                      const Color(0xFFF4F7FB),
                    ),
                    columns: const [
                      DataColumn(label: Text('HORA')),
                      DataColumn(label: Text('PACIENTE')),
                      DataColumn(label: Text('SERVICIO')),
                      DataColumn(label: Text('MÉDICO')),
                      DataColumn(label: Text('ESTADO')),
                      DataColumn(label: Text('ACCIÓN')),
                    ],
                    rows: [
                      for (final r in [
                        ('08:00', 'Esteban Puma Chura', 'Cardiología', 'Dr. Martínez', 'Atendido'),
                        ('08:30', 'Juan Condori', 'Pediatría', 'Dra. Salas', 'Atendido'),
                        ('09:00', 'María Luque', 'Ginecología', 'Dra. Ramos', 'En espera'),
                        ('09:30', 'Ana Cáceres', 'Medicina', 'Dr. Martínez', 'Programada'),
                        ('10:00', 'Luis Mamani', 'Pediatría', 'Dra. Salas', 'Programada'),
                        ('11:00', 'Carmen Ríos', 'Ginecología', 'Dra. Ramos', 'Programada'),
                      ])
                        DataRow(cells: [
                          DataCell(Text(r.$1, style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.blue))),
                          DataCell(Text(r.$2, style: const TextStyle(fontWeight: FontWeight.w700))),
                          DataCell(Text(r.$3)),
                          DataCell(Text(r.$4, style: const TextStyle(color: AppColors.muted))),
                          DataCell(_EstadoCita(r.$5)),
                          DataCell(Row(children: [
                            IconButton(icon: const Icon(Icons.edit_outlined, size: 18), onPressed: () {}),
                            IconButton(icon: const Icon(Icons.cancel_outlined, size: 18, color: AppColors.red), onPressed: () {}),
                          ])),
                        ]),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _EstadoCita extends StatelessWidget {
  const _EstadoCita(this.estado);
  final String estado;

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (estado) {
      case 'Atendido':
        color = AppColors.green;
        break;
      case 'En espera':
        color = AppColors.orange;
        break;
      default:
        color = AppColors.blue;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        estado,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w800,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _AdminMetric extends StatelessWidget {
  const _AdminMetric(this.label, this.value, this.icon, this.bg, this.color);
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
