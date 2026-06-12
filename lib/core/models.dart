// ─── Modelos de dominio ──────────────────────────────────────────────────────
// Todos con fromJson/toJson listos para conectar con el API Spring Boot
// NOTA: UserRol está definido en core/user_session.dart

// ── Enums de estado ───────────────────────────────────────────────────────────
enum UserStatus { activo, inactivo, suspendido }
enum PatientStatus { activo, cronico, nuevo, inactivo }
enum HistoryStatus { borrador, completada, firmada }
enum PrescriptionStatus { vigente, dispensada, vencida, anulada }
enum SessionStatus { programada, enCurso, completada, cancelada }
enum AreaStatus { activa, inactiva }
enum AuditAction { login, logout, create, edit, deleteRecord, exportRecord, view, aprobar }

// ── AppUser ──────────────────────────────────────────────────────────────────
class AppUser {
  final String id;
  final String nombres;
  final String apellidos;
  final String dni;
  final String email;
  final String telefono;
  final String rol;
  final String area;
  final String estado;
  final String username;
  final String? cmp;
  final String? cargo;
  final String? lastAccess;

  const AppUser({
    required this.id,
    required this.nombres,
    required this.apellidos,
    required this.dni,
    required this.email,
    required this.telefono,
    required this.rol,
    required this.area,
    required this.estado,
    required this.username,
    this.cmp,
    this.cargo,
    this.lastAccess,
  });

  String get nombreCompleto => '$nombres $apellidos';
  String get initials {
    final parts = nombreCompleto.split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return nombres.isNotEmpty ? nombres[0].toUpperCase() : '?';
  }

  factory AppUser.fromJson(Map<String, dynamic> j) => AppUser(
        id: j['id'] ?? '',
        nombres: j['nombres'] ?? '',
        apellidos: j['apellidos'] ?? '',
        dni: j['dni'] ?? '',
        email: j['email'] ?? '',
        telefono: j['telefono'] ?? '',
        rol: j['rol'] ?? '',
        area: j['area'] ?? '',
        estado: j['estado'] ?? '',
        username: j['username'] ?? '',
        cmp: j['cmp'],
        cargo: j['cargo'],
        lastAccess: j['lastAccess'],
      );

  Map<String, dynamic> toJson() => {
        'nombres': nombres,
        'apellidos': apellidos,
        'dni': dni,
        'email': email,
        'telefono': telefono,
        'rol': rol,
        'area': area,
        'estado': estado,
        'username': username,
        if (cmp != null) 'cmp': cmp,
        if (cargo != null) 'cargo': cargo,
      };
}

// ── Patient ───────────────────────────────────────────────────────────────────
class Patient {
  final String id;
  final String nombres;
  final String apellidos;
  final String dni;
  final String? fechaNacimiento;
  final String sexo;
  final String? telefono;
  final String? email;
  final String asegurado;
  final String? grupoSanguineo;
  final String estado;
  final String numeroHc;
  final String? alertas;
  final String? distrito;
  final String? provincia;
  final String? creadoEn;
  final String? estadoCivil;
  final String? ocupacion;
  final String? direccion;

  const Patient({
    required this.id,
    required this.nombres,
    required this.apellidos,
    required this.dni,
    this.fechaNacimiento,
    required this.sexo,
    this.telefono,
    this.email,
    required this.asegurado,
    this.grupoSanguineo,
    required this.estado,
    required this.numeroHc,
    this.alertas,
    this.distrito,
    this.provincia,
    this.creadoEn,
    this.estadoCivil,
    this.ocupacion,
    this.direccion,
  });

  String get nombreCompleto => '$nombres $apellidos';
  String get initials {
    final p = nombreCompleto.split(' ');
    return p.length >= 2 ? '${p[0][0]}${p[1][0]}'.toUpperCase() : '?';
  }

  factory Patient.fromJson(Map<String, dynamic> j) => Patient(
        id: j['id'] ?? '',
        nombres: j['nombres'] ?? '',
        apellidos: j['apellidos'] ?? '',
        dni: j['dni'] ?? '',
        fechaNacimiento: j['fechaNacimiento'],
        sexo: j['sexo'] ?? '',
        telefono: j['telefono'],
        email: j['email'],
        asegurado: j['asegurado'] ?? '',
        grupoSanguineo: j['grupoSanguineo'],
        estado: j['estado'] ?? '',
        numeroHc: j['numeroHc'] ?? '',
        alertas: j['alertas'],
        distrito: j['distrito'],
        provincia: j['provincia'],
        creadoEn: j['creadoEn'],
        estadoCivil: j['estadoCivil'],
        ocupacion: j['ocupacion'],
        direccion: j['direccion'],
      );

