class BirdModel {
  final String id;
  final int categoryId;
  final String? species;
  final String? description;
  final double price;
  final String status;
  final String regionName;
  final String sellerName;
  final String? sellerPhone;
  final List<MediaModel> media;

  BirdModel({
    required this.id,
    required this.categoryId,
    this.species,
    this.description,
    required this.price,
    required this.status,
    required this.regionName,
    required this.sellerName,
    this.sellerPhone,
    this.media = const [],
  });

  factory BirdModel.fromJson(Map<String, dynamic> json) {
    var mediaList = json['media'] as List? ?? [];
    return BirdModel(
      id: json['id']?.toString() ?? '',
      categoryId: json['category_id'] ?? 0,
      species: json['species'],
      description: json['description'],
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] ?? 'active',
      regionName: json['region_name'] ?? "Noma'lum",
      sellerName: json['seller_name'] ?? 'Sotuvchi',
      sellerPhone: json['seller_phone'],
      media: mediaList.map((m) => MediaModel.fromJson(m)).toList(),
    );
  }
}

class MediaModel {
  final String type;
  final String url;

  MediaModel({required this.type, required this.url});

  factory MediaModel.fromJson(Map<String, dynamic> json) {
    return MediaModel(
      type: json['type'] ?? 'image',
      url: json['url'] ?? '',
    );
  }
}
