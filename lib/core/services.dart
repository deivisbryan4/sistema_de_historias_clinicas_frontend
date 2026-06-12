import 'api_client.dart';
import 'models.dart';

// ─────────────────────────────────────────────────────────────────────────────
// PatientService — /api/clinical/patients
// ─────────────────────────────────────────────────────────────────────────────
class PatientService {
  static const _base = '/clinical/patients';

  static Future<List<Patient>> getAll({String? search, String? status}) async {
    final data = await ApiClient.get(_base,
        params: {'search': search, 'status': status});
    return (data as List).map((j) => Patient.fromJson(j)).toList();
  }

  static Future<Patient> getById(String id) async {
    final data = await ApiClient.get('$_base/$id');
    return Patient.fromJson(data);
  }

  static Future<Patient> create(Map<String, dynamic> body) async {
    final data = await ApiClient.post(_base, body);
    return Patient.fromJson(data);
  }

  static Future<Patient> update(String id, Map<String, dynamic> body) async {
    final data = await ApiClient.put('$_base/$id', body);
    return Patient.fromJson(data);
  }

  static Future<void> delete(String id) => ApiClient.delete('$_base/$id');
}

// ─────────────────────────────────────────────────────────────────────────────
// ClinicalHistoryService — /api/clinical/histories
// ─────────────────────────────────────────────────────────────────────────────
class ClinicalHistoryService {
  static const _base = '/clinical/histories';

  static Future<List<ClinicalHistory>> getAll() async {
    final data = await ApiClient.get(_base);
    return (data as List).map((j) => ClinicalHistory.fromJson(j)).toList();
  }

  static Future<List<ClinicalHistory>> getByPatient(String patientId) async {
    final data =
        await ApiClient.get(_base, params: {'patientId': patientId});
    return (data as List).map((j) => ClinicalHistory.fromJson(j)).toList();
  }

  static Future<List<ClinicalHistory>> getRecent() async {
    final data = await ApiClient.get('$_base/recent');
    return (data as List).map((j) => ClinicalHistory.fromJson(j)).toList();
  }

  static Future<ClinicalHistory> getById(String id) async {
    final data = await ApiClient.get('$_base/$id');
    return ClinicalHistory.fromJson(data);
  }

  static Future<ClinicalHistory> create(Map<String, dynamic> body) async {
    final data = await ApiClient.post(_base, body);
    return ClinicalHistory.fromJson(data);
  }

  static Future<ClinicalHistory> update(
      String id, Map<String, dynamic> body) async {
    final data = await ApiClient.put('$_base/$id', body);
    return ClinicalHistory.fromJson(data);
  }

  static Future<ClinicalHistory> sign(String id) async {
    final data = await ApiClient.patch('$_base/$id/sign');
    return ClinicalHistory.fromJson(data);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// PrescriptionService — /api/clinical/prescriptions
// ─────────────────────────────────────────────────────────────────────────────
class PrescriptionService {
  static const _base = '/clinical/prescriptions';

  static Future<List<Prescription>> getByPatient(String patientId) async {
    final data =
        await ApiClient.get(_base, params: {'patientId': patientId});
    return (data as List).map((j) => Prescription.fromJson(j)).toList();
  }

  static Future<List<Prescription>> getAll({String? status}) async {
    final data =
        await ApiClient.get(_base, params: {'status': status});
    return (data as List).map((j) => Prescription.fromJson(j)).toList();
  }

  static Future<Prescription> getById(String id) async {
    final data = await ApiClient.get('$_base/$id');
    return Prescription.fromJson(data);
  }

  static Future<Prescription> create(Map<String, dynamic> body) async {
    final data = await ApiClient.post(_base, body);
    return Prescription.fromJson(data);
  }

  static Future<void> void_(String id) =>
      ApiClient.patch('$_base/$id/void');
}

// ─────────────────────────────────────────────────────────────────────────────
// TelemedicineService — /api/clinical/telemedicine
// ─────────────────────────────────────────────────────────────────────────────
class TelemedicineService {
  static const _base = '/clinical/telemedicine';

  static Future<List<TelemedicineSession>> getAll({String? status}) async {
    final data =
        await ApiClient.get(_base, params: {'status': status});
    return (data as List)
        .map((j) => TelemedicineSession.fromJson(j))
        .toList();
  }

  static Future<TelemedicineSession> getById(String id) async {
    final data = await ApiClient.get('$_base/$id');
    return TelemedicineSession.fromJson(data);
  }

  static Future<TelemedicineSession> create(
      Map<String, dynamic> body) async {
    final data = await ApiClient.post(_base, body);
    return TelemedicineSession.fromJson(data);
  }

  static Future<TelemedicineSession> updateStatus(
      String id, String status) async {
    final data =
        await ApiClient.patch('$_base/$id/status', {'status': status});
    return TelemedicineSession.fromJson(data);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// DashboardService — /api/admin/dashboard
// ─────────────────────────────────────────────────────────────────────────────
class DashboardService {
  static Future<DashboardStats> getStats() async {
    final data = await ApiClient.get('/admin/dashboard/stats');
    return DashboardStats.fromJson(data);
  }

  static Future<DashboardStats> getClinicalStats() async {
    final data =
        await ApiClient.get('/clinical/dashboard/stats');
    return DashboardStats.fromJson(data);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// AuditService — /api/admin/audit
// ─────────────────────────────────────────────────────────────────────────────
class AuditService {
  static Future<List<AuditRecord>> getAll(
      {String? user, String? action, String? module}) async {
    final data = await ApiClient.get('/admin/audit',
        params: {'user': user, 'action': action, 'module': module});
    return (data as List).map((j) => AuditRecord.fromJson(j)).toList();
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// UserService — /api/admin/users
// ─────────────────────────────────────────────────────────────────────────────
class UserService {
  static const _base = '/admin/users';

  static Future<AppUser> login(String username, String password) async {
    final data = await ApiClient.post('/auth/login', {
      'username': username,
      'password': password,
    });
    return AppUser.fromJson(data);
  }

  static Future<List<AppUser>> getAll(
      {String? search, String? role, String? status}) async {
    final data = await ApiClient.get(_base,
        params: {'search': search, 'role': role, 'status': status});
    return (data as List).map((j) => AppUser.fromJson(j)).toList();
  }

  static Future<AppUser> getById(String id) async {
    final data = await ApiClient.get('$_base/$id');
    return AppUser.fromJson(data);
  }

  static Future<AppUser> create(Map<String, dynamic> body) async {
    final data = await ApiClient.post(_base, body);
    return AppUser.fromJson(data);
  }

  static Future<AppUser> update(String id, Map<String, dynamic> body) async {
    final data = await ApiClient.put('$_base/$id', body);
    return AppUser.fromJson(data);
  }

  static Future<void> updateStatus(String id, String status) =>
      ApiClient.patch('$_base/$id/status', {'status': status});

  static Future<void> delete(String id) => ApiClient.delete('$_base/$id');
}
