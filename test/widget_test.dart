import 'package:flutter_test/flutter_test.dart';
import 'package:sistema_de_historias_clinicas/main.dart';

void main() {
  testWidgets('muestra login y navega al dashboard', (tester) async {
    await tester.pumpWidget(const HceApp());

    expect(find.text('Iniciar sesión'), findsOneWidget);
    expect(find.text('Sistema HCE\nRural Salud Perú'), findsOneWidget);

    await tester.ensureVisible(find.text('Ingresar al sistema'));
    await tester.tap(find.text('Ingresar al sistema'));
    await tester.pumpAndSettle();

    expect(find.text('Dashboard'), findsWidgets);
    expect(find.text('Total Pacientes'), findsOneWidget);
  });
}
