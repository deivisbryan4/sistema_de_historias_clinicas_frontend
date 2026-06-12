import 'package:flutter/material.dart';
import '../core/user_session.dart';
import '../widgets/common_widgets.dart';
import '../pages/clinical_history_page.dart';
import 'role_shell_base.dart';

// ─────────────────────────────────────────────────────────────────────────────
// SHELL PACIENTE — vista personal: Mi salud, Mi HC, Mis recetas, Mis citas
// ─────────────────────────────────────────────────────────────────────────────
class PacienteShell extends StatefulWidget {
  const PacienteShell({super.key});

  @override
  State<PacienteShell> createState() => _PacienteShellState();
}

class _PacienteShellState extends State<PacienteShell> {
  int _index = 0;

  static const _navItems = [
    RoleNavItem(
      icon: Icons.favorite_outline,
      label: 'Mi salud',
      section: 'MI PORTAL',
    ),
    RoleNavItem(
      icon: Icons.folder_shared_outlined,
      label: 'Mi historia clínica',
    ),
    RoleNavItem(
      icon: Icons.medication_outlined,
      label: 'Mis recetas',
    ),
    RoleNavItem(
      icon: Icons.video_camera_front_outlined,
      label: 'Mis citas / Telemed.',
      section: 'CITAS',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final pages = [
      _PacienteDashboard(),
      _MiHistoriaPage(),
      _MisRecetasPage(),
      _MisCitasPage(),
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
                    NavigationDestination(
                      icon: Icon(Icons.favorite_outline),
                      label: 'Mi salud',
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.folder_shared_outlined),
                      label: 'Mi HC',
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.medication_outlined),
                      label: 'Recetas',
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.video_camera_front_outlined),
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
                  accentColor: const Color(0xFFE84B4B),
                ),
              Expanded(child: pages[_index]),
            ],
          ),
        );
      },
    );
  }
}

