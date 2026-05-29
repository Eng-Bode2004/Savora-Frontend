import 'package:flutter_test/flutter_test.dart';
import 'package:savora_app/main.dart';

void main() {
  testWidgets('App launches smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const SavoraApp());
    expect(find.text('Savora'), findsOneWidget);
  });
}
