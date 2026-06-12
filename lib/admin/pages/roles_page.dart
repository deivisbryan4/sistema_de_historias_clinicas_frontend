import 'package:flutter/material.dart';
import '../admin_models.dart';
import '../admin_mock_data.dart';
import '../widgets/permission_matrix.dart';

// ═══════════════════════════════════════════════════════════════════════════════
// ROLES Y PERMISOS — Visual de tarjetas de rol + matriz de permisos expandida
// Diseño: Layout de 2 columnas: tarjetas de roles a la izq, configuración a la der
// Completamente diferente a la vista de usuarios (dark cards, access badges, etc)
// ═══════════════════════════════════════════════════════════════════════════════

class RolesPage extends StatefulWidget {
  const RolesPage({super.key});

  @override
  State<RolesPage> createState() => _RolesPageState();
}

class _RolesPageState extends State<RolesPage> {
  UserRole _selectedRole = UserRole.administrador;

  static const _roleData = {
    UserRole.administrador: _RoleInfo(
      icon: Icons.admin_panel_settings,
      description: 'Acceso completo al sistema. Puede crear, modificar y eliminar cualquier recurso.',
      gradient: [Color(0xFF173E63), Color(0xFF254E7E)],
      level: 5,
    ),
    UserRole.medico: _RoleInfo(
      icon: Icons.medical_services,
      description: 'Acceso a HC, consultas y recetas. Puede firmar documentos médicos.',
      gradient: [Color(0xFF1A5FC4), Color(0xFF2F7DE1)],
      level: 4,
    ),
    UserRole.auditor: _RoleInfo(
      icon: Icons.policy,
      description: 'Solo lectura de todos los módulos. Puede exportar reportes de auditoría.',
      gradient: [Color(0xFF5A2FA0), Color(0xFF7A4FC3)],
      level: 3,
    ),
    UserRole.enfermero: _RoleInfo(
      icon: Icons.local_hospital,
      description: 'Acceso a signos vitales y seguimiento. Sin acceso a prescripción.',
      gradient: [Color(0xFF1F7549), Color(0xFF2F8A5B)],
      level: 2,
    ),
    UserRole.administrativo: _RoleInfo(
      icon: Icons.badge,
      description: 'Registro y admisión. Sin acceso a módulos clínicos avanzados.',
      gradient: [Color(0xFFB87010), Color(0xFFFFA927)],
      level: 1,
    ),
  };

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildHeader(),
        Expanded(
          child: LayoutBuilder(
            builder: (context, c) {
              if (c.maxWidth < 820) {
                return _buildMobileLayout();
              }
              return _buildDesktopLayout();
            },
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      color: const Color(0xFF0F2A42),
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: .08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.policy_outlined,
              color: Color(0xFF7FBAFF),
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Roles y Permisos',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  'Define qué puede hacer cada rol en el sistema',
                  style: TextStyle(color: Color(0xFF8EA6BF), fontSize: 13),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF2F7DE1).withValues(alpha: .2),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFF2F7DE1).withValues(alpha: .4)),
            ),
            child: const Row(
              children: [
                Icon(Icons.shield_outlined, size: 14, color: Color(0xFF7FBAFF)),
                SizedBox(width: 6),
                Text(
                  '5 roles definidos',
                  style: TextStyle(color: Color(0xFF7FBAFF), fontSize: 12, fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left panel — role cards
        Container(
          width: 300,
          color: const Color(0xFF0F2A42),
          child: _buildRoleCardList(),
        ),
        // Right panel — permissions
        Expanded(
          child: Container(
            color: const Color(0xFFF0F5FB),
            child: _buildPermissionsPanel(),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout() {
    return Column(
      children: [
        Container(
          height: 170,
          color: const Color(0xFF0F2A42),
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            children: UserRole.values
                .map(
                  (r) => Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: _RoleCardCompact(
                      role: r,
                      info: _roleData[r]!,
                      selected: _selectedRole == r,
                      userCount: mockUsers.where((u) => u.rol == r).length,
                      onTap: () => setState(() => _selectedRole = r),
                    ),
                  ),
                )
                .toList(),
          ),
        ),
        Expanded(child: _buildPermissionsPanel()),
      ],
    );
  }

  Widget _buildRoleCardList() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Padding(
          padding: EdgeInsets.only(bottom: 12),
          child: Text(
            'SELECCIONA UN ROL',
            style: TextStyle(
              color: Color(0xFF486D91),
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
            ),
          ),
        ),
        ...UserRole.values.map((r) {
          final info = _roleData[r]!;
          final count = mockUsers.where((u) => u.rol == r).length;
          final selected = _selectedRole == r;
          return _RoleCardFull(
            role: r,
            info: info,
            userCount: count,
            selected: selected,
            onTap: () => setState(() => _selectedRole = r),
          );
        }),
      ],
    );
  }

  Widget _buildPermissionsPanel() {
    final roleDef = mockRoles.firstWhere((r) => r.role == _selectedRole);
    final info = _roleData[_selectedRole]!;
    final userCount = mockUsers.where((u) => u.rol == _selectedRole).length;

    return SingleChildScrollView(
      child: Column(
        children: [
          // Role hero banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: info.gradient,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: .15),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(info.icon, color: Colors.white, size: 30),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _selectedRole.label,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      Text(
                        info.description,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: .8),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: .2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '$userCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'usuario${userCount != 1 ? 's' : ''}',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: .7),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Access level bar
          Container(
            padding: const EdgeInsets.all(20),
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      'Nivel de acceso',
                      style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
                    ),
                    const Spacer(),
                    Text(
                      '${info.level} / 5',
                      style: TextStyle(
                        color: info.gradient[0],
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: List.generate(5, (i) {
                    final filled = i < info.level;
                    return Expanded(
                      child: Container(
                        margin: EdgeInsets.only(right: i < 4 ? 4 : 0),
                        height: 8,
                        decoration: BoxDecoration(
                          color: filled ? info.gradient[0] : const Color(0xFFEAF0F6),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 16),
                // Module quick access summary
                _buildModuleSummary(roleDef),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Permissions matrix
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFD4E0EC)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.tune_outlined, size: 18, color: info.gradient[0]),
                    const SizedBox(width: 8),
                    const Text(
                      'Matriz de permisos',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0F5FB),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'Editable',
                        style: TextStyle(
                          color: Color(0xFF637995),
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                const Text(
                  'Activa o desactiva permisos por módulo. Los cambios afectan a todos los usuarios de este rol.',
                  style: TextStyle(color: Color(0xFF637995), fontSize: 12),
                ),
                const SizedBox(height: 16),
                PermissionMatrix(roleDefinition: roleDef),
              ],
            ),
          ),

          // Users in this role
          Padding(
            padding: const EdgeInsets.all(16),
            child: _buildUsersInRole(userCount),
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildModuleSummary(RoleDefinition roleDef) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'ACCESO POR MÓDULO',
          style: TextStyle(
            color: Color(0xFF637995),
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.1,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: roleDef.permissions.map((p) {
            final accessCount = [p.ver, p.crear, p.editar, p.eliminar, p.exportar, p.aprobarFirmar]
                .where((x) => x)
                .length;
            final hasAccess = accessCount > 0;
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: hasAccess
                    ? _roleData[_selectedRole]!.gradient[0].withValues(alpha: .08)
                    : const Color(0xFFF4F7FB),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: hasAccess
                      ? _roleData[_selectedRole]!.gradient[0].withValues(alpha: .25)
                      : const Color(0xFFD4E0EC),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    hasAccess ? Icons.check_circle_outline : Icons.block_outlined,
                    size: 13,
                    color: hasAccess
                        ? _roleData[_selectedRole]!.gradient[0]
                        : const Color(0xFFB1C0D0),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    p.module,
                    style: TextStyle(
                      color: hasAccess
                          ? _roleData[_selectedRole]!.gradient[0]
                          : const Color(0xFFB1C0D0),
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (hasAccess) ...[
                    const SizedBox(width: 5),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                      decoration: BoxDecoration(
                        color: _roleData[_selectedRole]!.gradient[0].withValues(alpha: .15),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '$accessCount',
                        style: TextStyle(
                          color: _roleData[_selectedRole]!.gradient[0],
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildUsersInRole(int userCount) {
    if (userCount == 0) return const SizedBox.shrink();
    final users = mockUsers.where((u) => u.rol == _selectedRole).toList();
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFD4E0EC)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Usuarios con este rol',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: _roleData[_selectedRole]!.gradient[0].withValues(alpha: .1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '$userCount',
                  style: TextStyle(
                    color: _roleData[_selectedRole]!.gradient[0],
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...users.map(
            (u) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          _roleData[_selectedRole]!.gradient[0],
                          _roleData[_selectedRole]!.gradient[1],
                        ],
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        u.initials,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          u.nombreCompleto,
                          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                        ),
                        Text(
                          '${u.cargo} · ${u.area}',
                          style: const TextStyle(color: Color(0xFF637995), fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: u.estado.color,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Role Card (Full — for sidebar) ──────────────────────────────────────────

class _RoleCardFull extends StatelessWidget {
  const _RoleCardFull({
    required this.role,
    required this.info,
    required this.userCount,
    required this.selected,
    required this.onTap,
  });
  final UserRole role;
  final _RoleInfo info;
  final int userCount;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: selected
              ? LinearGradient(colors: info.gradient)
              : null,
          color: selected ? null : const Color(0xFF152D45),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected
                ? Colors.transparent
                : const Color(0xFF1E3E5A),
            width: 1.5,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: info.gradient[0].withValues(alpha: .4),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: selected
                    ? Colors.white.withValues(alpha: .2)
                    : info.gradient[0].withValues(alpha: .2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                info.icon,
                color: selected ? Colors.white : info.gradient[0],
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    role.label,
                    style: TextStyle(
                      color: selected ? Colors.white : const Color(0xFFD0DFF0),
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                    ),
                  ),
                  Row(
                    children: [
                      // Access level dots
                      ...List.generate(
                        5,
                        (i) => Container(
                          margin: const EdgeInsets.only(right: 3, top: 4),
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: i < info.level
                                ? (selected ? Colors.white : info.gradient[0])
                                : (selected
                                    ? Colors.white.withValues(alpha: .3)
                                    : const Color(0xFF1E3E5A)),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Nivel ${info.level}',
                        style: TextStyle(
                          color: selected
                              ? Colors.white.withValues(alpha: .7)
                              : const Color(0xFF637995),
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: selected
                    ? Colors.white.withValues(alpha: .2)
                    : const Color(0xFF1A3A55),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '$userCount',
                style: TextStyle(
                  color: selected ? Colors.white : const Color(0xFF8EA6BF),
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Role Card (Compact — for mobile horizontal list) ─────────────────────────

class _RoleCardCompact extends StatelessWidget {
  const _RoleCardCompact({
    required this.role,
    required this.info,
    required this.userCount,
    required this.selected,
    required this.onTap,
  });
  final UserRole role;
  final _RoleInfo info;
  final int userCount;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 130,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: selected ? LinearGradient(colors: info.gradient) : null,
          color: selected ? null : const Color(0xFF152D45),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? Colors.transparent : const Color(0xFF1E3E5A),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(info.icon, color: Colors.white, size: 28),
            const SizedBox(height: 8),
            Text(
              role.label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w800,
                shadows: selected
                    ? [const Shadow(color: Colors.black26, blurRadius: 4)]
                    : [],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '$userCount usuario${userCount != 1 ? 's' : ''}',
              style: TextStyle(
                color: Colors.white.withValues(alpha: .7),
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Data class ───────────────────────────────────────────────────────────────

class _RoleInfo {
  const _RoleInfo({
    required this.icon,
    required this.description,
    required this.gradient,
    required this.level,
  });
  final IconData icon;
  final String description;
  final List<Color> gradient;
  final int level; // 1–5
}