// ── Mi salud (dashboard del paciente) ────────────────────────────────────────
class _PacienteDashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final session = UserSession.instance;
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(bottom: BorderSide(color: AppColors.line)),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: const Color(0xFFFFE8EC),
                child: Text(
                  session.initials,
                  style: const TextStyle(
                    color: Color(0xFFE84B4B),
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bienvenida, ${session.nombre}',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const Text(
                      'DNI 45782310 · N° HC: HC-2024-04521 · SIS Activo',
                      style: TextStyle(color: AppColors.muted),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F7EF),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFC5E8D5)),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.verified_outlined, color: AppColors.green, size: 16),
                    SizedBox(width: 6),
                    Text(
                      'SIS Activo',
                      style: TextStyle(
                        color: AppColors.green,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        PageBody(
          child: Column(
            children: [
              // Alertas médicas destacadas
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFE8EC),
                  border: Border.all(color: const Color(0xFFFFB3BB)),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.warning_amber, color: AppColors.red),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '⚠️ Alerta médica activa',
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              color: AppColors.red,
                            ),
                          ),
                          Text(
                            'Alergia a penicilina · HTA en control',
                            style: TextStyle(color: AppColors.red),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // Mis últimos signos vitales
              Panel(
                child: Column(
                  children: [
                    const SectionTitle(
                      Icons.monitor_heart_outlined,
                      'Mis últimos signos vitales',
                    ),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: const [
                        VitalBox('148/92', 'mmHg', 'Presión arterial', AppColors.red),
                        VitalBox('76', 'lpm', 'Frec. cardiaca', AppColors.green),
                        VitalBox('36.8', '°C', 'Temperatura', AppColors.green),
                        VitalBox('98', 'SatO₂', '', AppColors.orange),
                        VitalBox('63', 'kg', 'Peso', AppColors.green),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Registrado el 09/06/2026 por Lic. Carmen Flores',
                      style: TextStyle(color: AppColors.muted, fontSize: 13),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              ResponsiveRow(
                left: Panel(
                  child: Column(
                    children: [
                      const SectionTitle(
                        Icons.medication_outlined,
                        'Mi tratamiento actual',
                      ),
                      MedicineBox(
                        'Metformina 850mg',
                        '1 tableta c/12h con alimentos · 30 días',
                        '850mg',
                      ),
                      const SizedBox(height: 10),
                      MedicineBox(
                        'Enalapril 10mg',
                        '1 tableta c/24h en ayunas · 30 días',
                        '10mg',
                      ),
                      const SizedBox(height: 14),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.medication_outlined),
                          label: const Text('Ver todas mis recetas'),
                        ),
                      ),
                    ],
                  ),
                ),
                right: Panel(
                  child: Column(
                    children: [
                      SectionTitle(
                        Icons.calendar_today_outlined,
                        'Próximas citas',
                        action: TextButton(
                          onPressed: () {},
                          child: const Text('Ver agenda'),
                        ),
                      ),
                      _CitaPaciente(
                        'Medicina General',
                        'Dr. Alejandro Martínez',
                        '16 jun 2026 · 09:00 am',
                        const Color(0xFF2F7DE1),
                      ),
                      _CitaPaciente(
                        'Control HTA',
                        'Dr. Alejandro Martínez',
                        '30 jun 2026 · 08:30 am',
                        const Color(0xFF2F8A5B),
                      ),
                      const SizedBox(height: 14),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFFE84B4B),
                          ),
                          onPressed: () {},
                          icon: const Icon(Icons.video_call_outlined),
                          label: const Text('Solicitar teleconsulta'),
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

// ── Mi Historia Clínica ────────────────────────────────────────────────────────
class _MiHistoriaPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppHeader(
          title: 'Mi Historia Clínica',
          subtitle: 'Rosa Villanueva Quispe · HC-2024-04521',
          actions: [
            OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.download_outlined),
              label: const Text('Descargar PDF'),
            ),
          ],
        ),
        PageBody(
          child: ResponsiveRow(
            leftFlex: 4,
            rightFlex: 9,
            left: Column(
              children: const [
                PatientProfileCard(),
                SizedBox(height: 14),
                AlertCard(),
                SizedBox(height: 14),
                ContactCard(),
              ],
            ),
            right: Panel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SectionTitle(Icons.history, 'Historial de consultas'),
                  for (final c in [
                    ('09/06/2026', 'Hipertensión — Control', 'Dr. Martínez', 'Completada'),
                    ('02/06/2026', 'HTA — Control mensual', 'Dr. Martínez', 'Completada'),
                    ('10/05/2026', 'Diabetes tipo 2 — Control', 'Dr. Martínez', 'Completada'),
                    ('18/04/2026', 'HTA — Ajuste de dosis', 'Dr. Martínez', 'Completada'),
                  ])
                    Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF7FAFE),
                        border: Border.all(color: AppColors.line),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE9F2FF),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.medical_services_outlined, color: AppColors.blue, size: 18),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(c.$2, style: const TextStyle(fontWeight: FontWeight.w800)),
                                Text('${c.$3} · ${c.$1}', style: const TextStyle(color: AppColors.muted, fontSize: 13)),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE8F7EF),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(c.$4, style: const TextStyle(color: AppColors.green, fontWeight: FontWeight.w700, fontSize: 12)),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Mis Recetas ────────────────────────────────────────────────────────────────
class _MisRecetasPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppHeader(
          title: 'Mis Recetas',
          subtitle: 'Recetas médicas electrónicas — Rosa Villanueva Quispe',
          actions: const [],
        ),
        PageBody(
          child: Column(
            children: [
              for (final receta in [
                ('RX-2026-00142', '09/06/2026', 'Dr. Alejandro Martínez', 'Vigente', [
                  ('Metformina 850mg', '1 tab c/12h · 30 días'),
                  ('Enalapril 10mg', '1 tab c/24h · 30 días'),
                ]),
                ('RX-2026-00089', '02/06/2026', 'Dr. Alejandro Martínez', 'Dispensada', [
                  ('Metformina 850mg', '1 tab c/12h · 30 días'),
                ]),
              ])
                Column(
                  children: [
                    Panel(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.receipt_long_outlined, color: AppColors.primary),
                              const SizedBox(width: 10),
                              Text(
                                receta.$1,
                                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
                              ),
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: receta.$4 == 'Vigente'
                                      ? const Color(0xFFE8F7EF)
                                      : const Color(0xFFF5F8FC),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  receta.$4,
                                  style: TextStyle(
                                    color: receta.$4 == 'Vigente' ? AppColors.green : AppColors.muted,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${receta.$3} · ${receta.$2}',
                            style: const TextStyle(color: AppColors.muted),
                          ),
                          const Divider(height: 24),
                          for (final med in receta.$5)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Row(
                                children: [
                                  const Icon(Icons.medication_outlined, color: AppColors.blue, size: 18),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(med.$1, style: const TextStyle(fontWeight: FontWeight.w800)),
                                        Text(med.$2, style: const TextStyle(color: AppColors.muted, fontSize: 13)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          if (receta.$4 == 'Vigente')
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton.icon(
                                onPressed: () {},
                                icon: const Icon(Icons.download_outlined, size: 16),
                                label: const Text('Descargar receta PDF'),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Mis Citas ──────────────────────────────────────────────────────────────────
class _MisCitasPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppHeader(
          title: 'Mis Citas y Teleconsultas',
          subtitle: 'Rosa Villanueva Quispe — agenda personal',
          actions: [
            FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFE84B4B),
              ),
              onPressed: () {},
              icon: const Icon(Icons.video_call_outlined),
              label: const Text('Solicitar teleconsulta'),
            ),
          ],
        ),
        PageBody(
          child: Column(
            children: [
              Panel(
                child: Column(
                  children: [
                    const SectionTitle(Icons.calendar_today_outlined, 'Próximas citas'),
                    _CitaPaciente(
                      'Medicina General — Control HTA',
                      'Dr. Alejandro Martínez',
                      '16 jun 2026 · 09:00 am · Presencial',
                      const Color(0xFF2F7DE1),
                    ),
                    _CitaPaciente(
                      'Control Diabetes',
                      'Dr. Alejandro Martínez',
                      '30 jun 2026 · 08:30 am · Teleconsulta',
                      const Color(0xFFE84B4B),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFFE84B4B),
                        ),
                        onPressed: () {},
                        icon: const Icon(Icons.video_call_outlined),
                        label: const Text('Unirse a teleconsulta'),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              Panel(
                child: Column(
                  children: [
                    const SectionTitle(Icons.history, 'Historial de teleconsultas'),
                    for (final t in [
                      ('02/06/2026', 'Control HTA', 'Dr. Martínez', '24 min', 'Completada'),
                      ('10/05/2026', 'Diabetes tipo 2', 'Dr. Martínez', '18 min', 'Completada'),
                    ])
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          children: [
                            const CircleAvatar(
                              backgroundColor: Color(0xFFE9F2FF),
                              child: Icon(Icons.video_call_outlined, color: AppColors.blue),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(t.$2, style: const TextStyle(fontWeight: FontWeight.w800)),
                                  Text('${t.$3} · ${t.$1} · ${t.$4}', style: const TextStyle(color: AppColors.muted, fontSize: 13)),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE8F7EF),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(t.$5, style: const TextStyle(color: AppColors.green, fontWeight: FontWeight.w700, fontSize: 12)),
                            ),
                          ],
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

class _CitaPaciente extends StatelessWidget {
  const _CitaPaciente(this.titulo, this.medico, this.detalle, this.color);
  final String titulo;
  final String medico;
  final String detalle;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .06),
        border: Border.all(color: color.withValues(alpha: .3)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: color.withValues(alpha: .15),
            child: Icon(Icons.calendar_today_outlined, color: color, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(titulo, style: const TextStyle(fontWeight: FontWeight.w800)),
                Text(medico, style: TextStyle(color: color, fontSize: 13)),
                Text(detalle, style: const TextStyle(color: AppColors.muted, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
