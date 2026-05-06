import 'cart_item.dart';

class TabEntry {
  final String id;
  final String? customerName;
  final String? customerPhone;
  final List<CartItem> items;
  final double total;
  final double paidAmount;
  final DateTime timestamp;

  TabEntry({
    required this.id,
    this.customerName,
    this.customerPhone,
    required this.items,
    required this.total,
    required this.paidAmount,
    required this.timestamp,
  });

  double get outstandingAmount => total - paidAmount;
  bool get isSettled => outstandingAmount <= 0;

  TabEntry copyWith({
    String? customerName,
    String? customerPhone,
    List<CartItem>? items,
    double? total,
    double? paidAmount,
    DateTime? timestamp,
  }) {
    return TabEntry(
      id: this.id,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      items: items ?? this.items,
      total: total ?? this.total,
      paidAmount: paidAmount ?? this.paidAmount,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}
