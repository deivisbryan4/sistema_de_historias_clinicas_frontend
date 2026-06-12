import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'api_config.dart';

class ApiException implements Exception {
  final int statusCode;
  final String message;
  const ApiException(this.statusCode, this.message);

  @override
  String toString() => 'ApiException($statusCode): $message';
}

class ApiClient {
  static String get baseUrl => ApiConfig.baseUrl;
  static const Duration _timeout = Duration(seconds: 5);

  static Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  // ── GET ──────────────────────────────────────────────────────────────────────────
  static Future<dynamic> get(String path,
      {Map<String, String?>? params}) async {
    return safeCall(() async {
      final uri = _buildUri(path, params);
      final response = await http.get(uri, headers: _headers).timeout(_timeout);
      return _handle(response);
    });
  }

  // ── POST ─────────────────────────────────────────────────────────────────────────
  static Future<dynamic> post(String path, Map<String, dynamic> body) async {
    return safeCall(() async {
      final uri = _buildUri(path);
      final response = await http
          .post(uri, headers: _headers, body: jsonEncode(body))
          .timeout(_timeout);
      return _handle(response);
    });
  }

  // ── PUT ──────────────────────────────────────────────────────────────────────────
  static Future<dynamic> put(String path, Map<String, dynamic> body) async {
    return safeCall(() async {
      final uri = _buildUri(path);
      final response = await http
          .put(uri, headers: _headers, body: jsonEncode(body))
          .timeout(_timeout);
      return _handle(response);
    });
  }

  // ── PATCH ────────────────────────────────────────────────────────────────────────
  static Future<dynamic> patch(String path,
      [Map<String, dynamic>? body]) async {
    return safeCall(() async {
      final uri = _buildUri(path);
      final response = await http
          .patch(uri,
              headers: _headers,
              body: body != null ? jsonEncode(body) : null)
          .timeout(_timeout);
      return _handle(response);
    });
  }

  // ── DELETE ───────────────────────────────────────────────────────────────────────
  static Future<void> delete(String path) async {
    return safeCall(() async {
      final uri = _buildUri(path);
      final response =
          await http.delete(uri, headers: _headers).timeout(_timeout);
      _handle(response);
    });
  }

  // ── Helpers ────────────────────────────────────────────────────────────────
  static Uri _buildUri(String path, [Map<String, String?>? params]) {
    final cleanParams = params?.entries
        .where((e) => e.value != null && e.value!.isNotEmpty)
        .fold<Map<String, String>>({}, (m, e) => m..[e.key] = e.value!);
    return Uri.parse('$baseUrl$path').replace(
        queryParameters: (cleanParams?.isEmpty ?? true) ? null : cleanParams);
  }

  static dynamic _handle(http.Response response) {
    final body = utf8.decode(response.bodyBytes);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (body.isEmpty) return null;
      return jsonDecode(body);
    }
    // Credenciales incorrectas
    if (response.statusCode == 401 || response.statusCode == 403) {
      throw const ApiException(401, 'Usuario o contraseña incorrectos');
    }
    String msg = 'Error ${response.statusCode}';
    try {
      final err = jsonDecode(body);
      msg = err['message'] ?? err['error'] ?? msg;
    } catch (_) {}
    throw ApiException(response.statusCode, msg);
  }

  /// Wraps any call to catch socket/timeout exceptions with a friendly message.
  static Future<T> safeCall<T>(Future<T> Function() fn) async {
    try {
      return await fn();
    } on SocketException {
      throw const ApiException(0, 'No se puede conectar al servidor. Verifica que el backend esté en ejecución.');
    } on TimeoutException {
      throw const ApiException(0, 'El servidor tardó demasiado en responder (timeout). Verifica que el backend esté corriendo en el puerto 8080.');
    }
  }
}
