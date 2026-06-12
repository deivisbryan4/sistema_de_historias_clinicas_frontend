import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../admin_models.dart';
import '../admin_api_service.dart';

// ═══════════════════════════════════════════════════════════════════════════════
// AUDITORÍA — conectada al backend /api/admin/audit
// Botón Exportar: genera CSV y lo copia al portapapeles (compatible con web)
// ═══════════════════════════════════════════════════════════════════════════════

class AuditPage extends StatefulWidget {
  const AuditPage({super.key});

  @override
  State<AuditPage> createState() => _AuditPageState();
}

class _AuditPageState extends State<AuditPage> {
  List<AuditRecord> _records = [];
  bool _loading = true;
  String? _error;

  String _searchUser = '';
  AuditActionType? _filterAction;
  String? _filterModule;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final list = await AdminApiService.getAuditRecords(
        user: _searchUser.isEmpty ? null : _searchUser,
        action: _filterAction?.name.toUpperCase(),
        module: (_filterModule == null || _filterModule == 'Todos') ? null : _filterModule,
      );
      setState(() { _records = list; _loading = false; });
    } catch (e) {
      setState(() { _error = e.toString(); _loading = false; });
    }
  }

  List<AuditRecord> get _filtered {
    return _records.where((r) {
      final q = _searchUser.toLowerCase();
      final matchesUser = q.isEmpty || r.usuario.toLowerCase().contains(q);
      final matchesAction = _filterAction == null || r.accion == _filterAction;
      final matchesModule = _filterModule == null || _filterModule == 'Todos' || r.modulo == _filterModule;
      return matchesUser && matchesAction && matchesModule;
    }).toList()
      ..sort((a, b) => b.fecha.compareTo(a.fecha));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildHeader(),
        _buildFilters(),
        Expanded(child: _buildBody()),
      ],
    );
  }

  Widget _buildBody() {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Color(0xFFE84B4B)),
            const SizedBox(height: 12),
            const Text('Error al cargar auditoría', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
            Text(_error!, style: const TextStyle(color: Color(0xFF637995), fontSize: 13)),
            const SizedBox(height: 16),
            FilledButton.icon(onPressed: _load, icon: const Icon(Icons.refresh), label: const Text('Reintentar')),
          ],
        ),
      );
    }
    final records = _filtered;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: LayoutBuilder(
        builder: (context, c) {
          if (c.maxWidth < 720) return _buildCards(records);
          return _buildTable(records);
        },
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFD4E0EC))),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Seguridad y Auditoría', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
                Text(
                  '${_records.length} registros de actividad · Mostrando ${_filtered.length}',
                  style: const TextStyle(color: Color(0xFF637995), fontSize: 14),
                ),
              ],
            ),
          ),
          IconButton(icon: const Icon(Icons.refresh_outlined), tooltip: 'Actualizar', onPressed: _load),
          const SizedBox(width: 8),
          OutlinedButton.icon(
            onPressed: _exportCsv,
            icon: const Icon(Icons.download_outlined, size: 16),
            label: const Text('Exportar CSV'),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    final modules = ['Todos', ...{..._records.map((r) => r.modulo)}];
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: const BoxDecoration(
        color: Color(0xFFF7FAFE),
        border: Border(bottom: BorderSide(color: Color(0xFFEAF0F6))),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          spacing: 10,
          children: [
            SizedBox(
              width: 240,
              height: 40,
              child: TextField(
                onChanged: (v) => setState(() => _searchUser = v),
                onSubmitted: (_) => _load(),
                style: const TextStyle(fontSize: 13),
                decoration: InputDecoration(
                  hintText: 'Buscar por usuario…',
                  hintStyle: const TextStyle(fontSize: 13),
                  prefixIcon: const Icon(Icons.search, size: 18),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFFD4E0EC)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFFD4E0EC)),
                  ),
                ),
              ),
            ),
            _FilterDropdown<AuditActionType>(
              hint: 'Tipo de acción',
              value: _filterAction,
              items: AuditActionType.values,
              labelOf: (a) => a.label,
              onChanged: (v) => setState(() => _filterAction = v),
            ),
            _FilterDropdown<String>(
              hint: 'Módulo',
              value: _filterModule,
              items: modules,
              labelOf: (m) => m,
              onChanged: (v) => setState(() => _filterModule = v),
            ),
            if (_filterAction != null || _filterModule != null || _searchUser.isNotEmpty)
              TextButton.icon(
                onPressed: () => setState(() {
                  _filterAction = null;
                  _filterModule = null;
                  _searchUser = '';
                }),
                icon: const Icon(Icons.clear, size: 16),
                label: const Text('Limpiar'),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTable(List<AuditRecord> records) {
    if (records.isEmpty) return _emptyState();
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFD4E0EC)),
        borderRadius: BorderRadius.circular(14),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            headingRowColor: WidgetStateProperty.all(const Color(0xFFF4F7FB)),
            dataRowMinHeight: 62,
            dataRowMaxHeight: 80,
            columnSpacing: 16,
            columns: const [
              DataColumn(label: _ColLabel('TIPO')),
              DataColumn(label: _ColLabel('USUARIO')),
              DataColumn(label: _ColLabel('MÓDULO')),
              DataColumn(label: _ColLabel('DESCRIPCIÓN')),
              DataColumn(label: _ColLabel('IP / DISPOSITIVO')),
              DataColumn(label: _ColLabel('FECHA Y HORA')),
            ],
            rows: records.map(_buildRow).toList(),
          ),
        ),
      ),
    );
  }

  DataRow _buildRow(AuditRecord r) {
    final fecha = '${r.fecha.day.toString().padLeft(2, '0')}/${r.fecha.month.toString().padLeft(2, '0')}/${r.fecha.year}';
    final hora = '${r.fecha.hour.toString().padLeft(2, '0')}:${r.fecha.minute.toString().padLeft(2, '0')}';

    return DataRow(
      cells: [
        DataCell(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            decoration: BoxDecoration(
              color: r.accion.color.withValues(alpha: .1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(r.accion.icon, color: r.accion.color, size: 15),
                const SizedBox(width: 5),
                Text(r.accion.label, style: TextStyle(color: r.accion.color, fontWeight: FontWeight.w700, fontSize: 12)),
              ],
            ),
          ),
        ),
        DataCell(
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(r.usuario, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
              Text(r.usuarioRol, style: const TextStyle(color: Color(0xFF637995), fontSize: 11)),
            ],
          ),
        ),
        DataCell(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: const Color(0xFFE3EDF9), borderRadius: BorderRadius.circular(6)),
            child: Text(r.modulo, style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF173E63), fontSize: 12)),
          ),
        ),
        DataCell(
          SizedBox(
            width: 220,
            child: Text(r.detalle, style: const TextStyle(fontSize: 12), maxLines: 2, overflow: TextOverflow.ellipsis),
          ),
        ),
        DataCell(
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(r.ip, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
              Text(r.dispositivo, style: const TextStyle(color: Color(0xFF637995), fontSize: 11)),
            ],
          ),
        ),
        DataCell(
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(fecha, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
              Text(hora, style: const TextStyle(color: Color(0xFF637995), fontSize: 11)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCards(List<AuditRecord> records) {
    if (records.isEmpty) return _emptyState();
    return Column(
      children: records.map((r) {
        final fecha = '${r.fecha.day.toString().padLeft(2, '0')}/${r.fecha.month.toString().padLeft(2, '0')}/${r.fecha.year} ${r.fecha.hour.toString().padLeft(2, '0')}:${r.fecha.minute.toString().padLeft(2, '0')}';
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: r.accion.color.withValues(alpha: .25)),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                    decoration: BoxDecoration(color: r.accion.color.withValues(alpha: .1), borderRadius: BorderRadius.circular(8)),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(r.accion.icon, color: r.accion.color, size: 14),
                        const SizedBox(width: 5),
                        Text(r.accion.label, style: TextStyle(color: r.accion.color, fontWeight: FontWeight.w700, fontSize: 12)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: const Color(0xFFE3EDF9), borderRadius: BorderRadius.circular(6)),
                    child: Text(r.modulo, style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF173E63), fontSize: 12)),
                  ),
                  const Spacer(),
                  Text(fecha, style: const TextStyle(color: Color(0xFF637995), fontSize: 11)),
                ],
              ),
              const SizedBox(height: 10),
              Text(r.usuario, style: const TextStyle(fontWeight: FontWeight.w800)),
              Text(r.detalle, style: const TextStyle(color: Color(0xFF637995), fontSize: 13)),
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(Icons.computer_outlined, size: 13, color: Color(0xFF637995)),
                  const SizedBox(width: 4),
                  Text(r.ip, style: const TextStyle(color: Color(0xFF637995), fontSize: 12)),
                  const SizedBox(width: 8),
                  Text(r.dispositivo, style: const TextStyle(color: Color(0xFF637995), fontSize: 12)),
                ],
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _emptyState() {
    return Container(
      padding: const EdgeInsets.all(48),
      child: const Column(
        children: [
          Icon(Icons.security_outlined, size: 56, color: Color(0xFFD4E0EC)),
          SizedBox(height: 16),
          Text('No se encontraron registros de auditoría',
              style: TextStyle(color: Color(0xFF637995), fontSize: 16)),
        ],
      ),
    );
  }

  // ─── Export ───────────────────────────────────────────────────────────────

  void _exportCsv() {
    final records = _filtered;
    if (records.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No hay registros para exportar')),
      );
      return;
    }

    final lines = <String>[
      'ID,Usuario,Rol,Acción,Módulo,Detalle,IP,Dispositivo,Fecha',
      ...records.map((r) {
        final fecha = '${r.fecha.year}-${r.fecha.month.toString().padLeft(2, '0')}-${r.fecha.day.toString().padLeft(2, '0')} ${r.fecha.hour.toString().padLeft(2, '0')}:${r.fecha.minute.toString().padLeft(2, '0')}';
        String esc(String s) => '"${s.replaceAll('"', '""')}"';
        return [r.id, esc(r.usuario), esc(r.usuarioRol), r.accion.label, esc(r.modulo), esc(r.detalle), r.ip, esc(r.dispositivo), fecha].join(',');
      }),
    ];

    final csvContent = lines.join('\n');
    // Copy to clipboard (works on all platforms including web)
    Clipboard.setData(ClipboardData(text: csvContent)).then((_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle_outline, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Expanded(child: Text('${records.length} registros exportados. CSV copiado al portapapeles.')),
              ],
            ),
            backgroundColor: const Color(0xFF2F8A5B),
            duration: const Duration(seconds: 4),
            action: SnackBarAction(
              label: 'OK',
              textColor: Colors.white,
              onPressed: () {},
            ),
          ),
        );
      }
    });
  }
}

// ─── Filter Dropdown ─────────────────────────────────────────────────────────

class _FilterDropdown<T> extends StatelessWidget {
  const _FilterDropdown({
    required this.hint,
    required this.value,
    required this.items,
    required this.labelOf,
    required this.onChanged,
  });
  final String hint;
  final T? value;
  final List<T> items;
  final String Function(T) labelOf;
  final ValueChanged<T?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFD4E0EC)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          hint: Text(hint, style: const TextStyle(fontSize: 13)),
          items: [
            DropdownMenuItem<T>(value: null, child: const Text('Todos', style: TextStyle(fontSize: 13))),
            ...items.map((item) => DropdownMenuItem<T>(
              value: item,
              child: Text(labelOf(item), style: const TextStyle(fontSize: 13)),
            )),
          ],
          onChanged: onChanged,
          style: const TextStyle(color: Color(0xFF001A35), fontSize: 13),
          isDense: true,
        ),
      ),
    );
  }
}

class _ColLabel extends StatelessWidget {
  const _ColLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(text, style: const TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF637995), fontSize: 12));
  }
}
