import 'package:backend/screens/api_service.dart';

class Product {
  final String id;
  final String name;
  final String brand;
  final double rating;
  final int reviewCount;
  final double price;
  final double? originalPrice;
  final int? discountPercent;
  final String? imagePath;
  final List<String> images; // Danh sách ảnh (từ product_images table)
  bool isWishlisted;

  Product({
    required this.id,
    required this.name,
    required this.brand,
    required this.rating,
    required this.reviewCount,
    required this.price,
    this.originalPrice,
    this.discountPercent,
    this.imagePath,
    List<String>? images,
    this.isWishlisted = false,
  }) : images = images ?? [];

  bool get hasDiscount =>
      discountPercent != null && discountPercent! > 0 ||
      (originalPrice != null && originalPrice! > price);

  int get computedDiscount {
    if (discountPercent != null && discountPercent! > 0) {
      return discountPercent!;
    }
    if (originalPrice != null && originalPrice! > price) {
      return ((1 - price / originalPrice!) * 100).round();
    }
    return 0;
  }

  /// Tạo Product từ JSON trả về của API
  factory Product.fromJson(Map<String, dynamic> json) {
    final salePrice = _toDouble(_first(json, ['salePrice', 'sale_price'])) ?? 0;
    final comparePrice = _toDouble(
      _first(json, ['comparePrice', 'compare_price']),
    );
    int? discount;
    if (comparePrice != null && comparePrice > salePrice) {
      discount = ((1 - salePrice / comparePrice) * 100).round();
    }

    // Parse images array từ product_images table
    final rawImages = json['images'];
    final List<String> resolvedImages = [];
    if (rawImages is List && rawImages.isNotEmpty) {
      for (final img in rawImages) {
        final resolved = _resolveImage(img?.toString());
        if (resolved != null) resolvedImages.add(resolved);
      }
    }

    // Fallback: parse ảnh chính từ field image
    final resolvedImage = _resolveImage(json['image']?.toString());

    // Nếu images array rỗng, dùng imagePath làm fallback
    if (resolvedImages.isEmpty && resolvedImage != null) {
      resolvedImages.add(resolvedImage);
    }

    return Product(
      id: json['id']?.toString() ?? '',
      name: _first(json, ['productName', 'product_name'])?.toString() ?? '',
      brand:
          _first(json, ['brand', 'productType', 'product_type'])?.toString() ??
          '',
      rating: _toDouble(json['rating']) ?? 0,
      reviewCount: _toInt(_first(json, ['reviewCount', 'review_count'])) ?? 0,
      price: salePrice,
      originalPrice: comparePrice,
      discountPercent: discount,
      imagePath: resolvedImages.isNotEmpty
          ? resolvedImages.first
          : resolvedImage,
      images: resolvedImages,
    );
  }

  static dynamic _first(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      if (json.containsKey(key) && json[key] != null) return json[key];
    }
    return null;
  }

  /// Chuyển đổi URL ảnh:
  /// - Thay toàn bộ host:port bằng baseUrl hiện tại
  /// - Xử lý cả localhost, 127.0.0.1, và mọi IP cũ (192.168.x.x, v.v.)
  /// - Ghép base URL với path tương đối /images/ hoặc /uploads/
  /// - Fallback về assets/images/ nếu là tên file thuần
  static String? _resolveImage(String? raw) {
    if (raw == null || raw.isEmpty) return null;

    // Bất kỳ URL http/https nào → thay toàn bộ host:port bằng baseUrl hiện tại
    if (raw.startsWith('http://') || raw.startsWith('https://')) {
      final uri = Uri.tryParse(raw);
      final baseUri = Uri.tryParse(ApiService.baseUrl);
      if (uri != null && baseUri != null) {
        return uri
            .replace(
              scheme: baseUri.scheme,
              host: baseUri.host,
              port: baseUri.port,
            )
            .toString();
      }
      return raw;
    }

    // Path tương đối từ server → ghép base URL
    if (raw.startsWith('/images/') || raw.startsWith('/uploads/')) {
      return '${ApiService.baseUrl}$raw';
    }

    // Tên file asset cũ → fallback assets
    return 'assets/images/$raw';
  }

  static double? _toDouble(dynamic val) {
    if (val == null) return null;
    if (val is double) return val;
    if (val is int) return val.toDouble();
    return double.tryParse(val.toString());
  }

  static int? _toInt(dynamic val) {
    if (val == null) return null;
    if (val is int) return val;
    return int.tryParse(val.toString());
  }
}

// ── Demo data (dùng khi offline / test UI) ───────────────────────────

final List<Product> demoProducts = [
  Product(
    id: '1',
    name: 'Pullover',
    brand: 'Mango',
    rating: 3.5,
    reviewCount: 3,
    price: 51,
    imagePath: 'assets/images/product1.jpg',
  ),
  Product(
    id: '2',
    name: 'Blouse',
    brand: 'Dorothy Perkins',
    rating: 5.0,
    reviewCount: 10,
    price: 14,
    originalPrice: 21,
    discountPercent: 20,
    imagePath: 'assets/images/product2.jpg',
  ),
  Product(
    id: '3',
    name: 'T-shirt',
    brand: 'LOST Ink',
    rating: 5.0,
    reviewCount: 10,
    price: 12,
    imagePath: 'assets/images/product3.jpg',
    isWishlisted: true,
  ),
  Product(
    id: '4',
    name: 'Shirt',
    brand: 'Topshop',
    rating: 3.5,
    reviewCount: 3,
    price: 51,
    imagePath: 'assets/images/product4.jpg',
  ),
  Product(
    id: '5',
    name: 'T-Shirt Spanish',
    brand: 'Mango',
    rating: 4.0,
    reviewCount: 3,
    price: 9,
    imagePath: 'assets/images/product5.jpg',
  ),
  Product(
    id: '6',
    name: 'Light blouse',
    brand: 'Dorothy Perkins',
    rating: 5.0,
    reviewCount: 10,
    price: 14,
    originalPrice: 21,
    discountPercent: 20,
    imagePath: 'assets/images/product6.jpg',
  ),
  Product(
    id: '7',
    name: 'Shirt',
    brand: 'Mango',
    rating: 0,
    reviewCount: 0,
    price: 22,
    imagePath: 'assets/images/product7.jpg',
  ),
  Product(
    id: '8',
    name: 'Striped top',
    brand: 'River Island',
    rating: 4.5,
    reviewCount: 7,
    price: 18,
    originalPrice: 30,
    discountPercent: 20,
    imagePath: 'assets/images/product8.jpg',
  ),
];
