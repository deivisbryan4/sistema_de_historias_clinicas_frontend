/// Modelo de sesión del usuario activo.
/// Persiste el rol y datos del usuario logueado.
class UserSession {
  UserSession._();
  static final UserSession instance = UserSession._();

  UserRol _rol = UserRol.medico;
  String _nombre = '';
  String _dni = '';
  String _cargo = '';
  String _area = '';
  String _cmp = '';

  UserRol get rol => _rol;
  String get nombre => _nombre;
  String get dni => _dni;
  String get cargo => _cargo;
  String get area => _area;
  String get cmp => _cmp;

  String get initials {
    final parts = _nombre.split(' ');
    return parts.length >= 2
        ? '${parts[0][0]}${parts[1][0]}'.toUpperCase()
        : _nombre.isNotEmpty
            ? _nombre.substring(0, 2).toUpperCase()
            : 'US';
  }

  void login({
    required UserRol rol,
    required String nombre,
    required String dni,
    required String cargo,
    required String area,
    String cmp = '',
  }) {
    _rol = rol;
    _nombre = nombre;
    _dni = dni;
    _cargo = cargo;
    _area = area;
    _cmp = cmp;
  }

  void logout() {
    _rol = UserRol.medico;
    _nombre = '';
    _dni = '';
    _cargo = '';
    _area = '';
    _cmp = '';
  }
}

enum UserRol {
  medico,
  enfermero,
  administrativo,
  paciente,
  auditor,
  administrador;

  String get label {
    switch (this) {
      case medico:
        return 'Médico';
      case enfermero:
        return 'Enfermero/a';
      case administrativo:
        return 'Administrativo';
      case paciente:
        return 'Paciente';
      case auditor:
        return 'Auditor';
      case administrador:
        return 'Administrador';
    }
  }

  String get icon {
    switch (this) {
      case medico:
        return '👨‍⚕️';
      case enfermero:
        return '👩‍⚕️';
      case administrativo:
        return '🗂️';
      case paciente:
        return '🏥';
      case auditor:
        return '🔍';
      case administrador:
        return '⚙️';
    }
  }
}
