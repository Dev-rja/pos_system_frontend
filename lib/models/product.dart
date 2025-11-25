class Product {
  final int productId;
  final String productName;
  final int? categoryId;
  final double price;
  final int stockQuantity;
  final String unit;

  Product({
    required this.productId,
    required this.productName,
    required this.categoryId,
    required this.price,
    required this.stockQuantity,
    required this.unit,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      productId: json['product_id'] as int,
      productName: json['product_name'] as String,
      categoryId: json['category_id'] as int?,
      price: (json['price'] as num).toDouble(),
      stockQuantity: json['stock_quantity'] as int,
      unit: json['unit'] as String,
    );
  }
}
