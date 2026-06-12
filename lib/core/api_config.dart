import 'dart:io';
import 'package:flutter/foundation.dart';

// Configuración centralizada de la API
// Cambia baseUrl según el entorno

class ApiConfig {
  ApiConfig._();

  /// URL base del backend Spring Boot.
  /// En desarrollo usa localhost:8080.
  /// En producción apunta al servidor real.
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:8080/api';
    }
    // Si es Android y no es web (emulador)
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:8080/api';
    }
    return 'http://localhost:8080/api';
  }

  static const Duration connectTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // Rutas — Admin
  static const String adminUsers = '/admin/users';
  static const String adminAreas = '/admin/areas';
  static const String adminEstablishments = '/admin/establishments';
  static const String adminAudit = '/admin/audit';
  static const String adminDashboard = '/admin/dashboard';
  static const String authLogin = '/auth/login';

  // Rutas — Clínico
  static const String clinicalPatients = '/clinical/patients';
  static const String clinicalHistories = '/clinical/histories';
  static const String clinicalPrescriptions = '/clinical/prescriptions';
  static const String clinicalTelemedicine = '/clinical/telemedicine';
  static const String clinicalDashboard = '/clinical/dashboard';
}
