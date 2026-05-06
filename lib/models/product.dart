class Product {
  final String id;
  final String name;
  final double price;
  final String? barcode;
  final String category;

  Product({
    required this.id,
    required this.name,
    required this.price,
    this.barcode,
    required this.category,
  });

  Product copyWith({
    String? id,
    String? name,
    double? price,
    String? barcode,
    String? category,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      barcode: barcode ?? this.barcode,
      category: category ?? this.category,
    );
  }
}
