// ignore_for_file: constant_identifier_names
import 'package:flutter/material.dart';

// ─── Enums ───────────────────────────────────────────────────────────────────

enum UserRole {
  medico,
  enfermero,
  administrativo,
  auditor,
  administrador,
}

extension UserRoleExt on UserRole {
  String get label {
    switch (this) {
      case UserRole.medico:
        return 'Médico';
      case UserRole.enfermero:
        return 'Enfermero/a';
      case UserRole.administrativo:
        return 'Administrativo';
      case UserRole.auditor:
        return 'Auditor';
      case UserRole.administrador:
        return 'Administrador';
    }
  }

  Color get color {
    switch (this) {
      case UserRole.medico:
        return const Color(0xFF2F7DE1);
      case UserRole.enfermero:
        return const Color(0xFF2F8A5B);
      case UserRole.administrativo:
        return const Color(0xFFFFA927);
      case UserRole.auditor:
        return const Color(0xFF7A4FC3);
      case UserRole.administrador:
        return const Color(0xFF173E63);
    }
  }
}

enum UserStatus { activo, inactivo, suspendido }

extension UserStatusExt on UserStatus {
  String get label {
    switch (this) {
      case UserStatus.activo:
        return 'Activo';
      case UserStatus.inactivo:
        return 'Inactivo';
      case UserStatus.suspendido:
        return 'Suspendido';
    }
  }

  Color get color {
    switch (this) {
      case UserStatus.activo:
        return const Color(0xFF2F8A5B);
      case UserStatus.inactivo:
        return const Color(0xFF637995);
      case UserStatus.suspendido:
        return const Color(0xFFE84B4B);
    }
  }
}

enum AreaStatus { activa, inactiva }

extension AreaStatusExt on AreaStatus {
  String get label => this == AreaStatus.activa ? 'Activa' : 'Inactiva';
  Color get color =>
      this == AreaStatus.activa
          ? const Color(0xFF2F8A5B)
          : const Color(0xFF637995);
}

enum AuditActionType { login, logout, create, edit, delete, export, view, aprobar }

extension AuditActionTypeExt on AuditActionType {
  String get label {
    switch (this) {
      case AuditActionType.login:
        return 'Inicio sesión';
      case AuditActionType.logout:
        return 'Cierre sesión';
      case AuditActionType.create:
        return 'Creación';
      case AuditActionType.edit:
        return 'Edición';
      case AuditActionType.delete:
        return 'Eliminación';
      case AuditActionType.export:
        return 'Exportación';
      case AuditActionType.view:
        return 'Consulta';
      case AuditActionType.aprobar:
        return 'Aprobación';
    }
  }

  Color get color {
    switch (this) {
      case AuditActionType.login:
        return const Color(0xFF2F8A5B);
      case AuditActionType.logout:
        return const Color(0xFFE84B4B);
      case AuditActionType.create:
        return const Color(0xFF2F7DE1);
      case AuditActionType.edit:
        return const Color(0xFFFFA927);
      case AuditActionType.delete:
        return const Color(0xFFE84B4B);
      case AuditActionType.export:
        return const Color(0xFF7A4FC3);
      case AuditActionType.view:
        return const Color(0xFF637995);
      case AuditActionType.aprobar:
        return const Color(0xFF2F8A5B);
    }
  }

  IconData get icon {
    switch (this) {
      case AuditActionType.login:
        return Icons.login;
      case AuditActionType.logout:
        return Icons.logout;
      case AuditActionType.create:
        return Icons.add_circle_outline;
      case AuditActionType.edit:
        return Icons.edit_outlined;
      case AuditActionType.delete:
        return Icons.delete_outline;
      case AuditActionType.export:
        return Icons.download_outlined;
      case AuditActionType.view:
        return Icons.visibility_outlined;
      case AuditActionType.aprobar:
        return Icons.verified_outlined;
    }
  }
}

// ─── Models ──────────────────────────────────────────────────────────────────

class AppUser {
  final String id;
  final String nombres;
  final String apellidos;
  final String dni;
  final String email;
  final String telefono;
  final UserRole rol;
  final String area;
  final String establecimiento;
  UserStatus estado;
  final String? cmp;
  final String? colegiatura;
  final String username;
  final DateTime lastAccess;
  final DateTime fechaNacimiento;
  final String sexo;
  final String cargo;
  bool forzarCambioPassword;

