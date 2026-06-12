import 'package:flutter/material.dart';
import '../widgets/common_widgets.dart';
import '../pages/dashboard_page.dart';
import '../pages/patients_page.dart';
import '../pages/clinical_history_page.dart';
import '../pages/consultation_page.dart';
import '../pages/telemedicine_page.dart';
import '../pages/prescription_page.dart';
import '../pages/reports_page.dart';
import '../pages/dataset_analytics_page.dart';
import 'role_shell_base.dart';

// ─────────────────────────────────────────────────────────────────────────────
// SHELL MÉDICO — acceso completo al módulo clínico
// Módulos: Dashboard, Pacientes, Historia Clínica, Consultas,
//           Telemedicina, Recetas, Reportes
// ─────────────────────────────────────────────────────────────────────────────
class MedicoShell extends StatefulWidget {
  const MedicoShell({super.key});

  @override
  State<MedicoShell> createState() => _MedicoShellState();
}

class _MedicoShellState extends State<MedicoShell> {
  int _index = 0;

  static const _navItems = [
    RoleNavItem(
      icon: Icons.dashboard_outlined,
      label: 'Dashboard',
      section: 'PRINCIPAL',
    ),
    RoleNavItem(
      icon: Icons.people_outline,
      label: 'Pacientes',
      badge: '4,280',
    ),
    RoleNavItem(
      icon: Icons.folder_shared_outlined,
      label: 'Historias Clínicas',
    ),
    RoleNavItem(
      icon: Icons.medical_services_outlined,
      label: 'Consultas',
      section: 'CLÍNICO',
      badge: '18',
    ),
    RoleNavItem(
      icon: Icons.video_camera_front_outlined,
      label: 'Telemedicina',
    ),
    RoleNavItem(
      icon: Icons.medication_outlined,
      label: 'Recetas',
    ),
    RoleNavItem(
      icon: Icons.bar_chart_outlined,
      label: 'Reportes',
      section: 'GESTIÓN',
    ),
    RoleNavItem(
      icon: Icons.sync_alt_outlined,
      label: 'Intercambio Rural & FHIR',
      section: 'HL7 FHIR',
    ),
  ];

  final _pages = const [
    DashboardPage(),
    PatientsPage(),
    ClinicalHistoryPage(),
    ConsultationPage(),
    TelemedicinePage(),
    PrescriptionPage(),
    ReportsPage(),
    DatasetAnalyticsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final wide = c.maxWidth >= 960;
        return Scaffold(
          backgroundColor: AppColors.bg,
          bottomNavigationBar: wide
              ? null
              : NavigationBar(
                  selectedIndex: _index.clamp(0, 4),
                  onDestinationSelected: (i) => setState(() => _index = i),
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
                      icon: Icon(Icons.medication_outlined),
                      label: 'Recetas',
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
                  accentColor: const Color(0xFF2F7DE1),
                ),
              Expanded(child: _pages[_index]),
            ],
          ),
        );
      },
    );
  }
}
