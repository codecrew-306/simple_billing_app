import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/product.dart';
import '../models/cart_item.dart';

class BillingState {
  final List<CartItem> cart;
  final String? customerName;
  final String? customerPhone;

  BillingState({this.cart = const [], this.customerName, this.customerPhone});

  double get subtotal => cart.fold(0.0, (sum, item) => sum + item.total);
  double get total => subtotal; // For now. Can add taxes later.

  BillingState copyWith({
    List<CartItem>? cart,
    String? customerName,
    String? customerPhone,
  }) {
    return BillingState(
      cart: cart ?? this.cart,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
    );
  }
}

class BillingNotifier extends Notifier<BillingState> {
  @override
  BillingState build() => BillingState();

  void addToCart(Product product) {
    final index = state.cart.indexWhere(
      (item) => item.product.id == product.id,
    );
    if (index >= 0) {
      updateQuantity(product.id, state.cart[index].quantity + 1);
    } else {
      state = state.copyWith(
        cart: [
          ...state.cart,
          CartItem(product: product, quantity: 1),
        ],
      );
    }
  }

  void removeFromCart(String productId) {
    state = state.copyWith(
      cart: state.cart.where((item) => item.product.id != productId).toList(),
    );
  }

  void updateQuantity(String productId, int quantity) {
    if (quantity <= 0) {
      removeFromCart(productId);
      return;
    }
    state = state.copyWith(
      cart: state.cart.map((item) {
        if (item.product.id == productId) {
          return item.copyWith(quantity: quantity);
        }
        return item;
      }).toList(),
    );
  }

  void updateCustomerInfo(String? name, String? phone) {
    state = state.copyWith(customerName: name, customerPhone: phone);
  }

  void reset() {
    state = BillingState();
  }
}

final billingProvider = NotifierProvider<BillingNotifier, BillingState>(
  BillingNotifier.new,
);