  AppUser({
    required this.id,
    required this.nombres,
    required this.apellidos,
    required this.dni,
    required this.email,
    required this.telefono,
    required this.rol,
    required this.area,
    required this.establecimiento,
    required this.estado,
    this.cmp,
    this.colegiatura,
    required this.username,
    required this.lastAccess,
    required this.fechaNacimiento,
    required this.sexo,
    required this.cargo,
    this.forzarCambioPassword = false,
  });

  String get nombreCompleto => '$nombres $apellidos';

  String get initials {
    final parts = nombreCompleto.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return nombreCompleto.substring(0, 2).toUpperCase();
  }

  // ─── JSON serialization ───────────────────────────────────────────────────

  factory AppUser.fromJson(Map<String, dynamic> json) => AppUser(
        id: json['id'] as String,
        nombres: json['nombres'] as String,
        apellidos: json['apellidos'] as String,
        dni: json['dni'] as String,
        email: json['email'] as String,
        telefono: (json['telefono'] as String?) ?? '',
        rol: UserRole.values.firstWhere(
          (r) => r.name.toUpperCase() == (json['rol'] as String).toUpperCase(),
          orElse: () => UserRole.administrativo,
        ),
        area: (json['area'] as String?) ?? '',
        establecimiento: (json['establecimiento'] as String?) ?? '',
        estado: UserStatus.values.firstWhere(
          (s) => s.name.toUpperCase() == (json['estado'] as String).toUpperCase(),
          orElse: () => UserStatus.activo,
        ),
        cmp: json['cmp'] as String?,
        colegiatura: json['colegiatura'] as String?,
        username: json['username'] as String,
        lastAccess: json['lastAccess'] != null
            ? DateTime.parse(json['lastAccess'] as String)
            : DateTime.now(),
        fechaNacimiento: json['fechaNacimiento'] != null
            ? DateTime.parse(json['fechaNacimiento'] as String)
            : DateTime(1990, 1, 1),
        sexo: (json['sexo'] as String?) ?? 'Masculino',
        cargo: (json['cargo'] as String?) ?? '',
        forzarCambioPassword: (json['forzarCambioPassword'] as bool?) ?? false,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'nombres': nombres,
        'apellidos': apellidos,
        'dni': dni,
        'email': email,
        'telefono': telefono,
        'rol': rol.name.toUpperCase(),
        'area': area,
        'establecimiento': establecimiento,
        'estado': estado.name.toUpperCase(),
        if (cmp != null) 'cmp': cmp,
        if (colegiatura != null) 'colegiatura': colegiatura,
        'username': username,
        'lastAccess': lastAccess.toIso8601String(),
        'fechaNacimiento': fechaNacimiento.toIso8601String().substring(0, 10),
        'sexo': sexo,
        'cargo': cargo,
        'forzarCambioPassword': forzarCambioPassword,
      };

  /// For POST /api/admin/users and PUT /api/admin/users/{id}
  Map<String, dynamic> toCreateJson({String password = '123456'}) => {
        'nombres': nombres,
        'apellidos': apellidos,
        'dni': dni,
        'email': email,
        'telefono': telefono,
        'rol': rol.name.toUpperCase(),
        'area': area,
        'establecimiento': establecimiento,
        'estado': estado.name.toUpperCase(),
        if (cmp != null && cmp!.isNotEmpty) 'cmp': cmp,
        if (colegiatura != null && colegiatura!.isNotEmpty) 'colegiatura': colegiatura,
        'username': username,
        'password': password,
        'fechaNacimiento': fechaNacimiento.toIso8601String().substring(0, 10),
        'sexo': sexo,
        'cargo': cargo,
        'forzarCambioPassword': forzarCambioPassword,
      };
}

class ModulePermission {
  final String module;
  bool ver;
  bool crear;
  bool editar;
  bool eliminar;
  bool exportar;
  bool aprobarFirmar;

  ModulePermission({
    required this.module,
    this.ver = false,
    this.crear = false,
    this.editar = false,
    this.eliminar = false,
    this.exportar = false,
    this.aprobarFirmar = false,
  });

  ModulePermission copyWith({
    bool? ver,
    bool? crear,
    bool? editar,
    bool? eliminar,
    bool? exportar,
    bool? aprobarFirmar,
  }) {
    return ModulePermission(
      module: module,
      ver: ver ?? this.ver,
      crear: crear ?? this.crear,
      editar: editar ?? this.editar,
      eliminar: eliminar ?? this.eliminar,
      exportar: exportar ?? this.exportar,
      aprobarFirmar: aprobarFirmar ?? this.aprobarFirmar,
    );
  }
}

