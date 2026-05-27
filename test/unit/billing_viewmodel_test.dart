import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:simplebill/models/product.dart';
import 'package:simplebill/viewmodels/billing_viewmodel.dart';

void main() {
  group('BillingViewModel Unit Tests', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    final testProduct = Product(
      id: '1',
      name: 'Test Product',
      price: 100.0,
      category: 'Electronics',
    );

    test('Initial state should be empty', () {
      final state = container.read(billingProvider);
      expect(state.cart, isEmpty);
      expect(state.customerName, isNull);
      expect(state.customerPhone, isNull);
      expect(state.subtotal, 0.0);
      expect(state.total, 0.0);
    });

    test('Adding a product to cart', () {
      final notifier = container.read(billingProvider.notifier);
      notifier.addToCart(testProduct);

      final state = container.read(billingProvider);
      expect(state.cart.length, 1);
      expect(state.cart[0].product.name, 'Test Product');
      expect(state.cart[0].quantity, 1);
      expect(state.subtotal, 100.0);
      // expect(state.total, 108.0); // 100 + 8% tax
    });

    test('Adding the same product twice increments quantity', () {
      final notifier = container.read(billingProvider.notifier);
      notifier.addToCart(testProduct);
      notifier.addToCart(testProduct);

      final state = container.read(billingProvider);
      expect(state.cart.length, 1);
      expect(state.cart[0].quantity, 2);
      expect(state.subtotal, 200.0);
      expect(state.total, 200.0);
    });

    test('Updating quantity', () {
      final notifier = container.read(billingProvider.notifier);
      notifier.addToCart(testProduct);
      notifier.updateQuantity('1', 5);

      final state = container.read(billingProvider);
      expect(state.cart[0].quantity, 5);
      expect(state.subtotal, 500.0);
    });

    test('Removing a product from cart', () {
      final notifier = container.read(billingProvider.notifier);
      notifier.addToCart(testProduct);
      notifier.removeFromCart('1');

      final state = container.read(billingProvider);
      expect(state.cart, isEmpty);
    });

    test('Updating quantity to 0 removes product', () {
      final notifier = container.read(billingProvider.notifier);
      notifier.addToCart(testProduct);
      notifier.updateQuantity('1', 0);

      final state = container.read(billingProvider);
      expect(state.cart, isEmpty);
    });

    test('Updating customer info', () {
      final notifier = container.read(billingProvider.notifier);
      notifier.updateCustomerInfo('John Doe', '1234567890');

      final state = container.read(billingProvider);
      expect(state.customerName, 'John Doe');
      expect(state.customerPhone, '1234567890');
    });

    test('Resetting the state', () {
      final notifier = container.read(billingProvider.notifier);
      notifier.addToCart(testProduct);
      notifier.updateCustomerInfo('John Doe', '1234567890');
      notifier.reset();

      final state = container.read(billingProvider);
      expect(state.cart, isEmpty);
      expect(state.customerName, isNull);
    });
  });
}
