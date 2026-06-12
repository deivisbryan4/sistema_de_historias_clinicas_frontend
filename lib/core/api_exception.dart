/// Tipos de error de API con mensajes amigables en español
class ApiException implements Exception {
  const ApiException({
    required this.type,
    required this.message,
    this.statusCode,
  });

  final ApiErrorType type;
  final String message;
  final int? statusCode;

  // ─── Constructores de fábrica ─────────────────────────────────────────────

  factory ApiException.noConnection() => const ApiException(
        type: ApiErrorType.noConnection,
        message:
            'Sin conexión al servidor. Verifica que el backend esté corriendo en localhost:8080',
      );

  factory ApiException.network(String detail) => ApiException(
        type: ApiErrorType.network,
        message: 'Error de red: $detail',
      );

  factory ApiException.badRequest(String detail) => ApiException(
        type: ApiErrorType.badRequest,
        message: detail,
        statusCode: 400,
      );

  factory ApiException.unauthorized() => const ApiException(
        type: ApiErrorType.unauthorized,
        message: 'Sesión expirada. Por favor inicia sesión nuevamente.',
        statusCode: 401,
      );

  factory ApiException.forbidden() => const ApiException(
        type: ApiErrorType.forbidden,
        message: 'No tienes permisos para realizar esta acción.',
        statusCode: 403,
      );

  factory ApiException.notFound(String detail) => ApiException(
        type: ApiErrorType.notFound,
        message: detail,
        statusCode: 404,
      );

  factory ApiException.conflict(String detail) => ApiException(
        type: ApiErrorType.conflict,
        message: detail,
        statusCode: 409,
      );

  factory ApiException.server(String detail) => ApiException(
        type: ApiErrorType.server,
        message: detail,
        statusCode: 500,
      );

  /// Ícono Material para mostrar en la UI según el tipo de error
  String get icon {
    switch (type) {
      case ApiErrorType.noConnection:
        return '🔌';
      case ApiErrorType.unauthorized:
        return '🔒';
      case ApiErrorType.forbidden:
        return '🚫';
      case ApiErrorType.notFound:
        return '🔍';
      case ApiErrorType.server:
        return '⚠️';
      default:
        return '❌';
    }
  }

  @override
  String toString() => 'ApiException(${type.name}): $message';
}

enum ApiErrorType {
  noConnection,
  network,
  badRequest,
  unauthorized,
  forbidden,
  notFound,
  conflict,
  server,
}