class RoleDefinition {
  final UserRole role;
  final List<ModulePermission> permissions;

  RoleDefinition({required this.role, required this.permissions});
}

class MedicalArea {
  final String id;
  final String nombre;
  final String codigo;
  final String descripcion;
  final String responsable;
  int personalAsignado;
  AreaStatus estado;
  final String horario;

  MedicalArea({
    required this.id,
    required this.nombre,
    required this.codigo,
    required this.descripcion,
    required this.responsable,
    required this.personalAsignado,
    required this.estado,
    required this.horario,
  });

  // ─── JSON serialization ───────────────────────────────────────────────────

  factory MedicalArea.fromJson(Map<String, dynamic> json) => MedicalArea(
        id: json['id'] as String,
        nombre: json['nombre'] as String,
        codigo: json['codigo'] as String,
        descripcion: (json['descripcion'] as String?) ?? '',
        responsable: (json['responsable'] as String?) ?? '',
        personalAsignado: (json['personalAsignado'] as num?)?.toInt() ?? 0,
        estado: AreaStatus.values.firstWhere(
          (s) => s.name.toUpperCase() == (json['estado'] as String).toUpperCase(),
          orElse: () => AreaStatus.activa,
        ),
        horario: (json['horario'] as String?) ?? '',
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'nombre': nombre,
        'codigo': codigo,
        'descripcion': descripcion,
        'responsable': responsable,
        'personalAsignado': personalAsignado,
        'estado': estado.name.toUpperCase(),
        'horario': horario,
      };
}

class Establishment {
  final String id;
  final String nombre;
  final String codigoRenipress;
  final String red;
  final String microred;
  final String distrito;
  final String provincia;
  final String departamento;
  final String responsable;
  final String telefono;
  bool activo;

  Establishment({
    required this.id,
    required this.nombre,
    required this.codigoRenipress,
    required this.red,
    required this.microred,
    required this.distrito,
    required this.provincia,
    required this.departamento,
    required this.responsable,
    required this.telefono,
    required this.activo,
  });

  // ─── JSON serialization ───────────────────────────────────────────────────

  factory Establishment.fromJson(Map<String, dynamic> json) => Establishment(
        id: json['id'] as String,
        nombre: json['nombre'] as String,
        codigoRenipress: json['codigoRenipress'] as String,
        red: (json['red'] as String?) ?? '',
        microred: (json['microred'] as String?) ?? '',
        distrito: (json['distrito'] as String?) ?? '',
        provincia: (json['provincia'] as String?) ?? '',
        departamento: (json['departamento'] as String?) ?? '',
        responsable: (json['responsable'] as String?) ?? '',
        telefono: (json['telefono'] as String?) ?? '',
        activo: (json['activo'] as bool?) ?? true,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'nombre': nombre,
        'codigoRenipress': codigoRenipress,
        'red': red,
        'microred': microred,
        'distrito': distrito,
        'provincia': provincia,
        'departamento': departamento,
        'responsable': responsable,
        'telefono': telefono,
        'activo': activo,
      };
}

class AuditRecord {
  final String id;
  final String usuario;
  final String usuarioRol;
  final AuditActionType accion;
  final String modulo;
  final String detalle;
  final String ip;
  final String dispositivo;
  final DateTime fecha;

  AuditRecord({
    required this.id,
    required this.usuario,
    required this.usuarioRol,
    required this.accion,
    required this.modulo,
    required this.detalle,
    required this.ip,
    required this.dispositivo,
    required this.fecha,
  });

  // ─── JSON serialization ───────────────────────────────────────────────────

  factory AuditRecord.fromJson(Map<String, dynamic> json) => AuditRecord(
        id: json['id'] as String,
        usuario: json['usuario'] as String,
        usuarioRol: json['usuarioRol'] as String,
        accion: AuditActionType.values.firstWhere(
          (a) => a.name.toUpperCase() == (json['accion'] as String).toUpperCase(),
          orElse: () => AuditActionType.view,
        ),
        modulo: json['modulo'] as String,
        detalle: (json['detalle'] as String?) ?? '',
        ip: (json['ip'] as String?) ?? '',
        dispositivo: (json['dispositivo'] as String?) ?? '',
        fecha: DateTime.parse(json['fecha'] as String),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'usuario': usuario,
        'usuarioRol': usuarioRol,
        'accion': accion.name.toUpperCase(),
        'modulo': modulo,
        'detalle': detalle,
        'ip': ip,
        'dispositivo': dispositivo,
        'fecha': fecha.toIso8601String(),
      };
}
