import 'package:flutter/material.dart';
import '../core/user_session.dart';
import '../pages/login_page.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Shell base compartido por todos los roles
// ─────────────────────────────────────────────────────────────────────────────
abstract class RoleShell extends StatefulWidget {
  const RoleShell({super.key});
}

// ─────────────────────────────────────────────────────────────────────────────
// SIDEBAR genérico reutilizable por todos los shells de rol
// ─────────────────────────────────────────────────────────────────────────────
class RoleSideBar extends StatelessWidget {
  const RoleSideBar({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.onSelect,
    this.accentColor = const Color(0xFF2F7DE1),
  });

  final List<RoleNavItem> items;
  final int selectedIndex;
  final ValueChanged<int> onSelect;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    final session = UserSession.instance;
    return Container(
      width: 290,
      color: const Color(0xFF173E63),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.fromLTRB(24, 30, 20, 20),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Color(0xFF31577D))),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: accentColor,
                  child: Text(
                    session.initials,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        session.nombre,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Container(
                        margin: const EdgeInsets.only(top: 4),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: accentColor.withValues(alpha: .25),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          session.rol.label,
                          style: TextStyle(
                            color: accentColor,
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Logo
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 18, 24, 14),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: accentColor,
                  child: const Icon(
                    Icons.health_and_safety_outlined,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'HCE Rural Salud',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          const Divider(color: Color(0xFF31577D), height: 1),
          // Nav items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 10),
              children: [
                for (int i = 0; i < items.length; i++) ...[
                  if (items[i].section != null)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 20, 24, 6),
                      child: Text(
                        items[i].section!,
                        style: const TextStyle(
                          color: Color(0xFF8EA6BF),
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.3,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  _NavTile(
                    icon: items[i].icon,
                    label: items[i].label,
                    badge: items[i].badge,
                    selected: selectedIndex == i,
                    accentColor: accentColor,
                    onTap: () => onSelect(i),
                  ),
                ],
              ],
            ),
          ),
          const Divider(color: Color(0xFF31577D), height: 1),
          // Logout
          _NavTile(
            icon: Icons.logout,
            label: 'Cerrar sesión',
            selected: false,
            accentColor: accentColor,
            onTap: () {
              UserSession.instance.logout();
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const LoginPage()),
              );
            },
          ),
          const SizedBox(height: 14),
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
    required this.accentColor,
    this.badge = '',
  });
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Color accentColor;
  final String badge;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? const Color(0xFF23548A) : Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(
                color: selected ? accentColor : Colors.transparent,
                width: 3,
              ),
            ),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 20,
                color: selected ? Colors.white : const Color(0xFFB1C0D0),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: selected ? Colors.white : const Color(0xFFB1C0D0),
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (badge.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: accentColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    badge,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class RoleNavItem {
  const RoleNavItem({
    required this.icon,
    required this.label,
    this.section,
    this.badge = '',
  });
  final IconData icon;
  final String label;
  final String? section;
  final String badge;
}
