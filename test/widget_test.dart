import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:simplebill/app.dart';

void main() {
  testWidgets('Initial route is login screen', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      const ProviderScope(
        child: SimpleBillApp(),
      ),
    );

    // Verify that we are on the login screen
    expect(find.text('SimpleBill'), findsOneWidget);
    expect(find.text('Login'), findsOneWidget);
  });
}