  Map<String, dynamic> toJson() => {
        'nombres': nombres,
        'apellidos': apellidos,
        'dni': dni,
        if (fechaNacimiento != null) 'fechaNacimiento': fechaNacimiento,
        'sexo': sexo,
        if (telefono != null) 'telefono': telefono,
        if (email != null) 'email': email,
        'asegurado': asegurado,
        if (grupoSanguineo != null) 'grupoSanguineo': grupoSanguineo,
        'estado': estado,
        if (alertas != null) 'alertas': alertas,
        if (distrito != null) 'distrito': distrito,
        if (provincia != null) 'provincia': provincia,
        if (estadoCivil != null) 'estadoCivil': estadoCivil,
        if (ocupacion != null) 'ocupacion': ocupacion,
        if (direccion != null) 'direccion': direccion,
      };
}

// ── Diagnosis ─────────────────────────────────────────────────────────────────
class Diagnosis {
  final String id;
  final String codigoCie10;
  final String descripcion;
  final String tipo;
  final String? observacion;

  const Diagnosis({
    required this.id,
    required this.codigoCie10,
    required this.descripcion,
    required this.tipo,
    this.observacion,
  });

  factory Diagnosis.fromJson(Map<String, dynamic> j) => Diagnosis(
        id: j['id'] ?? '',
        codigoCie10: j['codigoCie10'] ?? '',
        descripcion: j['descripcion'] ?? '',
        tipo: j['tipo'] ?? '',
        observacion: j['observacion'],
      );

  Map<String, dynamic> toJson() => {
        'codigoCie10': codigoCie10,
        'descripcion': descripcion,
        'tipo': tipo,
        if (observacion != null) 'observacion': observacion,
      };
}

// ── VitalSigns ────────────────────────────────────────────────────────────────
class VitalSigns {
  final String? id;
  final int? presionSistolica;
  final int? presionDiastolica;
  final int? frecuenciaCardiaca;
  final int? frecuenciaRespiratoria;
  final double? temperatura;
  final int? saturacionOxigeno;
  final double? peso;
  final double? talla;
  final double? imc;

  const VitalSigns({
    this.id,
    this.presionSistolica,
    this.presionDiastolica,
    this.frecuenciaCardiaca,
    this.frecuenciaRespiratoria,
    this.temperatura,
    this.saturacionOxigeno,
    this.peso,
    this.talla,
    this.imc,
  });

  factory VitalSigns.fromJson(Map<String, dynamic> j) => VitalSigns(
        id: j['id'],
        presionSistolica: j['presionSistolica'],
        presionDiastolica: j['presionDiastolica'],
        frecuenciaCardiaca: j['frecuenciaCardiaca'],
        frecuenciaRespiratoria: j['frecuenciaRespiratoria'],
        temperatura: (j['temperatura'] as num?)?.toDouble(),
        saturacionOxigeno: j['saturacionOxigeno'],
        peso: (j['peso'] as num?)?.toDouble(),
        talla: (j['talla'] as num?)?.toDouble(),
        imc: (j['imc'] as num?)?.toDouble(),
      );

  Map<String, dynamic> toJson() => {
        if (presionSistolica != null) 'presionSistolica': presionSistolica,
        if (presionDiastolica != null) 'presionDiastolica': presionDiastolica,
        if (frecuenciaCardiaca != null)
          'frecuenciaCardiaca': frecuenciaCardiaca,
        if (frecuenciaRespiratoria != null)
          'frecuenciaRespiratoria': frecuenciaRespiratoria,
        if (temperatura != null) 'temperatura': temperatura,
        if (saturacionOxigeno != null)
          'saturacionOxigeno': saturacionOxigeno,
        if (peso != null) 'peso': peso,
        if (talla != null) 'talla': talla,
      };
}

