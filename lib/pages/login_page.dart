import 'package:flutter/material.dart';
import '../core/user_session.dart';
import '../core/services.dart';
import '../core/api_client.dart';
import '../widgets/common_widgets.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final user = TextEditingController();
  final pass = TextEditingController();
  bool remember = false;

  void _setRemember(bool? value) => setState(() => remember = value ?? false);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, c) {
            final wide = c.maxWidth >= 850;
            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1180),
                child: Container(
                  margin: EdgeInsets.all(wide ? 44 : 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(color: AppColors.line),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: wide
                      ? Row(
                          children: [
                            Expanded(child: _LoginBrand()),
                            Expanded(
                              child: _LoginForm(
                                user,
                                pass,
                                remember,
                                _setRemember,
                              ),
                            ),
                          ],
                        )
                      : SingleChildScrollView(
                          child: Column(
                            children: [
                              _LoginBrand(),
                              _LoginForm(user, pass, remember, _setRemember),
                            ],
                          ),
                        ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}



class _LoginBrand extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 520),
      color: AppColors.primary,
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircleAvatar(
            radius: 58,
            backgroundColor: Color(0xFF375D83),
            child: CircleAvatar(
              radius: 42,
              backgroundColor: AppColors.blue,
              child: Icon(
                Icons.health_and_safety_outlined,
                color: Colors.white,
                size: 42,
              ),
            ),
          ),
          const SizedBox(height: 46),
          const Text(
            'Sistema HCE\nRural Salud Perú',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w800,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 22),
          const Text(
            'Historias Clínicas Electrónicas para\nestablecimientos de salud rurales',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFFB7C6D7),
              fontSize: 20,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 36),
          Wrap(
            spacing: 20,
            runSpacing: 12,
            alignment: WrapAlignment.center,
            children: const [
              _MiniStat('12', 'Puestos'),
              _MiniStat('4,280', 'Pacientes'),
              _MiniStat('98%', 'Disponib.'),
            ],
          ),
          const SizedBox(height: 36),
          const Divider(color: Color(0xFF3B6288)),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFF486D91)),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.verified_user_outlined, color: Color(0xFF49C783)),
                SizedBox(width: 12),
                Flexible(
                  child: Text(
                    'Certificado MINSA · Norma Técnica NTS-139',
                    style: TextStyle(color: Color(0xFFB7C6D7), fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat(this.value, this.label);
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 112,
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF31577D),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 25,
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(
            label,
            style: const TextStyle(color: Color(0xFFB7C6D7), fontSize: 15),
          ),
        ],
      ),
    );
  }
}

class _LoginForm extends StatelessWidget {
  const _LoginForm(
    this.user,
    this.pass,
    this.remember,
    this.onRemember,
  );
  final TextEditingController user;
  final TextEditingController pass;
  final bool remember;
  final ValueChanged<bool?> onRemember;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final narrow = constraints.maxWidth < 480;
        final hPad  = narrow ? 24.0 : 48.0;
        final vPad  = narrow ? 24.0 : 44.0;

        return SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: hPad, vertical: vPad),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ACCESO AL SISTEMA',
                  style: TextStyle(
                    color: AppColors.blue,
                    letterSpacing: 1.5,
                    fontSize: narrow ? 13 : 16,
                  ),
                ),
                SizedBox(height: narrow ? 6 : 10),
                Text(
                  'Iniciar sesión',
                  style: TextStyle(
                    fontSize: narrow ? 26 : 32,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: narrow ? 6 : 10),
                Text(
                  'Ingresa tus credenciales institucionales para continuar',
                  style: TextStyle(
                    color: AppColors.muted,
                    fontSize: narrow ? 14 : 17,
                    height: 1.25,
                  ),
                ),
                SizedBox(height: narrow ? 20 : 30),
                _Field(label: 'Usuario / DNI', controller: user),
                SizedBox(height: narrow ? 14 : 20),
                _Field(label: 'Contraseña', controller: pass, obscure: true),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {},
                    child: const Text('¿Olvidaste tu contraseña?'),
                  ),
                ),
                CheckboxListTile(
                  value: remember,
                  onChanged: onRemember,
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Recordar sesión en este equipo'),
                  controlAffinity: ListTileControlAffinity.leading,
                ),
                SizedBox(height: narrow ? 12 : 18),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: FilledButton.icon(
                    onPressed: () async {
                      final username = user.text.trim();
                      final password = pass.text;
                      if (username.isEmpty || password.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Por favor, ingresa tu usuario y contraseña')),
                        );
                        return;
                      }

                      // Mostrar indicador de carga
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (_) => const Center(child: CircularProgressIndicator()),
                      );

                      try {
                        // Intentar login con el backend real
                        final match = await UserService.login(username, password);
                        if (!context.mounted) return;
                        Navigator.of(context).pop();

                        // Mapear rol a enum del frontend
                        final appRol = _rolFromString(match.rol);
                        UserSession.instance.login(
                          rol: appRol,
                          nombre: match.nombreCompleto,
                          dni: match.dni,
                          cargo: match.cargo ?? match.rol,
                          area: match.area,
                        );
                        Navigator.of(context).pushReplacementNamed('/home');

                      } catch (e) {
                        if (!context.mounted) return;
                        if (Navigator.canPop(context)) Navigator.of(context).pop();

                        // Si el servidor no está disponible (error 0 = sin conexión),
                        // intentar con usuarios demo locales
                        final isServerDown = e is ApiException && e.statusCode == 0;
                        if (isServerDown) {
                          final demoRol = _demoLogin(username, password);
                          if (demoRol != null && context.mounted) {
                            UserSession.instance.login(
                              rol: demoRol,
                              nombre: _demoNombre(username),
                              dni: '00000000',
                              cargo: _demoCargo(demoRol),
                              area: 'Medicina General',
                            );
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                backgroundColor: Color(0xFFF59E0B),
                                content: Text('⚠️ Modo DEMO — Backend no disponible. Los datos no se guardarán.'),
                                duration: Duration(seconds: 4),
                              ),
                            );
                            Navigator.of(context).pushReplacementNamed('/home');
                            return;
                          }
                          // Servidor caído y credenciales incorrectas
                          if (context.mounted) {
                            _showError(context, '🔌 El servidor no está disponible.\n\nAsegúrate de que el backend esté corriendo:\n  cd hce-backend\n  mvn spring-boot:run\n\nO usa las credenciales de demo (ej: rquispe / admin123)');
                          }
                        } else {
                          // Servidor respondió pero credenciales incorrectas
                          _showError(context, 'Usuario o contraseña incorrectos. Intenta de nuevo.');
                        }
                      }
                    },
                    icon: const Icon(Icons.login),
                    label: const Text('Ingresar al sistema'),
                  ),
                ),
                SizedBox(height: narrow ? 20 : 32),
                const Center(
                  child: Text(
                    'Acceso restringido · Uso exclusivo de personal autorizado\nRed de Salud Puno — DIRESA Puno 2026',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFF91A6BE),
                      height: 1.4,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({
    required this.label,
    required this.controller,
    this.obscure = false,
  });
  final String label;
  final TextEditingController controller;
  final bool obscure;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 17,
            color: AppColors.text,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: obscure,
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFFF5F8FC),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
      ],
    );
  }
}
// ─── Helper functions (module-level) ─────────────────────────────────────────

