import 'package:flutter/material.dart';
import 'api_client.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Widgets de estado reutilizables en todas las páginas
// ─────────────────────────────────────────────────────────────────────────────

/// Estado vacío — sin datos del backend
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    this.message = 'Sin datos',
    this.icon = Icons.cloud_off_outlined,
  });
  final String message;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 52, color: const Color(0xFF637995).withValues(alpha: .35)),
            const SizedBox(height: 16),
            Text(
              message,
              style: const TextStyle(
                color: Color(0xFF637995),
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            const Text(
              'Conectar con el backend para cargar datos',
              style: TextStyle(color: Color(0xFF637995), fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// Estado de carga
class LoadingState extends StatelessWidget {
  const LoadingState({super.key, this.message = 'Cargando...'});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(
              message,
              style: const TextStyle(color: Color(0xFF637995), fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}

/// Estado de error con botón de reintento
class ErrorState extends StatelessWidget {
  const ErrorState({super.key, required this.error, this.onRetry});
  final Object error;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final isNetwork = error is ApiException == false &&
        error.toString().contains('SocketException');
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 52, color: Color(0xFFE84B4B)),
            const SizedBox(height: 16),
            Text(
              isNetwork
                  ? 'Sin conexión al backend'
                  : (error is ApiException
                      ? (error as ApiException).message
                      : 'Error al cargar datos'),
              style: const TextStyle(
                color: Color(0xFFE84B4B),
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            const Text(
              'Verifica que el backend Spring Boot esté corriendo\nen http://localhost:8080',
              style: TextStyle(color: Color(0xFF637995), fontSize: 12),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 18),
              OutlinedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Reintentar'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Snackbar de éxito
void showSuccess(BuildContext context, String msg) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Row(
        children: [
          const Icon(Icons.check_circle_outline, color: Colors.white),
          const SizedBox(width: 10),
          Expanded(child: Text(msg)),
        ],
      ),
      backgroundColor: const Color(0xFF2F8A5B),
      behavior: SnackBarBehavior.floating,
      duration: const Duration(seconds: 3),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ),
  );
}

/// Snackbar de error
void showError(BuildContext context, Object error) {
  final msg = error is ApiException ? error.message : error.toString();
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.white),
          const SizedBox(width: 10),
          Expanded(child: Text(msg)),
        ],
      ),
      backgroundColor: const Color(0xFFE84B4B),
      behavior: SnackBarBehavior.floating,
      duration: const Duration(seconds: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ),
  );
}

/// Diálogo de confirmación (para eliminar, anular, etc.)
Future<bool> confirmDialog(
  BuildContext context, {
  required String title,
  required String content,
  String confirmLabel = 'Confirmar',
  Color confirmColor = const Color(0xFFE84B4B),
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(title),
      content: Text(content),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(backgroundColor: confirmColor),
          onPressed: () => Navigator.pop(ctx, true),
          child: Text(confirmLabel),
        ),
      ],
    ),
  );
  return result ?? false;
}
