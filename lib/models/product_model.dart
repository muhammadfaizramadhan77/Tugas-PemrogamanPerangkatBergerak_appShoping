double _toDouble(dynamic v) => v is num ? v.toDouble() : 0.0;
int _toInt(dynamic v, [int def = 0]) => v is num ? v.toInt() : def;
String _toStr(dynamic v) => v?.toString() ?? '';
Map<String, dynamic> _toMap(dynamic v) =>
    v is Map ? Map<String, dynamic>.from(v) : <String, dynamic>{};

class Dimensions {
  final double width, height, depth;
  const Dimensions({this.width = 0, this.height = 0, this.depth = 0});
  factory Dimensions.fromJson(Map<String, dynamic> j) => Dimensions(
        width: _toDouble(j['width']),
        height: _toDouble(j['height']),
        depth: _toDouble(j['depth']),
      );
}

class Review {
  final int rating;
  final String comment, date, reviewerName, reviewerEmail;
  const Review({
    this.rating = 0,
    this.comment = '',
    this.date = '',
    this.reviewerName = '',
    this.reviewerEmail = '',
  });
  factory Review.fromJson(Map<String, dynamic> j) => Review(
        rating: _toInt(j['rating']),
        comment: _toStr(j['comment']),
        date: _toStr(j['date']),
        reviewerName: _toStr(j['reviewerName']),
        reviewerEmail: _toStr(j['reviewerEmail']),
      );
}

class Meta {
  final String createdAt, updatedAt, barcode, qrCode;
  const Meta({
    this.createdAt = '',
    this.updatedAt = '',
    this.barcode = '',
    this.qrCode = '',
  });
  factory Meta.fromJson(Map<String, dynamic> j) => Meta(
        createdAt: _toStr(j['createdAt']),
        updatedAt: _toStr(j['updatedAt']),
        barcode: _toStr(j['barcode']),
        qrCode: _toStr(j['qrCode']),
      );
}

class Category {
  final String slug, name, url;
  const Category({required this.slug, required this.name, required this.url});
  factory Category.fromJson(Map<String, dynamic> j) => Category(
        slug: _toStr(j['slug']),
        name: _toStr(j['name']),
        url: _toStr(j['url']),
      );
}

class Product {
  final int id;
  final String title, description, category, brand, sku;
  final double price, discountPercentage, rating;
  final int stock, weight, minimumOrderQuantity;
  final List<String> tags, images;
  final Dimensions dimensions;
  final String warrantyInformation,
      shippingInformation,
      availabilityStatus,
      returnPolicy,
      thumbnail;
  final List<Review> reviews;
  final Meta meta;
  final bool isDeleted;
  final String? deletedOn;

  const Product({
    required this.id,
    required this.title,
    this.description = '',
    this.category = '',
    this.price = 0,
    this.discountPercentage = 0,
    this.rating = 0,
    this.stock = 0,
    this.tags = const [],
    this.brand = '',
    this.sku = '',
    this.weight = 0,
    this.dimensions = const Dimensions(),
    this.warrantyInformation = '',
    this.shippingInformation = '',
    this.availabilityStatus = '',
    this.reviews = const [],
    this.returnPolicy = '',
    this.minimumOrderQuantity = 1,
    this.meta = const Meta(),
    this.thumbnail = '',
    this.images = const [],
    this.isDeleted = false,
    this.deletedOn,
  });

  factory Product.fromJson(Map<String, dynamic> json) => Product(
        id: _toInt(json['id']),
        title: _toStr(json['title']),
        description: _toStr(json['description']),
        category: _toStr(json['category']),
        price: _toDouble(json['price']),
        discountPercentage: _toDouble(json['discountPercentage']),
        rating: _toDouble(json['rating']),
        stock: _toInt(json['stock']),
        tags: (json['tags'] as List? ?? []).map((e) => e.toString()).toList(),
        brand: _toStr(json['brand']),
        sku: _toStr(json['sku']),
        weight: _toInt(json['weight']),
        dimensions: Dimensions.fromJson(_toMap(json['dimensions'])),
        warrantyInformation: _toStr(json['warrantyInformation']),
        shippingInformation: _toStr(json['shippingInformation']),
        availabilityStatus: _toStr(json['availabilityStatus']),
        reviews: (json['reviews'] as List? ?? [])
            .map((e) => Review.fromJson(_toMap(e)))
            .toList(),
        returnPolicy: _toStr(json['returnPolicy']),
        minimumOrderQuantity: _toInt(json['minimumOrderQuantity'], 1),
        meta: Meta.fromJson(_toMap(json['meta'])),
        thumbnail: _toStr(json['thumbnail']),
        images: (json['images'] as List? ?? []).map((e) => e.toString()).toList(),
        isDeleted: json['isDeleted'] == true,
        deletedOn: json['deletedOn']?.toString(),
      );

  Map<String, dynamic> toJson() => {
        'title': title,
        'description': description,
        'category': category,
        'price': price,
        'brand': brand,
        'stock': stock,
        'thumbnail': thumbnail,
      };

  Product copyWith({
    int? id,
    String? title,
    String? description,
    String? category,
    String? brand,
    double? price,
    int? stock,
  }) =>
      Product(
        id: id ?? this.id,
        title: title ?? this.title,
        description: description ?? this.description,
        category: category ?? this.category,
        price: price ?? this.price,
        discountPercentage: discountPercentage,
        rating: rating,
        stock: stock ?? this.stock,
        tags: tags,
        brand: brand ?? this.brand,
        sku: sku,
        weight: weight,
        dimensions: dimensions,
        warrantyInformation: warrantyInformation,
        shippingInformation: shippingInformation,
        availabilityStatus: availabilityStatus,
        reviews: reviews,
        returnPolicy: returnPolicy,
        minimumOrderQuantity: minimumOrderQuantity,
        meta: meta,
        thumbnail: thumbnail,
        images: images,
      );
}

class ProductsResponse {
  final List<Product> products;
  final int total, skip, limit;
  const ProductsResponse({
    required this.products,
    required this.total,
    required this.skip,
    required this.limit,
  });
  factory ProductsResponse.fromJson(Map<String, dynamic> json) {
    final list = (json['products'] as List? ?? [])
        .map((e) => Product.fromJson(_toMap(e)))
        .toList();
    return ProductsResponse(
      products: list,
      total: _toInt(json['total'], list.length),
      skip: _toInt(json['skip']),
      limit: _toInt(json['limit'], 30),
    );
  }
}
