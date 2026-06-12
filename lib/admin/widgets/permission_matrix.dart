import 'package:flutter/material.dart';
import '../admin_models.dart';
import '../admin_mock_data.dart';

class PermissionMatrix extends StatefulWidget {
  const PermissionMatrix({super.key, required this.roleDefinition});
  final RoleDefinition roleDefinition;

  @override
  State<PermissionMatrix> createState() => _PermissionMatrixState();
}

class _PermissionMatrixState extends State<PermissionMatrix> {
  late List<ModulePermission> _permissions;
  bool _hasChanges = false;

  static const _permLabels = [
    ('ver', 'Ver'),
    ('crear', 'Crear'),
    ('editar', 'Editar'),
    ('eliminar', 'Eliminar'),
    ('exportar', 'Exportar'),
    ('aprobar', 'Aprobar/Firmar'),
  ];

  @override
  void initState() {
    super.initState();
    _permissions = widget.roleDefinition.permissions
        .map(
          (p) => ModulePermission(
            module: p.module,
            ver: p.ver,
            crear: p.crear,
            editar: p.editar,
            eliminar: p.eliminar,
            exportar: p.exportar,
            aprobarFirmar: p.aprobarFirmar,
          ),
        )
        .toList();
  }

  bool _getPermValue(ModulePermission p, String perm) {
    switch (perm) {
      case 'ver':
        return p.ver;
      case 'crear':
        return p.crear;
      case 'editar':
        return p.editar;
      case 'eliminar':
        return p.eliminar;
      case 'exportar':
        return p.exportar;
      case 'aprobar':
        return p.aprobarFirmar;
      default:
        return false;
    }
  }

  void _setPermValue(int idx, String perm, bool value) {
    setState(() {
      _hasChanges = true;
      final p = _permissions[idx];
      switch (perm) {
        case 'ver':
          _permissions[idx] = p.copyWith(ver: value);
          break;
        case 'crear':
          _permissions[idx] = p.copyWith(crear: value);
          break;
        case 'editar':
          _permissions[idx] = p.copyWith(editar: value);
          break;
        case 'eliminar':
          _permissions[idx] = p.copyWith(eliminar: value);
          break;
        case 'exportar':
          _permissions[idx] = p.copyWith(exportar: value);
          break;
        case 'aprobar':
          _permissions[idx] = p.copyWith(aprobarFirmar: value);
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 700;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isNarrow)
              _buildMobileMatrix()
            else
              _buildDesktopMatrix(),
            if (_hasChanges) ...[
              const SizedBox(height: 20),
              Row(
                children: [
                  FilledButton.icon(
                    onPressed: () {
                      // Update mock data
                      final roleIdx = mockRoles.indexWhere(
                        (r) => r.role == widget.roleDefinition.role,
                      );
                      if (roleIdx >= 0) {
                        mockRoles[roleIdx].permissions
                            .asMap()
                            .forEach((i, p) {
                          if (i < _permissions.length) {
                            p.ver = _permissions[i].ver;
                            p.crear = _permissions[i].crear;
                            p.editar = _permissions[i].editar;
                            p.eliminar = _permissions[i].eliminar;
                            p.exportar = _permissions[i].exportar;
                            p.aprobarFirmar = _permissions[i].aprobarFirmar;
                          }
                        });
                      }
                      setState(() => _hasChanges = false);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Permisos de ${widget.roleDefinition.role.label} guardados correctamente',
                          ),
                          backgroundColor: const Color(0xFF2F8A5B),
                        ),
                      );
                    },
                    icon: const Icon(Icons.save_outlined),
                    label: const Text('Guardar cambios'),
                  ),
                  const SizedBox(width: 12),
                  OutlinedButton(
                    onPressed: () {
                      setState(() {
                        _permissions = widget.roleDefinition.permissions
                            .map(
                              (p) => ModulePermission(
                                module: p.module,
                                ver: p.ver,
                                crear: p.crear,
                                editar: p.editar,
                                eliminar: p.eliminar,
                                exportar: p.exportar,
                                aprobarFirmar: p.aprobarFirmar,
                              ),
                            )
                            .toList();
                        _hasChanges = false;
                      });
                    },
                    child: const Text('Cancelar'),
                  ),
                ],
              ),
            ],
          ],
        );
      },
    );
  }

  Widget _buildDesktopMatrix() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        headingRowColor: WidgetStateProperty.all(const Color(0xFFF4F7FB)),
        columnSpacing: 20,
        columns: [
          const DataColumn(
            label: Text(
              'MÓDULO',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                color: Color(0xFF637995),
              ),
            ),
          ),
          for (final perm in _permLabels)
            DataColumn(
              label: Text(
                perm.$2.toUpperCase(),
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF637995),
                  fontSize: 12,
                ),
              ),
            ),
        ],
        rows: _permissions.asMap().entries.map((entry) {
          final idx = entry.key;
          final p = entry.value;
          return DataRow(
            cells: [
              DataCell(
                Text(
                  p.module,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
              for (final perm in _permLabels)
                DataCell(
                    Transform.scale(
                      scale: 0.85,
                      child: Switch(
                        value: _getPermValue(p, perm.$1),
                        onChanged: (v) => _setPermValue(idx, perm.$1, v),
                        activeThumbColor: Colors.white,
                        activeTrackColor: const Color(0xFF173E63),
                      ),
                    ),
                ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMobileMatrix() {
    return Column(
      children: _permissions.asMap().entries.map((entry) {
        final idx = entry.key;
        final p = entry.value;
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFF7FAFE),
            border: Border.all(color: const Color(0xFFD4E0EC)),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                p.module,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _permLabels.map((perm) {
                  final val = _getPermValue(p, perm.$1);
                  return GestureDetector(
                    onTap: () => _setPermValue(idx, perm.$1, !val),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: val
                            ? const Color(0xFF173E63)
                            : const Color(0xFFEAF0F6),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        perm.$2,
                        style: TextStyle(
                          color: val ? Colors.white : const Color(0xFF637995),
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
