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

    // Settle all splash transition timers
    await tester.pumpAndSettle();
  });
}
