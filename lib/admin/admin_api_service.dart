// ignore_for_file: constant_identifier_names
import '../core/api_client.dart';
import 'admin_models.dart';
import 'admin_mock_data.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  ADMIN API SERVICE — wraps all /api/admin/* endpoints
// ─────────────────────────────────────────────────────────────────────────────

// Cambia a true para usar datos mock (sin backend)
const bool useMockData = false;

class AdminApiService {
  // ── DASHBOARD ─────────────────────────────────────────────────────────────

  static Future<Map<String, dynamic>> getDashboardStats() async {
    if (useMockData) {
      await Future.delayed(const Duration(milliseconds: 500));
      return {
        'totalUsers': mockUsers.length,
        'activeUsers': mockUsers.where((u) => u.estado == UserStatus.activo).length,
        'totalAreas': mockAreas.length,
        'activeAreas': mockAreas.where((a) => a.estado == AreaStatus.activa).length,
        'totalEstablishments': mockEstablishments.length,
        'activeEstablishments': mockEstablishments.where((e) => e.activo).length,
      };
    }
    final data = await ApiClient.get('/admin/dashboard/stats');
    return (data as Map<String, dynamic>);
  }

  // ── AREAS ─────────────────────────────────────────────────────────────────

  static Future<List<MedicalArea>> getAreas() async {
    if (useMockData) {
      await Future.delayed(const Duration(milliseconds: 300));
      return mockAreas;
    }
    final data = await ApiClient.get('/admin/areas') as List<dynamic>;
    return data.map((j) => MedicalArea.fromJson(j as Map<String, dynamic>)).toList();
  }

  static Future<MedicalArea> createArea(MedicalArea area) async {
    if (useMockData) {
      await Future.delayed(const Duration(milliseconds: 300));
      return area;
    }
    final data = await ApiClient.post('/admin/areas', area.toJson());
    return MedicalArea.fromJson(data as Map<String, dynamic>);
  }

  static Future<MedicalArea> updateArea(String id, MedicalArea area) async {
    if (useMockData) {
      await Future.delayed(const Duration(milliseconds: 300));
      return area;
    }
    final data = await ApiClient.put('/admin/areas/$id', area.toJson());
    return MedicalArea.fromJson(data as Map<String, dynamic>);
  }

  static Future<MedicalArea> toggleAreaStatus(String id) async {
    if (useMockData) {
      await Future.delayed(const Duration(milliseconds: 300));
      final area = mockAreas.firstWhere((a) => a.id == id);
      return MedicalArea(
        id: area.id,
        nombre: area.nombre,
        codigo: area.codigo,
        descripcion: area.descripcion,
        responsable: area.responsable,
        personalAsignado: area.personalAsignado,
        estado: area.estado == AreaStatus.activa ? AreaStatus.inactiva : AreaStatus.activa,
        horario: area.horario,
      );
    }
    final data = await ApiClient.patch('/admin/areas/$id/status');
    return MedicalArea.fromJson(data as Map<String, dynamic>);
  }

  static Future<void> deleteArea(String id) async {
    if (useMockData) {
      await Future.delayed(const Duration(milliseconds: 300));
      return;
    }
    await ApiClient.delete('/admin/areas/$id');
  }

  // ── ESTABLISHMENTS ────────────────────────────────────────────────────────

  static Future<List<Establishment>> getEstablishments() async {
    if (useMockData) {
      await Future.delayed(const Duration(milliseconds: 300));
      return mockEstablishments;
    }
    final data = await ApiClient.get('/admin/establishments') as List<dynamic>;
    return data.map((j) => Establishment.fromJson(j as Map<String, dynamic>)).toList();
  }

  static Future<Establishment> createEstablishment(Establishment e) async {
    if (useMockData) {
      await Future.delayed(const Duration(milliseconds: 300));
      return e;
    }
    final data = await ApiClient.post('/admin/establishments', e.toJson());
    return Establishment.fromJson(data as Map<String, dynamic>);
  }

  static Future<Establishment> updateEstablishment(String id, Establishment e) async {
    if (useMockData) {
      await Future.delayed(const Duration(milliseconds: 300));
      return e;
    }
    final data = await ApiClient.put('/admin/establishments/$id', e.toJson());
    return Establishment.fromJson(data as Map<String, dynamic>);
  }

