import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:notify_vault/app/app.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      const ProviderScope(
        child: NotifyVaultApp(),
      ),
    );

    // Verify app launches
    expect(find.byType(NotifyVaultApp), findsOneWidget);

    // Pump to advance past splash transition (avoid pumpAndSettle due to infinite CircularProgressIndicator)
    await tester.pump(const Duration(milliseconds: 2500));
  });
}
