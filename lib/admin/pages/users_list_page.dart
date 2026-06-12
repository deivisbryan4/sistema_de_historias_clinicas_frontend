import 'package:flutter/material.dart';
import '../admin_models.dart';
import '../admin_api_service.dart';
import '../widgets/user_status_badge.dart';
import 'user_form_page.dart';

// ═══════════════════════════════════════════════════════════════════════════════
// GESTIÓN DE USUARIOS — Vista de directorio con perfiles visuales
// Diseño: Barra de métricas + Tabs de rol + Grid de tarjetas de personal
// ═══════════════════════════════════════════════════════════════════════════════

class UsersListPage extends StatefulWidget {
  const UsersListPage({super.key});

  @override
  State<UsersListPage> createState() => _UsersListPageState();
}

class _UsersListPageState extends State<UsersListPage>
    with SingleTickerProviderStateMixin {
  List<AppUser> _users = [];
  bool _loading = true;
  String? _loadError;

  String _searchQuery = '';
  UserRole? _filterRole;
  UserStatus? _filterStatus;
  bool _gridView = true;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {
          _filterRole = _tabController.index == 0
              ? null
              : UserRole.values[_tabController.index - 1];
        });
      }
    });
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() { _loading = true; _loadError = null; });
    try {
      final list = await AdminApiService.getUsers();
      setState(() { _users = list; _loading = false; });
    } catch (e) {
      setState(() { _loadError = e.toString(); _loading = false; });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<AppUser> get _filteredUsers {
    return _users.where((u) {
      final q = _searchQuery.toLowerCase();
      final matchesSearch = q.isEmpty ||
          u.nombreCompleto.toLowerCase().contains(q) ||
          u.dni.contains(q) ||
          u.email.toLowerCase().contains(q) ||
          u.area.toLowerCase().contains(q);
      final matchesRole = _filterRole == null || u.rol == _filterRole;
      final matchesStatus = _filterStatus == null || u.estado == _filterStatus;
      return matchesSearch && matchesRole && matchesStatus;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_loadError != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Color(0xFFE84B4B)),
            const SizedBox(height: 12),
            const Text('Error al cargar usuarios', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
            Text(_loadError!, style: const TextStyle(color: Color(0xFF637995))),
            const SizedBox(height: 16),
            FilledButton.icon(onPressed: _loadUsers, icon: const Icon(Icons.refresh), label: const Text('Reintentar')),
          ],
        ),
      );
    }
    final filtered = _filteredUsers;
    final activos = _users.where((u) => u.estado == UserStatus.activo).length;
    final inactivos = _users.where((u) => u.estado == UserStatus.inactivo).length;
    final suspendidos = _users.where((u) => u.estado == UserStatus.suspendido).length;

    return Column(
      children: [
        // ── Gradient header ─────────────────────────────────────────
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF173E63), Color(0xFF23548A)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            children: [
              // Title bar
              Padding(
                padding: const EdgeInsets.fromLTRB(28, 20, 20, 12),
                child: Row(
                  children: [
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Directorio de Personal',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          Text(
                            'Gestión de usuarios del sistema HCE',
                            style: TextStyle(
                              color: Color(0xFFB7C6D7),
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Color(0xFF486D91)),
                      ),
                      onPressed: () => setState(() => _gridView = !_gridView),
                      icon: Icon(
                        _gridView
                            ? Icons.view_list_outlined
                            : Icons.grid_view_outlined,
                        size: 16,
                      ),
                      label: Text(_gridView ? 'Lista' : 'Cuadrícula'),
                    ),
                    const SizedBox(width: 8),
                    FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF2F7DE1),
                      ),
                      onPressed: () => _openForm(context, null),
                      icon: const Icon(Icons.person_add_outlined, size: 16),
                      label: const Text('Nuevo usuario'),
                    ),
                  ],
                ),
              ),

              // Stats strip
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
                child: Row(
                  children: [
                    _StatChip(
                      label: 'Total',
                      value: '${_users.length}',
                      color: Colors.white,
                    ),
                    const SizedBox(width: 10),
                    _StatChip(
                      label: 'Activos',
                      value: '$activos',
                      color: const Color(0xFF4ADEA0),
                    ),
                    const SizedBox(width: 10),
                    _StatChip(
                      label: 'Inactivos',
                      value: '$inactivos',
                      color: const Color(0xFF8EA6BF),
                    ),
                    const SizedBox(width: 10),
                    _StatChip(
                      label: 'Suspendidos',
                      value: '$suspendidos',
                      color: const Color(0xFFFF7A7A),
                    ),
                  ],
                ),
              ),

              // Role tabs
              TabBar(
                controller: _tabController,
                isScrollable: true,
                tabAlignment: TabAlignment.start,
                labelColor: Colors.white,
                unselectedLabelColor: const Color(0xFF8EA6BF),
                indicatorColor: const Color(0xFF2F7DE1),
                indicatorWeight: 3,
                tabs: [
                  const Tab(text: 'Todos'),
                  ...UserRole.values.map(
                    (r) => Tab(
                      text: r.label,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // ── Search + status filter bar ───────────────────────────────
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          color: Colors.white,
          child: Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 40,
                  child: TextField(
                    onChanged: (v) => setState(() => _searchQuery = v),
                    style: const TextStyle(fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'Buscar por nombre, DNI, correo o área…',
                      hintStyle: const TextStyle(fontSize: 13),
                      prefixIcon: const Icon(Icons.search, size: 18),
                      filled: true,
                      fillColor: const Color(0xFFF4F7FB),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              _StatusFilterChip(
                label: 'Todos',
                selected: _filterStatus == null,
                color: const Color(0xFF637995),
                onTap: () => setState(() => _filterStatus = null),
              ),
              const SizedBox(width: 6),
              _StatusFilterChip(
                label: 'Activo',
                selected: _filterStatus == UserStatus.activo,
                color: const Color(0xFF2F8A5B),
                onTap: () => setState(() => _filterStatus =
                    _filterStatus == UserStatus.activo ? null : UserStatus.activo),
              ),
              const SizedBox(width: 6),
              _StatusFilterChip(
                label: 'Inactivo',
                selected: _filterStatus == UserStatus.inactivo,
                color: const Color(0xFF637995),
                onTap: () => setState(() => _filterStatus =
                    _filterStatus == UserStatus.inactivo ? null : UserStatus.inactivo),
              ),
              const SizedBox(width: 6),
              _StatusFilterChip(
                label: 'Suspendido',
                selected: _filterStatus == UserStatus.suspendido,
                color: const Color(0xFFE84B4B),
                onTap: () => setState(() => _filterStatus =
                    _filterStatus == UserStatus.suspendido ? null : UserStatus.suspendido),
              ),
            ],
          ),
        ),

        // ── Results info ────────────────────────────────────────────
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
          color: const Color(0xFFF7FAFE),
          child: Row(
            children: [
              Text(
                '${filtered.length} resultado${filtered.length != 1 ? 's' : ''}',
                style: const TextStyle(
                  color: Color(0xFF637995),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),

        // ── Content ─────────────────────────────────────────────────
        Expanded(
          child: filtered.isEmpty
              ? _emptyState()
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: LayoutBuilder(
                    builder: (context, c) {
                      if (!_gridView || c.maxWidth < 500) {
                        return _buildListView(filtered, context);
                      }
                      final cols = c.maxWidth > 1100
                          ? 4
                          : c.maxWidth > 760
                              ? 3
                              : 2;
                      return GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: cols,
                          crossAxisSpacing: 14,
                          mainAxisSpacing: 14,
                          childAspectRatio: 0.78,
                        ),
                        itemCount: filtered.length,
                        itemBuilder: (context, i) {
                          final u = filtered[i];
                          return _UserCard(
                            user: u,
                            onRefresh: () => setState(() {}),
                            onToggleStatus: () => _toggleUserStatus(u),
                            onDelete: () => _deleteUser(u),
                            onEdit: () => _openForm(context, u),
                          );
                        },
                      );
                    },
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildListView(List<AppUser> users, BuildContext context) {
    return Column(
      children: users
          .map(
            (u) => Container(
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFEAF0F6)),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                leading: _UserAvatar(user: u, radius: 24),
                title: Text(
                  u.nombreCompleto,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                subtitle: Text(
                  '${u.cargo} · ${u.area}',
                  style: const TextStyle(fontSize: 12),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    RoleBadge(u.rol),
                    const SizedBox(width: 8),
                    UserStatusBadge(u.estado),
                    const SizedBox(width: 4),
                    _ActionMenu(
                      user: u,
                      onEdit: () => _openForm(context, u),
                      onToggleStatus: () => _toggleUserStatus(u),
                      onDelete: () => _deleteUser(u),
                    ),
                  ],
                ),
                onTap: () => _openForm(context, u),
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFFEAF0F6),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.person_search_outlined,
              size: 40,
              color: Color(0xFFB1C0D0),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Sin resultados',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 18,
              color: Color(0xFF637995),
            ),
          ),
          const Text(
            'Prueba con otros filtros',
            style: TextStyle(color: Color(0xFF8EA6BF)),
          ),
        ],
      ),
    );
  }

  void _openForm(BuildContext context, AppUser? user) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => UserFormDialog(
        user: user,
        onSave: (u) async {
          try {
            if (user == null) {
              final created = await AdminApiService.createUser(u);
              setState(() => _users.add(created));
            } else {
              final updated = await AdminApiService.updateUser(user.id, u);
              setState(() {
                final i = _users.indexWhere((x) => x.id == updated.id);
                if (i >= 0) _users[i] = updated;
              });
            }
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(user == null ? 'Usuario creado' : 'Usuario actualizado'),
                backgroundColor: const Color(0xFF2F8A5B),
              ));
            }
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text('Error: $e'),
                backgroundColor: const Color(0xFFE84B4B),
              ));
            }
          }
        },
      ),
    );
  }

  Future<void> _toggleUserStatus(AppUser user) async {
    try {
      final newStatus = user.estado == UserStatus.activo ? UserStatus.inactivo : UserStatus.activo;
      final updated = await AdminApiService.updateUserStatus(user.id, newStatus);
      setState(() {
        final i = _users.indexWhere((x) => x.id == updated.id);
        if (i >= 0) _users[i] = updated;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error al cambiar estado: $e'),
          backgroundColor: const Color(0xFFE84B4B),
        ));
      }
    }
  }

  Future<void> _deleteUser(AppUser user) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Eliminar usuario', style: TextStyle(fontWeight: FontWeight.w800)),
        content: Text('¿Deseas eliminar a "${user.nombreCompleto}"? Esta acción no se puede deshacer.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: const Color(0xFFE84B4B)),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    try {
      await AdminApiService.deleteUser(user.id);
      setState(() => _users.removeWhere((x) => x.id == user.id));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Usuario eliminado'), backgroundColor: Color(0xFF2F8A5B)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error al eliminar: $e'),
          backgroundColor: const Color(0xFFE84B4B),
        ));
      }
    }
  }
}