/// Convierte el string de rol del backend al enum local.
UserRol _rolFromString(String rol) {
  switch (rol.toUpperCase()) {
    case 'MEDICO':         return UserRol.medico;
    case 'ENFERMERO':      return UserRol.enfermero;
    case 'ADMINISTRATIVO': return UserRol.administrativo;
    case 'PACIENTE':       return UserRol.paciente;
    case 'AUDITOR':        return UserRol.auditor;
    case 'ADMINISTRADOR':  return UserRol.administrador;
    default:               return UserRol.administrador;
  }
}

/// Tabla de usuarios demo para cuando el backend no está disponible.
const _demoUsers = {
  'rquispe':         ('admin123', UserRol.administrador),
  'cmendoza':        ('admin123', UserRol.medico),
  'msanchez':        ('admin123', UserRol.medico),
  'rgutierrez':      ('admin123', UserRol.medico),
  'jvargas':         ('admin123', UserRol.medico),
  'atorres':         ('admin123', UserRol.enfermero),
  'pramirez':        ('admin123', UserRol.enfermero),
  'cdiaz':           ('admin123', UserRol.enfermero),
  'lcabrera':        ('admin123', UserRol.administrativo),
  'sflores':         ('admin123', UserRol.administrativo),
  'pramos':          ('admin123', UserRol.auditor),
  'rosa.villanueva': ('admin123', UserRol.paciente),
};

UserRol? _demoLogin(String username, String password) {
  final entry = _demoUsers[username.toLowerCase()];
  if (entry == null) return null;
  return entry.$1 == password ? entry.$2 : null;
}

String _demoNombre(String username) {
  const nombres = {
    'rquispe':         'Roberto Quispe Huamán',
    'cmendoza':        'Carlos Alberto Mendoza',
    'msanchez':        'María Elena Sánchez',
    'rgutierrez':      'Rosa María Gutiérrez',
    'jvargas':         'Juan Carlos Vargas',
    'atorres':         'Ana Lucía Torres',
    'pramirez':        'Pedro Ramírez',
    'cdiaz':           'Carmen Díaz',
    'lcabrera':        'Luis Cabrera',
    'sflores':         'Sandra Flores',
    'pramos':          'Patricia Ramos',
    'rosa.villanueva': 'Rosa Villanueva Quispe',
  };
  return nombres[username.toLowerCase()] ?? username;
}

String _demoCargo(UserRol rol) {
  switch (rol) {
    case UserRol.administrador:  return 'Director Regional';
    case UserRol.medico:         return 'Médico';
    case UserRol.enfermero:      return 'Enfermero/a';
    case UserRol.administrativo: return 'Administrativo';
    case UserRol.auditor:        return 'Auditor';
    case UserRol.paciente:       return 'Paciente';
  }
}

void _showError(BuildContext context, String message) {
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      icon: const Icon(Icons.warning_amber_rounded, color: Color(0xFFF59E0B), size: 40),
      title: const Text('No se pudo iniciar sesión'),
      content: Text(message, style: const TextStyle(height: 1.5)),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(),
          child: const Text('Entendido'),
        ),
      ],
    ),
  );
}
