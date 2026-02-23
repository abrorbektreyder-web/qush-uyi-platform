class ShopItemModel {
  final String id;
  final String name;
  final String? description;
  final double price;
  final int stockQuantity;
  final String category;
  final String? imageUrl;
  final bool isActive;

  ShopItemModel({
    required this.id,
    required this.name,
    this.description,
    required this.price,
    required this.stockQuantity,
    required this.category,
    this.imageUrl,
    required this.isActive,
  });

  factory ShopItemModel.fromJson(Map<String, dynamic> json) {
    return ShopItemModel(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      description: json['description'],
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      stockQuantity: json['stock_quantity'] ?? 0,
      category: json['category'] ?? 'Boshqa',
      imageUrl: json['image_url'],
      isActive: json['is_active'] ?? true,
    );
  }
}
