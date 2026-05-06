import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/product.dart';
import 'package:uuid/uuid.dart';

class ProductNotifier extends Notifier<List<Product>> {
  @override
  List<Product> build() => _dummyProducts;

  static final List<Product> _dummyProducts = [
    Product(id: '1', name: 'Milk 2L', price: 120.0, barcode: '8901234567890', category: 'Grocery'),
    Product(id: '2', name: 'Rice 5kg', price: 630.0, barcode: '8901234567891', category: 'Grocery'),
    Product(id: '3', name: 'Eggs (6 pcs)', price: 60.0, barcode: '8901234567892', category: 'Grocery'),
  ];

  Product addProduct(String name, double price, String? barcode, String category) {
    final newProduct = Product(
      id: const Uuid().v4(),
      name: name,
      price: price,
      barcode: barcode,
      category: category,
    );
    state = [...state, newProduct];
    return newProduct;
  }

  Product? getProductByBarcode(String barcode) {
    try {
      return state.firstWhere((p) => p.barcode == barcode);
    } catch (_) {
      return null;
    }
  }
}

final productProvider = NotifierProvider<ProductNotifier, List<Product>>(ProductNotifier.new);