// ─── User Card (Grid) ─────────────────────────────────────────────────────────

class _UserCard extends StatelessWidget {
  const _UserCard({
    required this.user,
    required this.onRefresh,
    required this.onToggleStatus,
    required this.onDelete,
    required this.onEdit,
  });
  final AppUser user;
  final VoidCallback onRefresh;
  final VoidCallback onToggleStatus;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEAF0F6)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Top color band + avatar
          Container(
            height: 64,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  user.rol.color.withValues(alpha: .15),
                  user.rol.color.withValues(alpha: .05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
            ),
            child: Stack(
              children: [
                Positioned(
                  top: 10,
                  right: 10,
                  child: _ActionMenu(
                    user: user,
                    onEdit: onEdit,
                    onToggleStatus: onToggleStatus,
                    onDelete: onDelete,
                  ),
                ),
              ],
            ),
          ),

          // Avatar overlapping the band
          Transform.translate(
            offset: const Offset(0, -32),
            child: _UserAvatar(user: user, radius: 32),
          ),

          // Info
          Transform.translate(
            offset: const Offset(0, -24),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Column(
                children: [
                  Text(
                    user.nombreCompleto,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    user.cargo,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color(0xFF637995),
                      fontSize: 11,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 10),
                  RoleBadge(user.rol),
                  const SizedBox(height: 6),
                  UserStatusBadge(user.estado),
                  const SizedBox(height: 10),
                  // Details
                  _MiniInfo(Icons.domain_outlined, user.area),
                  _MiniInfo(Icons.local_hospital_outlined, user.establecimiento),
                  if (user.cmp != null) _MiniInfo(Icons.badge_outlined, 'CMP ${user.cmp}'),
                  const SizedBox(height: 12),
                  // Actions
                  Row(
                    children: [
                      Expanded(
                        child: _SmallButton(
                          icon: Icons.edit_outlined,
                          label: 'Editar',
                          onTap: onEdit,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: _SmallButton(
                          icon: user.estado == UserStatus.activo
                              ? Icons.person_off_outlined
                              : Icons.person_outlined,
                          label: user.estado == UserStatus.activo
                              ? 'Desactivar'
                              : 'Activar',
                          color: user.estado == UserStatus.activo
                              ? const Color(0xFFE84B4B)
                              : const Color(0xFF2F8A5B),
                          onTap: onToggleStatus,
                        ),
                      ),
                    ],
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

// ─── User Avatar ──────────────────────────────────────────────────────────────

class _UserAvatar extends StatelessWidget {
  const _UserAvatar({required this.user, required this.radius});
  final AppUser user;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: radius * 2,
      height: radius * 2,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [
            user.rol.color,
            user.rol.color.withValues(alpha: .7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: Colors.white, width: 3),
        boxShadow: [
          BoxShadow(
            color: user.rol.color.withValues(alpha: .3),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Center(
        child: Text(
          user.initials,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            fontSize: radius * 0.6,
          ),
        ),
      ),
    );
  }
}

// ─── Supporting widgets ───────────────────────────────────────────────────────

class _StatChip extends StatelessWidget {
  const _StatChip({required this.label, required this.value, required this.color});
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withValues(alpha: .15)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w900,
              fontSize: 18,
            ),
          ),
          Text(
            label,
            style: const TextStyle(color: Color(0xFFB7C6D7), fontSize: 11),
          ),
        ],
      ),
    );
  }
}

