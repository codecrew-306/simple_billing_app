import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/transaction.dart';
import '../models/cart_item.dart';
import '../models/product.dart';
import 'package:uuid/uuid.dart';

class TransactionNotifier extends Notifier<List<Transaction>> {
  @override
  List<Transaction> build() => _dummyTransactions;

  static final List<Transaction> _dummyTransactions = [
    Transaction(
      id: 'T1',
      customerName: 'Rajesh',
      customerPhone: '9876543210',
      items: [
        CartItem(product: Product(id: '1', name: 'Milk 2L', price: 120.0, category: 'Grocery'), quantity: 2),
      ],
      subtotal: 240.0,
      total: 240.0,
      timestamp: DateTime.now().subtract(const Duration(minutes: 60)),
      paymentMethod: 'Cash',
    ),
  ];

  void addTransaction({
    required List<CartItem> items,
    required double subtotal,
    required double total,
    String? customerName,
    String? customerPhone,
    required String paymentMethod,
  }) {
    final newTransaction = Transaction(
      id: const Uuid().v4(),
      customerName: customerName,
      customerPhone: customerPhone,
      items: items,
      subtotal: subtotal,
      total: total,
      timestamp: DateTime.now(),
      paymentMethod: paymentMethod,
    );
    state = [newTransaction, ...state];
  }
}

final transactionProvider = NotifierProvider<TransactionNotifier, List<Transaction>>(TransactionNotifier.new);
