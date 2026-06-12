import 'package:flutter/material.dart';
import '../../core/api_exception.dart';

/// Widget de carga estándar para usar mientras la API responde
class ApiLoadingState extends StatelessWidget {
  const ApiLoadingState({super.key, this.message = 'Cargando datos…'});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(
            width: 48,
            height: 48,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              color: Color(0xFF2F7DE1),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(color: Color(0xFF637995), fontSize: 14),
          ),
        ],
      ),
    );
  }
}

/// Widget de error estándar con botón de reintento
class ApiErrorState extends StatelessWidget {
  const ApiErrorState({
    super.key,
    required this.exception,
    required this.onRetry,
  });

  final Object exception;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final isApiEx = exception is ApiException;
    final apiEx = isApiEx ? exception as ApiException : null;
    final isNoConn = apiEx?.type == ApiErrorType.noConnection;

    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 420),
        margin: const EdgeInsets.all(32),
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFFFE0E0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: .06),
              blurRadius: 12,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: isNoConn
                    ? const Color(0xFFFFF3E0)
                    : const Color(0xFFFFEBEB),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isNoConn
                    ? Icons.wifi_off_outlined
                    : Icons.error_outline_rounded,
                color: isNoConn
                    ? const Color(0xFFFFA927)
                    : const Color(0xFFE84B4B),
                size: 32,
              ),
            ),
            const SizedBox(height: 16),

            // Title
            Text(
              isNoConn ? 'Sin conexión al backend' : 'Error al cargar datos',
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),

            // Message
            Text(
              apiEx?.message ?? exception.toString(),
              style: const TextStyle(color: Color(0xFF637995), fontSize: 13),
              textAlign: TextAlign.center,
            ),

            if (isNoConn) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF8EC),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFFFE5A0)),
                ),
                child: const Text(
                  '💡 Asegúrate de que el backend Spring Boot esté corriendo:\n'
                  'mvn spring-boot:run  →  localhost:8080',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF8A6300),
                    fontFamily: 'monospace',
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],

            const SizedBox(height: 20),

            FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF2F7DE1),
              ),
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_outlined, size: 16),
              label: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }
}