class _StatusFilterChip extends StatelessWidget {
  const _StatusFilterChip({
    required this.label,
    required this.selected,
    required this.color,
    required this.onTap,
  });
  final String label;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? color.withValues(alpha: .12) : const Color(0xFFF4F7FB),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? color : const Color(0xFFD4E0EC),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? color : const Color(0xFF637995),
            fontWeight: FontWeight.w700,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}

class _MiniInfo extends StatelessWidget {
  const _MiniInfo(this.icon, this.text);
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 12, color: const Color(0xFF8EA6BF)),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              text,
              style: const TextStyle(color: Color(0xFF637995), fontSize: 11),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _SmallButton extends StatelessWidget {
  const _SmallButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final c = color ?? const Color(0xFF173E63);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 7),
        decoration: BoxDecoration(
          color: c.withValues(alpha: .07),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: c.withValues(alpha: .2)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 13, color: c),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(color: c, fontSize: 11, fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionMenu extends StatelessWidget {
  const _ActionMenu({
    required this.user,
    required this.onEdit,
    required this.onToggleStatus,
    required this.onDelete,
  });
  final AppUser user;
  final VoidCallback onEdit;
  final VoidCallback onToggleStatus;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert, size: 18, color: Color(0xFF637995)),
      onSelected: (v) {
        switch (v) {
          case 'edit':
            onEdit();
          case 'toggle':
            onToggleStatus();
          case 'delete':
            onDelete();
          case 'reset':
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Contraseña temporal enviada al correo registrado'),
              ),
            );
        }
      },
      itemBuilder: (_) => [
        const PopupMenuItem(
          value: 'edit',
          child: Row(children: [
            Icon(Icons.edit_outlined, size: 16),
            SizedBox(width: 8),
            Text('Editar perfil'),
          ]),
        ),
        PopupMenuItem(
          value: 'toggle',
          child: Row(children: [
            Icon(
              user.estado == UserStatus.activo
                  ? Icons.person_off_outlined
                  : Icons.person_outlined,
              size: 16,
            ),
            const SizedBox(width: 8),
            Text(user.estado == UserStatus.activo ? 'Desactivar' : 'Activar'),
          ]),
        ),
        const PopupMenuItem(
          value: 'reset',
          child: Row(children: [
            Icon(Icons.lock_reset_outlined, size: 16),
            SizedBox(width: 8),
            Text('Restablecer contraseña'),
          ]),
        ),
        const PopupMenuItem(
          value: 'delete',
          child: Row(children: [
            Icon(Icons.delete_outline, size: 16, color: Color(0xFFE84B4B)),
            SizedBox(width: 8),
            Text('Eliminar usuario', style: TextStyle(color: Color(0xFFE84B4B))),
          ]),
        ),
      ],
    );
  }
}
