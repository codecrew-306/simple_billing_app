import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/tab.dart';
import '../models/cart_item.dart';
import '../models/product.dart';
import 'package:uuid/uuid.dart';

class TabNotifier extends Notifier<List<TabEntry>> {
  @override
  List<TabEntry> build() => _dummyTabs;

  static final List<TabEntry> _dummyTabs = [
    TabEntry(
      id: 'tab1',
      customerName: 'Rajesh Sharma',
      customerPhone: '98765 43210',
      items: [
        CartItem(
          product: Product(
            id: '1',
            name: 'Milk 2L',
            price: 120.0,
            category: 'Grocery',
          ),
          quantity: 2,
        ),
        CartItem(
          product: Product(
            id: '2',
            name: 'Bread',
            price: 40.0,
            category: 'Grocery',
          ),
          quantity: 1,
        ),
      ],
      total: 850.0,
      paidAmount: 500.0,
      timestamp: DateTime.now().subtract(const Duration(days: 29)),
    ),
    TabEntry(
      id: 'tab2',
      customerName: 'Amit Patel',
      customerPhone: '98765 12345',
      items: [
        CartItem(
          product: Product(
            id: '3',
            name: 'Rice 5kg',
            price: 650.0,
            category: 'Grocery',
          ),
          quantity: 1,
        ),
      ],
      total: 1250.0,
      paidAmount: 0.0,
      timestamp: DateTime.now().subtract(const Duration(days: 30)),
    ),
  ];

  void addTab({
    required List<CartItem> items,
    required double total,
    required double paidAmount,
    String? customerName,
    String? customerPhone,
  }) {
    final newTab = TabEntry(
      id: const Uuid().v4(),
      customerName: customerName,
      customerPhone: customerPhone,
      items: items,
      total: total,
      paidAmount: paidAmount,
      timestamp: DateTime.now(),
    );
    state = [newTab, ...state];
  }

  void updatePaidAmount(String tabId, double additionalAmount) {
    state = state.map((tab) {
      if (tab.id == tabId) {
        return tab.copyWith(paidAmount: tab.paidAmount + additionalAmount);
      }
      return tab;
    }).toList();
  }

  void removeTab(String tabId) {
    state = state.where((tab) => tab.id != tabId).toList();
  }
}

final tabProvider = NotifierProvider<TabNotifier, List<TabEntry>>(
  TabNotifier.new,
);
