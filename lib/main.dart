import 'package:flutter/material.dart';
import 'admin/admin_shell.dart';
import 'core/user_session.dart';
import 'shells/medico_shell.dart';
import 'shells/enfermero_shell.dart';
import 'shells/administrativo_shell.dart';
import 'shells/paciente_shell.dart';
import 'shells/auditor_shell.dart';

import 'widgets/common_widgets.dart';
import 'pages/login_page.dart';
import 'pages/dashboard_page.dart';
import 'pages/patients_page.dart';
import 'pages/clinical_history_page.dart';
import 'pages/consultation_page.dart';
import 'pages/telemedicine_page.dart';
import 'pages/reports_page.dart';
import 'pages/prescription_page.dart';

void main() => runApp(const HceApp());

class HceApp extends StatelessWidget {
  const HceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'HCE Rural Salud',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.bg,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          primary: AppColors.primary,
          surface: Colors.white,
        ),
        fontFamily: 'Arial',
      ),
      initialRoute: '/',
      onGenerateRoute: (settings) {
        if (settings.name == '/home') {
          return MaterialPageRoute(
            builder: (_) {
              final rol = UserSession.instance.rol;
              switch (rol) {
                case UserRol.medico:
                  return const MedicoShell();
                case UserRol.enfermero:
                  return const EnfermeroShell();
                case UserRol.administrativo:
                  return const AdministrativoShell();
                case UserRol.paciente:
                  return const PacienteShell();
                case UserRol.auditor:
                  return const AuditorShell();
                case UserRol.administrador:
                  return const AdminShell();
              }
            },
            settings: settings,
          );
        }
        return MaterialPageRoute(
          builder: (_) => const LoginPage(),
          settings: settings,
        );
      },
    );
  }
}

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int index = 0;

  final pages = const [
    DashboardPage(),
    PatientsPage(),
    ClinicalHistoryPage(),
    ConsultationPage(),
    TelemedicinePage(),
    ReportsPage(),
    PrescriptionPage(),
  ];

  void _openAdmin(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const AdminShell()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final wide = c.maxWidth >= 980;
        return Scaffold(
          bottomNavigationBar: wide
              ? null
              : NavigationBar(
                  selectedIndex: index.clamp(0, 4),
                  onDestinationSelected: (i) {
                    if (i == 4) {
                      _openAdmin(context);
                    } else {
                      setState(() => index = i);
                    }
                  },
                  destinations: const [
                    NavigationDestination(
                      icon: Icon(Icons.dashboard_outlined),
                      label: 'Inicio',
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.people_outline),
                      label: 'Pacientes',
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.folder_shared_outlined),
                      label: 'HC',
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.medical_services_outlined),
                      label: 'Consulta',
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.admin_panel_settings_outlined),
                      label: 'Admin',
                    ),
                  ],
                ),
          body: Row(
            children: [
              if (wide)
                _SideBar(
                  index: index,
                  onSelect: (i) => setState(() => index = i),
                  onAdmin: () => _openAdmin(context),
                ),
              Expanded(child: pages[index]),
            ],
          ),
        );
      },
    );
  }
}

class _SideBar extends StatelessWidget {
  const _SideBar({
    required this.index,
    required this.onSelect,
    required this.onAdmin,
  });
  final int index;
  final ValueChanged<int> onSelect;
  final VoidCallback onAdmin;

  @override
  Widget build(BuildContext context) {
    final items = [
      ('PRINCIPAL', Icons.dashboard_outlined, 'Dashboard', 0, '', false),
      ('', Icons.people_outline, 'Pacientes', 1, '', false),
      ('', Icons.folder_shared_outlined, 'Historias Clínicas', 2, '', false),
      ('CLÍNICO', Icons.medical_services_outlined, 'Consultas', 3, '', false),
      ('', Icons.video_camera_front_outlined, 'Telemedicina', 4, '', false),
      ('', Icons.medication_outlined, 'Recetas', 6, '', false),
      ('GESTIÓN', Icons.bar_chart_outlined, 'Reportes', 5, '', false),
      ('', Icons.admin_panel_settings_outlined, 'Administración', -1, '', true),
    ];
    return Container(
      width: 310,
      color: AppColors.primary,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(26, 30, 20, 26),
            child: Row(
              children: const [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: AppColors.blue,
                  child: Icon(
                    Icons.health_and_safety_outlined,
                    color: Colors.white,
                  ),
                ),
                SizedBox(width: 14),
                Text(
                  'HCE\nRural Salud',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          const Divider(color: Color(0xFF31577D)),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 10),
              children: [
                for (final item in items) ...[
                  if (item.$1.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(26, 22, 26, 8),
                      child: Text(
                        item.$1,
                        style: const TextStyle(
                          color: Color(0xFF8EA6BF),
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.3,
                        ),
                      ),
                    ),
                  _NavTile(
                    icon: item.$2,
                    label: item.$3,
                    badge: item.$5,
                    selected: index == item.$4,
                    onTap: item.$6 ? onAdmin : () => onSelect(item.$4),
                  ),
                ],
              ],
            ),
          ),
          const Divider(color: Color(0xFF31577D)),
          _NavTile(
            icon: Icons.account_circle_outlined,
            label: 'Dr. A. Martínez',
            selected: false,
            onTap: () {},
          ),
          _NavTile(
            icon: Icons.logout,
            label: 'Cerrar sesión',
            selected: false,
            onTap: () => Navigator.of(context).pushReplacementNamed('/'),
          ),
          const SizedBox(height: 22),
        ],
      ),
    );
  }
}

class _NavTile extends StatelessWidget {
  const _NavTile({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
    this.badge = '',
  });
  final IconData icon;
  final String label;
  final bool selected;
  final String badge;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.primary2 : Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          height: 50,
          padding: const EdgeInsets.symmetric(horizontal: 26),
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(
                color: selected ? AppColors.blue : Colors.transparent,
                width: 3,
              ),
            ),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: selected ? Colors.white : const Color(0xFFB1C0D0),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: selected ? Colors.white : const Color(0xFFB1C0D0),
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (badge.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.blue,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(badge, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12)),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
