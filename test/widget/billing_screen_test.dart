import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:simplebill/views/screens/billing_screen.dart';
import 'package:simplebill/viewmodels/product_viewmodel.dart';
import 'package:simplebill/viewmodels/billing_viewmodel.dart';
import 'package:simplebill/models/product.dart';

void main() {
  Widget createTestWidget() {
    return ProviderScope(
      child: MaterialApp(
        home: const BillingScreen(),
      ),
    );
  }

  group('BillingScreen Widget Tests', () {
    testWidgets('Should render all major sections on web', (tester) async {
      tester.view.physicalSize = const Size(1200, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createTestWidget());

      expect(find.text('Product Search'), findsOneWidget);
      expect(find.text('Scan Barcode'), findsOneWidget);
      expect(find.text('Walk-in Customer'), findsOneWidget);
      expect(find.text('Current Order'), findsOneWidget);
      expect(find.text('Order Summary'), findsOneWidget);
    });

    testWidgets('Tapping search field opens search dialog', (tester) async {
      tester.view.physicalSize = const Size(1200, 800);
      await tester.pumpWidget(createTestWidget());

      await tester.tap(find.text('Search by name, SKU, or category...'));
      await tester.pumpAndSettle();

      expect(find.byType(Dialog), findsOneWidget);
    });

    testWidgets('Searching and adding a product works', (tester) async {
      tester.view.physicalSize = const Size(1200, 800);
      await tester.pumpWidget(createTestWidget());

      await tester.tap(find.text('Search by name, SKU, or category...'));
      await tester.pumpAndSettle();

      await tester.enterText(find.descendant(of: find.byType(Dialog), matching: find.byType(TextField)), 'Milk');
      await tester.pumpAndSettle();

      await tester.tap(find.text('Milk 2L'));
      await tester.pumpAndSettle();

      expect(find.text('1 Items'), findsOneWidget);
      expect(find.text('Milk 2L'), findsOneWidget);
    });

    testWidgets('Customer details accordion expands and collapses', (tester) async {
      tester.view.physicalSize = const Size(1200, 800);
      await tester.pumpWidget(createTestWidget());

      expect(find.text('Customer Name'), findsNothing);

      // Tap to expand
      await tester.tap(find.byType(ExpansionTile));
      await tester.pumpAndSettle();

      expect(find.text('Customer Name'), findsOneWidget);
      expect(find.text('Phone Number'), findsOneWidget);

      // Tap to collapse
      await tester.tap(find.text('Walk-in Customer'));
      await tester.pumpAndSettle();

      expect(find.text('Customer Name'), findsNothing);
    });

    testWidgets('Mark as Paid button enablement logic', (tester) async {
      tester.view.physicalSize = const Size(1200, 800);
      await tester.pumpWidget(createTestWidget());

      // Add product
      await tester.tap(find.text('Search by name, SKU, or category...'));
      await tester.pumpAndSettle();
      
      // Type 'Milk' to be sure
      await tester.enterText(find.descendant(of: find.byType(Dialog), matching: find.byType(TextField)), 'Milk');
      await tester.pumpAndSettle();
      
      await tester.tap(find.text('Milk 2L'));
      await tester.pumpAndSettle();

      final markAsPaidButtonFinder = find.widgetWithText(ElevatedButton, 'Mark as Paid');
      final amountFieldFinder = find.byWidgetPredicate((w) => w is TextField && w.decoration?.hintText == '0.00');
      
      await tester.ensureVisible(amountFieldFinder);
      await tester.pumpAndSettle();

      // Disabled initially
      expect(tester.widget<ElevatedButton>(markAsPaidButtonFinder).onPressed, isNull);

      // Enter 130
      await tester.enterText(amountFieldFinder, '130');
      await tester.pumpAndSettle();
      
      // Check if button is enabled
      final button = tester.widget<ElevatedButton>(markAsPaidButtonFinder);
      expect(button.onPressed, isNotNull);
    });
  });
}