// ── ClinicalHistory ───────────────────────────────────────────────────────────
class ClinicalHistory {
  final String id;
  final String patientId;
  final String patientNombre;
  final String medico;
  final String medicoId;
  final String fechaAtencion;
  final String especialidad;
  final String estado;
  final String? motivoConsulta;
  final String? enfermedadActual;
  final String? observaciones;
  final String? planTratamiento;
  final String? tipoAtencion;
  final String? referencia;
  final String? contrarreferencia;
  final String? establecimientoOrigen;
  final String? establecimientoDestino;
  final int? tiempoAccesoHistoria;
  final int? tiempoAtencion;
  final String? estadoIntercambio;
  final String? recursoFhir;
  final List<Diagnosis> diagnosticos;
  final VitalSigns? signosVitales;

  const ClinicalHistory({
    required this.id,
    required this.patientId,
    required this.patientNombre,
    required this.medico,
    required this.medicoId,
    required this.fechaAtencion,
    required this.especialidad,
    required this.estado,
    this.motivoConsulta,
    this.enfermedadActual,
    this.observaciones,
    this.planTratamiento,
    this.tipoAtencion,
    this.referencia,
    this.contrarreferencia,
    this.establecimientoOrigen,
    this.establecimientoDestino,
    this.tiempoAccesoHistoria,
    this.tiempoAtencion,
    this.estadoIntercambio,
    this.recursoFhir,
    this.diagnosticos = const [],
    this.signosVitales,
  });

  factory ClinicalHistory.fromJson(Map<String, dynamic> j) => ClinicalHistory(
        id: j['id'] ?? '',
        patientId: j['patientId'] ?? j['patient']?['id'] ?? '',
        patientNombre: j['patientNombre'] ??
            ('${j['patient']?['nombres'] ?? ''} ${j['patient']?['apellidos'] ?? ''}'.trim()),
        medico: j['medico'] ?? '',
        medicoId: j['medicoId'] ?? '',
        fechaAtencion: j['fechaAtencion'] ?? j['fecha'] ?? '',
        especialidad: j['especialidad'] ?? '',
        estado: j['estado'] ?? '',
        motivoConsulta: j['motivoConsulta'],
        enfermedadActual: j['enfermedadActual'],
        observaciones: j['observaciones'],
        planTratamiento: j['planTratamiento'],
        tipoAtencion: j['tipoAtencion'],
        referencia: j['referencia'],
        contrarreferencia: j['contrarreferencia'],
        establecimientoOrigen: j['establecimientoOrigen'],
        establecimientoDestino: j['establecimientoDestino'],
        tiempoAccesoHistoria: j['tiempoAccesoHistoria'],
        tiempoAtencion: j['tiempoAtencion'],
        estadoIntercambio: j['estadoIntercambio'],
        recursoFhir: j['recursoFhir'],
        diagnosticos: (j['diagnosticos'] as List<dynamic>? ?? [])
            .map((d) => Diagnosis.fromJson(d))
            .toList(),
        signosVitales: j['signosVitales'] != null
            ? VitalSigns.fromJson(j['signosVitales'])
            : null,
      );
}

// ── PrescriptionItem ──────────────────────────────────────────────────────────
class PrescriptionItem {
  final String? id;
  final String medicamento;
  final String dosis;
  final String frecuencia;
  final String duracion;
  final int cantidad;
  final String? observaciones;

  const PrescriptionItem({
    this.id,
    required this.medicamento,
    required this.dosis,
    required this.frecuencia,
    required this.duracion,
    required this.cantidad,
    this.observaciones,
  });

  factory PrescriptionItem.fromJson(Map<String, dynamic> j) => PrescriptionItem(
        id: j['id'],
        medicamento: j['medicamento'] ?? '',
        dosis: j['dosis'] ?? '',
        frecuencia: j['frecuencia'] ?? '',
        duracion: j['duracion'] ?? '',
        cantidad: j['cantidad'] ?? 0,
        observaciones: j['observaciones'],
      );

  Map<String, dynamic> toJson() => {
        'medicamento': medicamento,
        'dosis': dosis,
        'frecuencia': frecuencia,
        'duracion': duracion,
        'cantidad': cantidad,
        if (observaciones != null) 'observaciones': observaciones,
      };
}

// ── Prescription ──────────────────────────────────────────────────────────────
class Prescription {
  final String id;
  final String patientId;
  final String patientNombre;
  final String medico;
  final String fecha;
  final String estado;
  final String numeroReceta;
  final List<PrescriptionItem> items;

  const Prescription({
    required this.id,
    required this.patientId,
    required this.patientNombre,
    required this.medico,
    required this.fecha,
    required this.estado,
    required this.numeroReceta,
    this.items = const [],
  });

