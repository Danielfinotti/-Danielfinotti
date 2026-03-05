import 'package:flutter_test/flutter_test.dart';
import 'package:control_persianas/main.dart';

void main() {
  testWidgets('App carrega corretamente', (WidgetTester tester) async {
    await tester.pumpWidget(const ControlPersianaApp());
    expect(find.byType(ControlPersianaApp), findsOneWidget);
  });
}
