// ignore_for_file: constant_identifier_names
import '../core/api_client.dart';
import 'admin_models.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  ADMIN API SERVICE — wraps all /api/admin/* endpoints
// ─────────────────────────────────────────────────────────────────────────────

class AdminApiService {
  // ── DASHBOARD ─────────────────────────────────────────────────────────────

  static Future<Map<String, dynamic>> getDashboardStats() async {
    final data = await ApiClient.get('/api/admin/dashboard/stats');
    return (data as Map<String, dynamic>);
  }

  // ── AREAS ─────────────────────────────────────────────────────────────────

  static Future<List<MedicalArea>> getAreas() async {
    final data = await ApiClient.get('/api/admin/areas') as List<dynamic>;
    return data.map((j) => MedicalArea.fromJson(j as Map<String, dynamic>)).toList();
  }

  static Future<MedicalArea> createArea(MedicalArea area) async {
    final data = await ApiClient.post('/api/admin/areas', area.toJson());
    return MedicalArea.fromJson(data as Map<String, dynamic>);
  }

  static Future<MedicalArea> updateArea(String id, MedicalArea area) async {
    final data = await ApiClient.put('/api/admin/areas/$id', area.toJson());
    return MedicalArea.fromJson(data as Map<String, dynamic>);
  }

  static Future<MedicalArea> toggleAreaStatus(String id) async {
    final data = await ApiClient.patch('/api/admin/areas/$id/status');
    return MedicalArea.fromJson(data as Map<String, dynamic>);
  }

  static Future<void> deleteArea(String id) async {
    await ApiClient.delete('/api/admin/areas/$id');
  }

  // ── ESTABLISHMENTS ────────────────────────────────────────────────────────

  static Future<List<Establishment>> getEstablishments() async {
    final data = await ApiClient.get('/api/admin/establishments') as List<dynamic>;
    return data.map((j) => Establishment.fromJson(j as Map<String, dynamic>)).toList();
  }

  static Future<Establishment> createEstablishment(Establishment e) async {
    final data = await ApiClient.post('/api/admin/establishments', e.toJson());
    return Establishment.fromJson(data as Map<String, dynamic>);
  }

  static Future<Establishment> updateEstablishment(String id, Establishment e) async {
    final data = await ApiClient.put('/api/admin/establishments/$id', e.toJson());
    return Establishment.fromJson(data as Map<String, dynamic>);
  }

  static Future<Establishment> toggleEstablishmentActive(String id) async {
    final data = await ApiClient.patch('/api/admin/establishments/$id/active');
    return Establishment.fromJson(data as Map<String, dynamic>);
  }

  static Future<void> deleteEstablishment(String id) async {
    await ApiClient.delete('/api/admin/establishments/$id');
  }

  // ── USERS ──────────────────────────────────────────────────────────────────

  static Future<List<AppUser>> getUsers({
    String? search,
    String? role,
    String? status,
  }) async {
    final data = await ApiClient.get('/api/admin/users', params: {
      'search': search,
      'role': role,
      'status': status,
    }) as List<dynamic>;
    return data.map((j) => AppUser.fromJson(j as Map<String, dynamic>)).toList();
  }

  static Future<AppUser> createUser(AppUser user) async {
    final data = await ApiClient.post('/api/admin/users', user.toCreateJson());
    return AppUser.fromJson(data as Map<String, dynamic>);
  }

  static Future<AppUser> updateUser(String id, AppUser user) async {
    final data = await ApiClient.put('/api/admin/users/$id', user.toCreateJson());
    return AppUser.fromJson(data as Map<String, dynamic>);
  }

  static Future<AppUser> updateUserStatus(String id, UserStatus status) async {
    final data = await ApiClient.patch(
      '/api/admin/users/$id/status',
      {'status': status.name.toUpperCase()},
    );
    return AppUser.fromJson(data as Map<String, dynamic>);
  }

  static Future<void> deleteUser(String id) async {
    await ApiClient.delete('/api/admin/users/$id');
  }

  // ── AUDIT ──────────────────────────────────────────────────────────────────

  static Future<List<AuditRecord>> getAuditRecords({
    String? user,
    String? action,
    String? module,
  }) async {
    final data = await ApiClient.get('/api/admin/audit', params: {
      'user': user,
      'action': action,
      'module': module,
    }) as List<dynamic>;
    return data.map((j) => AuditRecord.fromJson(j as Map<String, dynamic>)).toList();
  }
}
