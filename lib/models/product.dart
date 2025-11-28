class Product {
  final int productId;
  final String productName;
  final int? categoryId;
  final String? categoryName;
  final double price;
  final int stockQuantity;
  final String unit;
  final String? imagePath;
  final DateTime? expiryDate;

  Product({
    required this.productId,
    required this.productName,
    required this.categoryId,
    this.categoryName,
    required this.price,
    required this.stockQuantity,
    required this.unit,
    this.imagePath,
    this.expiryDate, 
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    final expiryStr = json['expiry_date'] as String?;
    DateTime? expiry;

    if (expiryStr != null && expiryStr.isNotEmpty) {
      try {
        expiry = DateTime.parse(expiryStr); // expects "YYYY-MM-DD"
      } catch (_) {
        expiry = null; // if format is bad, just ignore
      }
    }

    return Product(
      productId: json['product_id'] as int,
      productName: json['product_name'] as String,
      categoryId: json['category_id'] as int?,
      categoryName: json['category_name'] as String?,
      price: (json['price'] as num).toDouble(),
      stockQuantity: json['stock_quantity'] as int,
      unit: json['unit'] as String,
      imagePath: json['image_path'] as String?,
      expiryDate: expiry,
    );
  }
}