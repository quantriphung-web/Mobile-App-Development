import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:backend/screens/api_service.dart';

String get _kBaseUrl => ApiService.baseUrl;

class Product {
  final String id;
  final String productName;
  final String? sku;
  final double salePrice;
  final double? comparePrice;
  final String shortDescription;
  final String productType;
  final String? image;
  final String? brand;
  final List<String> images;
  bool isFavorite;

  Product({
    required this.id,
    required this.productName,
    this.sku,
    required this.salePrice,
    this.comparePrice,
    required this.shortDescription,
    required this.productType,
    this.image,
    this.brand,
    List<String>? images,
    this.isFavorite = false,
  }) : images = images ?? [];

  factory Product.fromJson(Map<String, dynamic> json) {
    // ✅ Dùng resolveImageUrl giống ApiService — xử lý localhost → IP thực
    final imageResolved = ApiService.resolveImageUrl(json['image']?.toString());

    // Parse và resolve từng URL trong images
    final rawImages = json['images'];
    final List<String> resolvedImages = [];
    if (rawImages is List && rawImages.isNotEmpty) {
      for (final img in rawImages) {
        final resolved = ApiService.resolveImageUrl(img?.toString());
        if (resolved != null && resolved.isNotEmpty) {
          resolvedImages.add(resolved);
        }
      }
    }

    // Fallback: nếu images rỗng, dùng image chính
    if (resolvedImages.isEmpty && imageResolved != null) {
      resolvedImages.add(imageResolved);
    }
    return Product(
      id: json['id'].toString(),
      productName:
          _first(json, ['productName', 'product_name'])?.toString() ?? '',
      sku: json['sku']?.toString(),
      salePrice: _toDouble(_first(json, ['salePrice', 'sale_price'])) ?? 0,
      comparePrice: _toDouble(_first(json, ['comparePrice', 'compare_price'])),
      shortDescription:
          _first(json, ['shortDescription', 'short_description'])?.toString() ??
          '',
      productType:
          _first(json, ['productType', 'product_type'])?.toString() ?? '',
      image: imageResolved,
      brand: json['brand']?.toString(),
      images: resolvedImages,
    );
  }

  static dynamic _first(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      if (json.containsKey(key) && json[key] != null) return json[key];
    }
    return null;
  }

  static double? _toDouble(dynamic val) {
    if (val == null) return null;
    if (val is double) return val;
    if (val is int) return val.toDouble();
    return double.tryParse(val.toString());
  }
}

class ProductService {
  static String get _baseUrl => _kBaseUrl;

  Future<List<Product>> getSaleProducts() async {
    try {
      final response = await http
          .get(Uri.parse('$_baseUrl/api/products/sale'))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        return data
            .map((e) => Product.fromJson(e))
            .where((p) => p.productName.trim().isNotEmpty)
            .toList();
      }
      throw Exception('Cannot load sale products (${response.statusCode})');
    } catch (e) {
      throw Exception('Sale products error: $e');
    }
  }

  Future<List<Product>> getNewProducts() async {
    try {
      final response = await http
          .get(Uri.parse('$_baseUrl/api/products/new'))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        return data
            .map((e) => Product.fromJson(e))
            .where((p) => p.productName.trim().isNotEmpty)
            .toList();
      }
      throw Exception('Cannot load new products (${response.statusCode})');
    } catch (e) {
      throw Exception('New products error: $e');
    }
  }
}
