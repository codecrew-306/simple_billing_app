import 'cart_item.dart';

class Transaction {
  final String id;
  final String? customerName;
  final String? customerPhone;
  final List<CartItem> items;
  final double subtotal;
  final double total;
  final DateTime timestamp;
  final String paymentMethod;

  Transaction({
    required this.id,
    this.customerName,
    this.customerPhone,
    required this.items,
    required this.subtotal,
    required this.total,
    required this.timestamp,
    required this.paymentMethod,
  });
}
