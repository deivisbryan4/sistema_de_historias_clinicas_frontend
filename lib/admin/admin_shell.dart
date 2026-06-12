import 'package:flutter/material.dart';
import 'pages/admin_dashboard_page.dart';
import 'pages/users_list_page.dart';
import 'pages/roles_page.dart';
import 'pages/areas_page.dart';
import 'pages/establishments_page.dart';
import 'pages/audit_page.dart';
import '../pages/dataset_analytics_page.dart';

class AdminShell extends StatefulWidget {
  const AdminShell({super.key});

  @override
  State<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends State<AdminShell> {
  int _index = 0;

  static const _pages = [
    AdminDashboardPage(),
    UsersListPage(),
    RolesPage(),
    AreasPage(),
    EstablishmentsPage(),
    AuditPage(),
    DatasetAnalyticsPage(),
  ];

  static const _navItems = [
    _NavItem(Icons.dashboard_outlined, Icons.dashboard, 'Dashboard'),
    _NavItem(Icons.people_outline, Icons.people, 'Usuarios'),
    _NavItem(Icons.policy_outlined, Icons.policy, 'Roles'),
    _NavItem(Icons.domain_outlined, Icons.domain, 'Áreas'),
    _NavItem(Icons.local_hospital_outlined, Icons.local_hospital, 'Establec.'),
    _NavItem(Icons.security_outlined, Icons.security, 'Auditoría'),
    _NavItem(Icons.sync_alt_outlined, Icons.sync_alt, 'FHIR & Intercambio'),
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 760;
        return Scaffold(
          backgroundColor: const Color(0xFFEAF0F6),
          bottomNavigationBar: isWide
              ? null
              : NavigationBar(
                  selectedIndex: _index,
                  onDestinationSelected: (i) => setState(() => _index = i),
                  labelBehavior:
                      NavigationDestinationLabelBehavior.onlyShowSelected,
                  destinations: _navItems
                      .map(
                        (item) => NavigationDestination(
                          icon: Icon(item.icon),
                          selectedIcon: Icon(item.selectedIcon),
                          label: item.label,
                        ),
                      )
                      .toList(),
                ),
          body: Row(
            children: [
              if (isWide)
                _AdminSidebar(
                  index: _index,
                  onSelect: (i) => setState(() => _index = i),
                  items: _navItems,
                ),
              Expanded(child: _pages[_index]),
            ],
          ),
        );
      },
    );
  }
}

class _AdminSidebar extends StatelessWidget {
  const _AdminSidebar({
    required this.index,
    required this.onSelect,
    required this.items,
  });

  final int index;
  final ValueChanged<int> onSelect;
  final List<_NavItem> items;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      decoration: const BoxDecoration(
        color: Color(0xFF1C3A5E),
        border: Border(right: BorderSide(color: Color(0xFF254E7E))),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.fromLTRB(20, 20, 16, 18),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Color(0xFF254E7E))),
            ),
            child: Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: const Color(0xFF2F7DE1).withValues(alpha: .25),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.admin_panel_settings_outlined,
                    color: Color(0xFF7FBAFF),
                    size: 18,
                  ),
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'Administración',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Nav items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: items.asMap().entries.map((entry) {
                final i = entry.key;
                final item = entry.value;
                final selected = index == i;
                return _SidebarTile(
                  icon: selected ? item.selectedIcon : item.icon,
                  label: item.label,
                  selected: selected,
                  onTap: () => onSelect(i),
                );
              }).toList(),
            ),
          ),

          // Back to main
          const Divider(color: Color(0xFF254E7E), height: 1),
          _SidebarTile(
            icon: Icons.arrow_back_outlined,
            label: 'Volver al sistema',
            selected: false,
            onTap: () {
              // Pop the AdminShell so the parent HomeShell handles navigation
              if (Navigator.canPop(context)) {
                Navigator.pop(context);
              }
            },
            color: const Color(0xFF8EA6BF),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}

class _SidebarTile extends StatelessWidget {
  const _SidebarTile({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
    this.color,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final fg = color ?? (selected ? Colors.white : const Color(0xFFB1C0D0));
    return Material(
      color: selected ? const Color(0xFF254E7E) : Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          height: 46,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(
                color: selected ? const Color(0xFF2F7DE1) : Colors.transparent,
                width: 3,
              ),
            ),
          ),
          child: Row(
            children: [
              Icon(icon, size: 19, color: fg),
              const SizedBox(width: 12),
              Text(
                label,
                style: TextStyle(
                  color: fg,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  const _NavItem(this.icon, this.selectedIcon, this.label);
  final IconData icon;
  final IconData selectedIcon;
  final String label;
}
