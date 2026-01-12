import 'package:flutter_test/flutter_test.dart';
import 'package:machine_test_app/app.dart';

void main() {
  testWidgets('App builds without crashing', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    // If MyApp builds, test passes
    expect(find.byType(MyApp), findsOneWidget);
  });
}
