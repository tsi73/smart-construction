import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:construction_mobile_app/app.dart';

void main() {
  testWidgets('App starts with splash and branding text',
      (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      const ProviderScope(
        child: ConstructProApp(),
      ),
    );

    // Verify splash branding text exists
    expect(find.text('ConstructPro'), findsOneWidget);

    // Pump and settle to clear timers/animations (Splash animation and auth check)
    await tester.pumpAndSettle(const Duration(seconds: 3));
  });
}