  static Future<Establishment> toggleEstablishmentActive(String id) async {
    if (useMockData) {
      await Future.delayed(const Duration(milliseconds: 300));
      final est = mockEstablishments.firstWhere((e) => e.id == id);
      return Establishment(
        id: est.id,
        nombre: est.nombre,
        codigoRenipress: est.codigoRenipress,
        red: est.red,
        microred: est.microred,
        distrito: est.distrito,
        provincia: est.provincia,
        departamento: est.departamento,
        responsable: est.responsable,
        telefono: est.telefono,
        activo: !est.activo,
      );
    }
    final data = await ApiClient.patch('/api/admin/establishments/$id/active');
    return Establishment.fromJson(data as Map<String, dynamic>);
  }

  static Future<void> deleteEstablishment(String id) async {
    if (useMockData) {
      await Future.delayed(const Duration(milliseconds: 300));
      return;
    }
    await ApiClient.delete('/admin/establishments/$id');
  }

  // ── USERS ──────────────────────────────────────────────────────────────────

  static Future<List<AppUser>> getUsers({
    String? search,
    String? role,
    String? status,
  }) async {
    if (useMockData) {
      await Future.delayed(const Duration(milliseconds: 300));
      var users = mockUsers;
      if (search != null && search.isNotEmpty) {
        users = users.where((u) => 
          u.nombres.toLowerCase().contains(search.toLowerCase()) ||
          u.apellidos.toLowerCase().contains(search.toLowerCase()) ||
          u.dni.contains(search)
        ).toList();
      }
      if (role != null && role.isNotEmpty) {
        users = users.where((u) => u.rol.name == role).toList();
      }
      if (status != null && status.isNotEmpty) {
        users = users.where((u) => u.estado.name == status).toList();
      }
      return users;
    }
    final data = await ApiClient.get('/admin/users', params: {
      'search': search,
      'role': role,
      'status': status,
    }) as List<dynamic>;
    return data.map((j) => AppUser.fromJson(j as Map<String, dynamic>)).toList();
  }

  static Future<AppUser> createUser(AppUser user) async {
    if (useMockData) {
      await Future.delayed(const Duration(milliseconds: 300));
      return user;
    }
    final data = await ApiClient.post('/admin/users', user.toCreateJson());
    return AppUser.fromJson(data as Map<String, dynamic>);
  }

  static Future<AppUser> updateUser(String id, AppUser user) async {
    if (useMockData) {
      await Future.delayed(const Duration(milliseconds: 300));
      return user;
    }
    final data = await ApiClient.put('/admin/users/$id', user.toCreateJson());
    return AppUser.fromJson(data as Map<String, dynamic>);
  }

  static Future<AppUser> updateUserStatus(String id, UserStatus status) async {
    if (useMockData) {
      await Future.delayed(const Duration(milliseconds: 300));
      final user = mockUsers.firstWhere((u) => u.id == id);
      return AppUser(
        id: user.id,
        nombres: user.nombres,
        apellidos: user.apellidos,
        dni: user.dni,
        email: user.email,
        telefono: user.telefono,
        rol: user.rol,
        area: user.area,
        establecimiento: user.establecimiento,
        estado: status,
        cmp: user.cmp,
        username: user.username,
        lastAccess: user.lastAccess,
    fechaNacimiento: user.fechaNacimiento,
    sexo: user.sexo,
    cargo: user.cargo,
      );
    }
    final data = await ApiClient.patch(
      '/admin/users/$id/status',
      {'status': status.name.toUpperCase()},
    );
    return AppUser.fromJson(data as Map<String, dynamic>);
  }

  static Future<void> deleteUser(String id) async {
    if (useMockData) {
      await Future.delayed(const Duration(milliseconds: 300));
      return;
    }
    await ApiClient.delete('/admin/users/$id');
  }

  // ── AUDIT ──────────────────────────────────────────────────────────────────

  static Future<List<AuditRecord>> getAuditRecords({
    String? user,
    String? action,
    String? module,
  }) async {
    if (useMockData) {
      await Future.delayed(const Duration(milliseconds: 300));
      var records = mockAuditRecords;
      if (user != null && user.isNotEmpty) {
        records = records.where((r) => r.usuario.toLowerCase().contains(user.toLowerCase())).toList();
      }
      if (action != null && action.isNotEmpty) {
        records = records.where((r) => r.accion.name == action).toList();
      }
      if (module != null && module.isNotEmpty) {
        records = records.where((r) => r.modulo.toLowerCase().contains(module.toLowerCase())).toList();
      }
      return records;
    }
    final data = await ApiClient.get('/admin/audit', params: {
      'user': user,
      'action': action,
      'module': module,
    }) as List<dynamic>;
    return data.map((j) => AuditRecord.fromJson(j as Map<String, dynamic>)).toList();
  }
}
