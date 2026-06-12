import 'package:flutter/material.dart';
import '../core/models.dart';

class ClinicalHistoryDetailView extends StatefulWidget {
  final Patient patient;
  final ClinicalHistory history;
  final VoidCallback onBack;

  const ClinicalHistoryDetailView({
    super.key,
    required this.patient,
    required this.history,
    required this.onBack,
  });

  @override
  State<ClinicalHistoryDetailView> createState() => _ClinicalHistoryDetailViewState();
}

class _ClinicalHistoryDetailViewState extends State<ClinicalHistoryDetailView> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final Color _bgColor = const Color(0xFFF3F4F6); // Light gray background
  final Color _panelColor = Colors.white;
  final Color _borderColor = const Color(0xFFE5E7EB);
  final Color _textColor = const Color(0xFF1F2937);
  final Color _mutedTextColor = const Color(0xFF6B7280);
  final Color _primaryColor = const Color(0xFF1E3A8A); // Deep blue for primary actions

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  int _calculateAge(String? birthDate) {
    if (birthDate == null || birthDate.isEmpty) return 0;
    try {
      final bDate = DateTime.parse(birthDate);
      final today = DateTime.now();
      int age = today.year - bDate.year;
      if (today.month < bDate.month || (today.month == bDate.month && today.day < bDate.day)) {
        age--;
      }
      return age;
    } catch (_) {
      return 0;
    }
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return '';
    try {
      final d = DateTime.parse(dateStr);
      return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
    } catch (_) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    final age = _calculateAge(widget.patient.fechaNacimiento);

    return Theme(
      data: ThemeData.light().copyWith(
        scaffoldBackgroundColor: _bgColor,
        primaryColor: _primaryColor,
        dividerColor: _borderColor,
        colorScheme: ColorScheme.light(
          primary: _primaryColor,
          surface: _panelColor,
        ),
      ),
      child: Scaffold(
        appBar: _buildAppBar(),
        body: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left Panel (Patient Details)
              SizedBox(
                width: 300,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildProfileCard(age),
                      const SizedBox(height: 16),
                      _buildAlertsCard(),
                      const SizedBox(height: 16),
                      _buildContactCard(),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 24),
              
              // Right Panel (Tabs & Content)
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: _panelColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _borderColor),
                  ),
                  child: Column(
                    children: [
                      // Custom TabBar Container
                      _buildTabBar(),
                      // Tab Content
                      Expanded(
                        child: TabBarView(
                          controller: _tabController,
                          children: [
                            _buildDatosTab(age),
                            const Center(child: Text('Antecedentes (En desarrollo)')),
                            const Center(child: Text('Diagnósticos (En desarrollo)')),
                            const Center(child: Text('Tratamientos (En desarrollo)')),
                            const Center(child: Text('Evolución (En desarrollo)')),
                            const Center(child: Text('Recetas (En desarrollo)')),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: _panelColor,
      elevation: 0,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1.0),
        child: Container(color: _borderColor, height: 1.0),
      ),
      leadingWidth: 0,
      leading: const SizedBox.shrink(),
      title: Row(
        children: [
          IconButton(
            icon: Icon(Icons.people_alt_outlined, color: _mutedTextColor),
            onPressed: widget.onBack,
          ),
          Text('Pacientes', style: TextStyle(color: _mutedTextColor, fontSize: 16)),
          Icon(Icons.chevron_right, color: _mutedTextColor, size: 20),
          Text(widget.patient.nombreCompleto, style: TextStyle(color: _mutedTextColor, fontSize: 16)),
          Icon(Icons.chevron_right, color: _mutedTextColor, size: 20),
          Text('Historia Clínica', style: TextStyle(color: _textColor, fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0),
          child: OutlinedButton.icon(
            onPressed: () {},
            icon: Icon(Icons.print_outlined, color: _mutedTextColor, size: 18),
            label: Text('Imprimir', style: TextStyle(color: _mutedTextColor)),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: _borderColor),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0),
          child: OutlinedButton.icon(
            onPressed: () {},
            icon: Icon(Icons.add, color: _mutedTextColor, size: 18),
            label: Text('Nueva consulta', style: TextStyle(color: _mutedTextColor)),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: _borderColor),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0),
          child: IconButton(
            onPressed: () {},
            icon: const Icon(Icons.more_horiz),
            color: Colors.white,
            style: IconButton.styleFrom(
              backgroundColor: const Color(0xFF1F2937),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ),
        const SizedBox(width: 24),
      ],
    );
  }

  Widget _buildProfileCard(int age) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: _panelColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _borderColor),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: const Color(0xFFDBEAFE), // Light blue
            child: Text(
              widget.patient.initials,
              style: const TextStyle(color: Color(0xFF1E3A8A), fontWeight: FontWeight.bold, fontSize: 28),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            widget.patient.nombreCompleto,
            textAlign: TextAlign.center,
            style: TextStyle(color: _textColor, fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 4),
          Text(
            'DNI: ${widget.patient.dni}',
            style: TextStyle(color: _mutedTextColor, fontSize: 14),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildBadge(widget.patient.sexo.isNotEmpty ? widget.patient.sexo : 'N/A', const Color(0xFFFCE7F3), const Color(0xFFBE185D)),
              const SizedBox(width: 8),
              _buildBadge('$age años', const Color(0xFFE2E8F0), const Color(0xFF475569)), // Light Gray
              const SizedBox(width: 8),
              _buildBadge(widget.patient.asegurado, const Color(0xFFD1FAE5), const Color(0xFF047857)),
            ],
          ),
          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 16),
          Text('N° HC', style: TextStyle(color: _mutedTextColor, fontSize: 13)),
          const SizedBox(height: 4),
          Text(
            widget.patient.numeroHc,
            style: TextStyle(color: _textColor, fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(String text, Color bgColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        text,
        style: TextStyle(color: textColor, fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _buildAlertsCard() {
    List<String> alertas = [];
    if (widget.patient.alertas != null && widget.patient.alertas!.isNotEmpty) {
      alertas = widget.patient.alertas!.split(',').map((e) => e.trim()).toList();
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _panelColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.monitor_heart_outlined, color: const Color(0xFFDC2626), size: 20), // Red icon
              const SizedBox(width: 8),
              Text('Alertas', style: TextStyle(color: _textColor, fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
          const SizedBox(height: 16),
          if (alertas.isEmpty)
            Text('No hay alertas registradas', style: TextStyle(color: _mutedTextColor, fontSize: 14))
          else
            ...alertas.map((alerta) {
              final isAllergy = alerta.toLowerCase().contains('alergia');
              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Text(
                  alerta,
                  style: TextStyle(
                    color: isAllergy ? const Color(0xFFDC2626) : _textColor,
                    fontSize: 14,
                  ),
                ),
              );
            }).toList(),
        ],
      ),
    );
  }

  Widget _buildContactCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _panelColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.phone_outlined, color: _primaryColor, size: 20),
              const SizedBox(width: 8),
              Text('Contacto', style: TextStyle(color: _textColor, fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
          const SizedBox(height: 16),
          _buildContactRow('Celular', widget.patient.telefono ?? 'No registrado'),
          const SizedBox(height: 12),
          _buildContactRow('Distrito', widget.patient.distrito ?? 'No registrado'),
          const SizedBox(height: 12),
          _buildContactRow('Asegurado', widget.patient.asegurado),
        ],
      ),
    );
  }

  Widget _buildContactRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: _mutedTextColor, fontSize: 14)),
        Text(value, style: TextStyle(color: _textColor, fontSize: 14, fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _buildTabBar() {
    return Container(
      padding: const EdgeInsets.only(top: 8, left: 8, right: 8),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: _borderColor)),
      ),
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        labelColor: _primaryColor,
        unselectedLabelColor: _mutedTextColor,
        indicatorColor: _primaryColor,
        indicatorWeight: 3,
        tabs: [
          _buildTabWithIcon(Icons.person_outline, 'Datos'),
          _buildTabWithIcon(Icons.history_outlined, 'Antecedentes'),
          _buildTabWithIcon(Icons.medical_information_outlined, 'Diagnósticos'),
          _buildTabWithIcon(Icons.vaccines_outlined, 'Tratamientos'),
          _buildTabWithIcon(Icons.show_chart, 'Evolución'),
          _buildTabWithIcon(Icons.description_outlined, 'Recetas'),
        ],
      ),
    );
  }

  Tab _buildTabWithIcon(IconData icon, String text) {
    return Tab(
      height: 48,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: 8),
          Text(text),
        ],
      ),
    );
  }

  Widget _buildDatosTab(int age) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Datos generales section
          Row(
            children: [
              Icon(Icons.account_circle_outlined, color: _primaryColor, size: 20),
              const SizedBox(width: 8),
              Text('Datos generales', style: TextStyle(color: _textColor, fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 16),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 3,
            childAspectRatio: 3.5,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            children: [
              _buildFormReadOnly('NOMBRE COMPLETO', widget.patient.nombreCompleto),
              _buildFormReadOnly('FECHA DE NACIMIENTO', _formatDate(widget.patient.fechaNacimiento)),
              _buildFormReadOnly('EDAD', '$age años'),
              _buildFormReadOnly('SEXO', widget.patient.sexo),
              _buildFormReadOnly('ESTADO CIVIL', widget.patient.estadoCivil ?? 'No registrado'),
              _buildFormReadOnly('OCUPACIÓN', widget.patient.ocupacion ?? 'No registrado'),
              _buildFormReadOnly('DIRECCIÓN', widget.patient.direccion ?? 'No registrado'),
              _buildFormReadOnly('SEGURO', '${widget.patient.asegurado} — Activo'), // Mocked Active state
              _buildFormReadOnly('GRUPO SANGUÍNEO', widget.patient.grupoSanguineo ?? 'No registrado'),
            ],
          ),
          const SizedBox(height: 32),

          // Diagnósticos activos section
          Row(
            children: [
              Icon(Icons.settings_outlined, color: _primaryColor, size: 20),
              const SizedBox(width: 8),
              Text('Diagnósticos activos', style: TextStyle(color: _textColor, fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
          const SizedBox(height: 16),
          _buildDiagnosticoItem('I10', 'Hipertensión esencial (primaria)', 'Desde 2022', true),
          const SizedBox(height: 12),
          _buildDiagnosticoItem('E11.9', 'Diabetes mellitus tipo 2 sin complicaciones', 'Desde 2023', false),
          const SizedBox(height: 32),

          // Última receta section
          Row(
            children: [
              Icon(Icons.description_outlined, color: _primaryColor, size: 20),
              const SizedBox(width: 8),
              Text('Última receta', style: TextStyle(color: _textColor, fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildRecetaItem('Metformina 850mg', '850mg', '1 tableta c/12h con alimentos', '30 días')),
              const SizedBox(width: 16),
              Expanded(child: _buildRecetaItem('Enalapril 10mg', '10mg', '1 tableta c/24h en ayunas', '30 días')),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              OutlinedButton.icon(
                onPressed: null, // Disabled per mockup
                icon: const Icon(Icons.edit_outlined),
                label: const Text('Editar HC'),
                style: OutlinedButton.styleFrom(
                  disabledForegroundColor: _borderColor,
                  side: BorderSide(color: _borderColor),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
              const SizedBox(width: 16),
              OutlinedButton.icon(
                onPressed: null, // Disabled
                icon: const Icon(Icons.picture_as_pdf_outlined),
                label: const Text('Descargar PDF'),
                style: OutlinedButton.styleFrom(
                  disabledForegroundColor: _borderColor,
                  side: BorderSide(color: _borderColor),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
              const SizedBox(width: 16),
              OutlinedButton.icon(
                onPressed: null, // Disabled
                icon: const Icon(Icons.add),
                label: const Text('Nueva consulta'),
                style: OutlinedButton.styleFrom(
                  disabledForegroundColor: _borderColor,
                  side: BorderSide(color: _borderColor),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildFormReadOnly(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: _mutedTextColor, fontSize: 11, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFFF9FAFB), // Very light gray
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: _borderColor),
          ),
          child: Text(
            value,
            style: TextStyle(color: _textColor, fontSize: 14),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildDiagnosticoItem(String code, String desc, String since, bool isPrincipal) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _borderColor),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFDBEAFE),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(code, style: TextStyle(color: _primaryColor, fontWeight: FontWeight.bold, fontSize: 12)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(desc, style: TextStyle(color: _textColor, fontSize: 14, fontWeight: FontWeight.w500)),
          ),
          Text(since, style: TextStyle(color: _mutedTextColor, fontSize: 12)),
          const SizedBox(width: 16),
          _buildBadge(
            isPrincipal ? 'Principal' : 'Secundario',
            isPrincipal ? const Color(0xFFFEF3C7) : const Color(0xFFD1FAE5), // Yellow or Green
            isPrincipal ? const Color(0xFFD97706) : const Color(0xFF047857),
          ),
        ],
      ),
    );
  }

  Widget _buildRecetaItem(String name, String dosage, String instructions, String duration) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(name, style: TextStyle(color: _textColor, fontWeight: FontWeight.bold, fontSize: 15)),
              Text(dosage, style: const TextStyle(color: Color(0xFF3B82F6), fontSize: 13)), // Blue text
            ],
          ),
          const SizedBox(height: 8),
          Text('$instructions · $duration', style: TextStyle(color: _mutedTextColor, fontSize: 13)),
        ],
      ),
    );
  }
}
