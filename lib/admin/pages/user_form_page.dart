import 'package:flutter/material.dart';
import '../admin_models.dart';

class UserFormDialog extends StatefulWidget {
  const UserFormDialog({super.key, this.user, required this.onSave});
  final AppUser? user;
  final void Function(AppUser) onSave;

  @override
  State<UserFormDialog> createState() => _UserFormDialogState();
}

class _UserFormDialogState extends State<UserFormDialog> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nombres;
  late final TextEditingController _apellidos;
  late final TextEditingController _dni;
  late final TextEditingController _email;
  late final TextEditingController _telefono;
  late final TextEditingController _cargo;
  late final TextEditingController _cmp;
  late final TextEditingController _colegiatura;
  late final TextEditingController _username;
  late final TextEditingController _password;

  UserRole _rol = UserRole.administrativo;
  String _area = 'Medicina General';
  String _establecimiento = 'C.S. Juliaca';
  UserStatus _estado = UserStatus.activo;
  String _sexo = 'Masculino';
  bool _forzarCambio = true;

  @override
  void initState() {
    super.initState();
    final u = widget.user;
    _nombres = TextEditingController(text: u?.nombres ?? '');
    _apellidos = TextEditingController(text: u?.apellidos ?? '');
    _dni = TextEditingController(text: u?.dni ?? '');
    _email = TextEditingController(text: u?.email ?? '');
    _telefono = TextEditingController(text: u?.telefono ?? '');
    _cargo = TextEditingController(text: u?.cargo ?? '');
    _cmp = TextEditingController(text: u?.cmp ?? '');
    _colegiatura = TextEditingController(text: u?.colegiatura ?? '');
    _username = TextEditingController(text: u?.username ?? '');
    _password = TextEditingController();
    if (u != null) {
      _rol = u.rol;
      _area = u.area;
      _establecimiento = u.establecimiento;
      _estado = u.estado;
      _sexo = u.sexo;
      _forzarCambio = u.forzarCambioPassword;
    }
  }

  @override
  void dispose() {
    for (final c in [
      _nombres, _apellidos, _dni, _email, _telefono,
      _cargo, _cmp, _colegiatura, _username, _password,
    ]) { c.dispose(); }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.user != null;
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720, maxHeight: 700),
        child: Column(
          children: [
            _buildDialogHeader(isEdit),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(28),
                child: Form(
                  key: _formKey,
                  child: LayoutBuilder(
                    builder: (context, c) {
                      final twoCol = c.maxWidth >= 480;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _sectionTitle(Icons.person_outline, 'Datos personales'),
                          twoCol
                              ? _twoCol(
                                  _field('Nombres *', _nombres, validator: _required),
                                  _field('Apellidos *', _apellidos, validator: _required),
                                )
                              : Column(children: [
                                  _field('Nombres *', _nombres, validator: _required),
                                  _field('Apellidos *', _apellidos, validator: _required),
                                ]),
                          twoCol
                              ? _twoCol(
                                  _field('DNI *', _dni, validator: _requiredDni, keyboardType: TextInputType.number),
                                  _field('Teléfono', _telefono, keyboardType: TextInputType.phone),
                                )
                              : Column(children: [
                                  _field('DNI *', _dni, validator: _requiredDni, keyboardType: TextInputType.number),
                                  _field('Teléfono', _telefono, keyboardType: TextInputType.phone),
                                ]),
                          twoCol
                              ? _twoCol(
                                  _field('Correo institucional *', _email, validator: _requiredEmail, keyboardType: TextInputType.emailAddress),
                                  _dropdownSexo(),
                                )
                              : Column(children: [
                                  _field('Correo institucional *', _email, validator: _requiredEmail, keyboardType: TextInputType.emailAddress),
                                  _dropdownSexo(),
                                ]),
                          const SizedBox(height: 8),
                          _sectionTitle(Icons.work_outline, 'Datos laborales'),
                          twoCol
                              ? _twoCol(
                                  _field('Cargo', _cargo),
                                  _dropdownRol(),
                                )
                              : Column(children: [
                                  _field('Cargo', _cargo),
                                  _dropdownRol(),
                                ]),
                          twoCol
                              ? _twoCol(_dropdownArea(), _dropdownEstablishment())
                              : Column(children: [_dropdownArea(), _dropdownEstablishment()]),
                          if (_rol == UserRole.medico) ...[
                            _field(
                              'CMP *',
                              _cmp,
                              validator: (v) =>
                                  (v == null || v.isEmpty) ? 'CMP es obligatorio para médicos' : null,
                              keyboardType: TextInputType.number,
                            ),
                          ],
                          if (_rol == UserRole.enfermero)
                            _field('N° Colegiatura', _colegiatura),
                          const SizedBox(height: 8),
                          _sectionTitle(Icons.lock_outline, 'Credenciales y acceso'),
                          twoCol
                              ? _twoCol(
                                  _field('Usuario *', _username, validator: _required),
                                  _field(
                                    isEdit ? 'Nueva contraseña' : 'Contraseña temporal *',
                                    _password,
                                    obscure: true,
                                    validator: isEdit ? null : _required,
                                  ),
                                )
                              : Column(children: [
                                  _field('Usuario *', _username, validator: _required),
                                  _field(
                                    isEdit ? 'Nueva contraseña' : 'Contraseña temporal *',
                                    _password,
                                    obscure: true,
                                    validator: isEdit ? null : _required,
                                  ),
                                ]),
                          CheckboxListTile(
                            value: _forzarCambio,
                            onChanged: (v) => setState(() => _forzarCambio = v ?? true),
                            contentPadding: EdgeInsets.zero,
                            title: const Text('Forzar cambio de contraseña en primer ingreso'),
                            controlAffinity: ListTileControlAffinity.leading,
                          ),
                          _dropdownEstado(),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
            _buildDialogFooter(isEdit),
          ],
        ),
      ),
    );
  }

  Widget _buildDialogHeader(bool isEdit) {
    return Container(
      padding: const EdgeInsets.fromLTRB(28, 22, 20, 18),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFEAF0F6))),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF173E63).withValues(alpha: .1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              isEdit ? Icons.edit_outlined : Icons.person_add_outlined,
              color: const Color(0xFF173E63),
              size: 20,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              isEdit ? 'Editar usuario' : 'Nuevo usuario',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
          ),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close),
          ),
        ],
      ),
    );
  }

  Widget _buildDialogFooter(bool isEdit) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Color(0xFFEAF0F6))),
      ),
      child: Row(
        children: [
          if (isEdit) ...[
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFFE84B4B),
                side: const BorderSide(color: Color(0xFFE84B4B)),
              ),
              onPressed: () {
                setState(() {
                  widget.user!.estado = UserStatus.inactivo;
                });
                Navigator.pop(context);
              },
              icon: const Icon(Icons.person_off_outlined, size: 16),
              label: const Text('Desactivar'),
            ),
            const SizedBox(width: 8),
          ],
          const Spacer(),
          OutlinedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          const SizedBox(width: 12),
          FilledButton.icon(
            onPressed: _save,
            icon: const Icon(Icons.save_outlined, size: 16),
            label: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final u = widget.user;
    final newUser = AppUser(
      id: u?.id ?? 'u${DateTime.now().millisecondsSinceEpoch}',
      nombres: _nombres.text.trim(),
      apellidos: _apellidos.text.trim(),
      dni: _dni.text.trim(),
      email: _email.text.trim(),
      telefono: _telefono.text.trim(),
      rol: _rol,
      area: _area,
      establecimiento: _establecimiento,
      estado: _estado,
      cmp: _rol == UserRole.medico ? _cmp.text.trim() : null,
      colegiatura: _rol == UserRole.enfermero ? _colegiatura.text.trim() : null,
      username: _username.text.trim(),
      lastAccess: u?.lastAccess ?? DateTime.now(),
      fechaNacimiento: u?.fechaNacimiento ?? DateTime(1990, 1, 1),
      sexo: _sexo,
      cargo: _cargo.text.trim(),
      forzarCambioPassword: _forzarCambio,
    );
    widget.onSave(newUser);
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          u == null
              ? 'Usuario ${newUser.nombreCompleto} creado exitosamente'
              : 'Usuario ${newUser.nombreCompleto} actualizado',
        ),
        backgroundColor: const Color(0xFF2F8A5B),
      ),
    );
  }

  // ── Field builders ───────────────────────────────────────────────────────

  Widget _sectionTitle(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16, top: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: const Color(0xFF173E63)),
          const SizedBox(width: 8),
          Text(
            text,
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              color: Color(0xFF173E63),
              fontSize: 14,
            ),
          ),
          const SizedBox(width: 8),
          const Expanded(child: Divider()),
        ],
      ),
    );
  }

  Widget _twoCol(Widget left, Widget right) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: left),
        const SizedBox(width: 16),
        Expanded(child: right),
      ],
    );
  }

  Widget _field(
    String label,
    TextEditingController ctrl, {
    String? Function(String?)? validator,
    bool obscure = false,
    TextInputType? keyboardType,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: ctrl,
        obscureText: obscure,
        keyboardType: keyboardType,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          filled: true,
          fillColor: const Color(0xFFF7FAFE),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 12,
          ),
        ),
      ),
    );
  }

  Widget _dropdownRol() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<UserRole>(
        value: _rol,
        decoration: InputDecoration(
          labelText: 'Rol *',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          filled: true,
          fillColor: const Color(0xFFF7FAFE),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 12,
          ),
        ),
        validator: (v) => v == null ? 'Seleccione un rol' : null,
        items: UserRole.values
            .map((r) => DropdownMenuItem(value: r, child: Text(r.label)))
            .toList(),
        onChanged: (v) => setState(() => _rol = v ?? _rol),
      ),
    );
  }

  Widget _dropdownArea() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        initialValue: _area,
        decoration: InputDecoration(
          labelText: 'Área *',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          filled: true,
          fillColor: const Color(0xFFF7FAFE),
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        ),
        validator: (v) => (v == null || v.trim().isEmpty) ? 'Ingrese el área' : null,
        onChanged: (v) => _area = v,
        onSaved: (v) => _area = v ?? _area,
      ),
    );
  }

  Widget _dropdownEstablishment() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        initialValue: _establecimiento,
        decoration: InputDecoration(
          labelText: 'Establecimiento *',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          filled: true,
          fillColor: const Color(0xFFF7FAFE),
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        ),
        onChanged: (v) => _establecimiento = v,
        onSaved: (v) => _establecimiento = v ?? _establecimiento,
      ),
    );
  }

  Widget _dropdownSexo() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<String>(
        value: _sexo,
        decoration: InputDecoration(
          labelText: 'Sexo',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          filled: true,
          fillColor: const Color(0xFFF7FAFE),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 12,
          ),
        ),
        items: const [
          DropdownMenuItem(value: 'Masculino', child: Text('Masculino')),
          DropdownMenuItem(value: 'Femenino', child: Text('Femenino')),
          DropdownMenuItem(value: 'Otro', child: Text('Otro')),
        ],
        onChanged: (v) => setState(() => _sexo = v ?? _sexo),
      ),
    );
  }

  Widget _dropdownEstado() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<UserStatus>(
        value: _estado,
        decoration: InputDecoration(
          labelText: 'Estado del usuario',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          filled: true,
          fillColor: const Color(0xFFF7FAFE),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 12,
          ),
        ),
        items: UserStatus.values
            .map((s) => DropdownMenuItem(value: s, child: Text(s.label)))
            .toList(),
        onChanged: (v) => setState(() => _estado = v ?? _estado),
      ),
    );
  }

  String? _required(String? v) =>
      (v == null || v.trim().isEmpty) ? 'Campo obligatorio' : null;
  String? _requiredDni(String? v) {
    if (v == null || v.trim().isEmpty) return 'DNI obligatorio';
    if (v.trim().length != 8) return 'DNI debe tener 8 dígitos';
    return null;
  }
  String? _requiredEmail(String? v) {
    if (v == null || v.trim().isEmpty) return 'Correo obligatorio';
    if (!v.contains('@')) return 'Ingrese un correo válido';
    return null;
  }
}