  factory Prescription.fromJson(Map<String, dynamic> j) => Prescription(
        id: j['id'] ?? '',
        patientId: j['patientId'] ?? j['patient']?['id'] ?? '',
        patientNombre: j['patientNombre'] ??
            ('${j['patient']?['nombres'] ?? ''} ${j['patient']?['apellidos'] ?? ''}'.trim()),
        medico: j['medico'] ?? '',
        fecha: j['fecha'] ?? '',
        estado: j['estado'] ?? '',
        numeroReceta: j['numeroReceta'] ?? '',
        items: (j['items'] as List<dynamic>? ?? [])
            .map((i) => PrescriptionItem.fromJson(i))
            .toList(),
      );
}

// ── TelemedicineSession ───────────────────────────────────────────────────────
class TelemedicineSession {
  final String id;
  final String patientId;
  final String patientNombre;
  final String medico;
  final String especialidad;
  final String fechaProgramada;
  final String estado;
  final String? enlace;
  final String? motivoConsulta;
  final int duracionMinutos;

  const TelemedicineSession({
    required this.id,
    required this.patientId,
    required this.patientNombre,
    required this.medico,
    required this.especialidad,
    required this.fechaProgramada,
    required this.estado,
    this.enlace,
    this.motivoConsulta,
    this.duracionMinutos = 30,
  });

  factory TelemedicineSession.fromJson(Map<String, dynamic> j) =>
      TelemedicineSession(
        id: j['id'] ?? '',
        patientId: j['patientId'] ?? j['patient']?['id'] ?? '',
        patientNombre: j['patientNombre'] ??
            ('${j['patient']?['nombres'] ?? ''} ${j['patient']?['apellidos'] ?? ''}'.trim()),
        medico: j['medico'] ?? '',
        especialidad: j['especialidad'] ?? '',
        fechaProgramada: j['fechaProgramada'] ?? '',
        estado: j['estado'] ?? '',
        enlace: j['enlace'],
        motivoConsulta: j['motivoConsulta'],
        duracionMinutos: j['duracionMinutos'] ?? 30,
      );
}

// ── AuditRecord ───────────────────────────────────────────────────────────────
class AuditRecord {
  final String id;
  final String usuario;
  final String usuarioRol;
  final String accion;
  final String modulo;
  final String detalle;
  final String ip;
  final String fecha;

  const AuditRecord({
    required this.id,
    required this.usuario,
    required this.usuarioRol,
    required this.accion,
    required this.modulo,
    required this.detalle,
    required this.ip,
    required this.fecha,
  });

  factory AuditRecord.fromJson(Map<String, dynamic> j) => AuditRecord(
        id: j['id'] ?? '',
        usuario: j['usuario'] ?? '',
        usuarioRol: j['usuarioRol'] ?? '',
        accion: j['accion'] ?? '',
        modulo: j['modulo'] ?? '',
        detalle: j['detalle'] ?? '',
        ip: j['ip'] ?? '',
        fecha: j['fecha'] ?? '',
      );
}

// ── DashboardStats ────────────────────────────────────────────────────────────
class DashboardStats {
  final int totalUsers;
  final int activeUsers;
  final int doctors;
  final int nurses;
  final int admins;
  final int inactiveUsers;
  final int activeAreas;
  final int totalPatients;
  final int consultationsToday;
  final int newPatientsThisMonth;

  const DashboardStats({
    this.totalUsers = 0,
    this.activeUsers = 0,
    this.doctors = 0,
    this.nurses = 0,
    this.admins = 0,
    this.inactiveUsers = 0,
    this.activeAreas = 0,
    this.totalPatients = 0,
    this.consultationsToday = 0,
    this.newPatientsThisMonth = 0,
  });

  factory DashboardStats.fromJson(Map<String, dynamic> j) => DashboardStats(
        totalUsers: j['totalUsers'] ?? 0,
        activeUsers: j['activeUsers'] ?? 0,
        doctors: j['doctors'] ?? 0,
        nurses: j['nurses'] ?? 0,
        admins: j['admins'] ?? 0,
        inactiveUsers: j['inactiveUsers'] ?? 0,
        activeAreas: j['activeAreas'] ?? 0,
        totalPatients: j['totalPatients'] ?? 0,
        consultationsToday: j['consultationsToday'] ?? 0,
        newPatientsThisMonth: j['newPatientsThisMonth'] ?? 0,
      );
}
