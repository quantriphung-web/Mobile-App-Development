import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:backend/screens/product_model.dart';

class ApiService {
  /// Spring Boot backend (port 8080). Override at build time:
  /// `flutter run --dart-define=API_BASE_URL=http://<your-ip>:8080`
  static const _springPort = 8080;

  /// LAN IP of the machine running Spring Boot (see `app.base-url` in application.properties).
  static const _defaultLanHost = '172.16.7.149';
  static const _prefKey = 'api_base_url';
  static const _requestTimeout = Duration(seconds: 15);

  static String? _resolvedBaseUrl;

  /// Gọi trong `main()` trước `runApp` — tự tìm IP Spring Boot đang chạy.
  static Future<void> init() async {
    const configured = String.fromEnvironment('API_BASE_URL');
    if (configured.isNotEmpty) {
      _resolvedBaseUrl = configured;
      debugPrint('[ApiService] API_BASE_URL=$configured');
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_prefKey);
    if (saved != null && await _probe(saved)) {
      _resolvedBaseUrl = saved;
      debugPrint('[ApiService] Using saved base URL: $saved');
      return;
    }

    for (final url in _candidateBaseUrls()) {
      if (await _probe(url)) {
        _resolvedBaseUrl = url;
        await prefs.setString(_prefKey, url);
        debugPrint('[ApiService] Connected to Spring Boot at $url');
        return;
      }
    }

    _resolvedBaseUrl = _candidateBaseUrls().first;
    debugPrint(
      '[ApiService] WARNING: Cannot reach Spring Boot. '
      'Using fallback $_resolvedBaseUrl — start server or set '
      '--dart-define=API_BASE_URL=http://<ip>:8080',
    );
  }

  static String get baseUrl {
    const configured = String.fromEnvironment('API_BASE_URL');
    if (configured.isNotEmpty) return configured;
    if (_resolvedBaseUrl != null) return _resolvedBaseUrl!;
    return _fallbackBaseUrl();
  }

  static String _fallbackBaseUrl() {
    if (kIsWeb) return 'http://localhost:$_springPort';
    if (defaultTargetPlatform == TargetPlatform.android) {
      // Emulator: 10.0.2.2 = localhost của máy host
      return 'http://10.0.2.2:$_springPort';
    }
    return 'http://localhost:$_springPort';
  }

  static List<String> _candidateBaseUrls() {
    if (kIsWeb) return ['http://localhost:$_springPort'];
    if (defaultTargetPlatform == TargetPlatform.android) {
      return [
        'http://10.0.2.2:$_springPort',
        'http://$_defaultLanHost:$_springPort',
        'http://localhost:$_springPort',
      ];
    }
    return ['http://localhost:$_springPort'];
  }

  static Future<bool> _probe(String url) async {
    try {
      final response = await http
          .get(Uri.parse('$url/api/auth/health'))
          .timeout(const Duration(seconds: 4));
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  static final _client = http.Client();

  static Future<http.Response> _get(Uri uri, {Map<String, String>? headers}) {
    return _client.get(uri, headers: headers).timeout(_requestTimeout);
  }

  static Future<http.Response> _post(
    Uri uri, {
    Map<String, String>? headers,
    Object? body,
  }) {
    return _client
        .post(uri, headers: headers, body: body)
        .timeout(_requestTimeout);
  }

  static Future<http.Response> _put(
    Uri uri, {
    Map<String, String>? headers,
    Object? body,
  }) {
    return _client
        .put(uri, headers: headers, body: body)
        .timeout(_requestTimeout);
  }

  static Future<http.Response> _patch(
    Uri uri, {
    Map<String, String>? headers,
    Object? body,
  }) {
    return _client
        .patch(uri, headers: headers, body: body)
        .timeout(_requestTimeout);
  }

  static Future<http.Response> _delete(
    Uri uri, {
    Map<String, String>? headers,
  }) {
    return _client.delete(uri, headers: headers).timeout(_requestTimeout);
  }

  static Never _httpError(String action, http.Response response) {
    final snippet = response.body.length > 200
        ? '${response.body.substring(0, 200)}...'
        : response.body;
    throw Exception(
      '$action failed (${response.statusCode}) at $baseUrl: $snippet',
    );
  }

  static Future<bool> checkConnection() async {
    try {
      final uri = Uri.parse('$baseUrl/api/auth/health');
      final response = await _get(uri);
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('[ApiService] checkConnection failed: $e');
      return false;
    }
  }

  // ── Helper chung: thay TOÀN BỘ host:port bằng baseUrl hiện tại ──────
  static String? resolveImageUrl(String? raw) {
    if (raw == null || raw.isEmpty) return null;

    if (raw.startsWith('http://') || raw.startsWith('https://')) {
      final uri = Uri.tryParse(raw.trim());
      final baseUri = Uri.tryParse(baseUrl);
      if (uri != null && baseUri != null) {
        return uri
            .replace(
              scheme: baseUri.scheme,
              host: baseUri.host,
              port: baseUri.port,
            )
            .toString();
      }
      return raw.trim();
    }

    if (raw.startsWith('/images/') || raw.startsWith('/uploads/')) {
      return '$baseUrl${raw.trim()}';
    }

    return 'assets/images/${raw.trim()}';
  }

  // ── Helper nội bộ ───────────────────────────────────────────────────

  static bool _isValidProduct(Product p) => p.name.trim().isNotEmpty;

  static dynamic _first(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      if (json.containsKey(key) && json[key] != null) return json[key];
    }
    return null;
  }

  static double? _toDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    return double.tryParse(value.toString());
  }

  // ✅ Helper parse photo_urls — dùng chung cho mọi nơi
  static List<String> _parsePhotoUrls(dynamic raw) {
    final List<String> result = [];
    if (raw == null) return result;

    if (raw is List) {
      // JSON array: ["url1", "url2"]
      result.addAll(
        raw.map((e) => e.toString().trim()).where((s) => s.isNotEmpty),
      );
    } else if (raw is String && raw.isNotEmpty) {
      // PostgreSQL TEXT[] dạng: {url1,url2} hoặc {"url1","url2"}
      final clean = raw.trim().replaceAll(RegExp(r'^\{|\}$'), '').trim();
      if (clean.isNotEmpty) {
        result.addAll(
          clean
              .split(',')
              .map((s) => s.trim().replaceAll(RegExp(r'^"|"$'), '').trim())
              .where((s) => s.isNotEmpty),
        );
      }
    }
    return result;
  }

  // ── Products ─────────────────────────────────────────────────────────

  static Future<List<Product>> getProducts({
    String? categoryId,
    String sort = 'newest',
    double? minPrice,
    double? maxPrice,
  }) async {
    final uri = Uri.parse('$baseUrl/api/products');
    final response = await _get(uri);

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);

      if (categoryId != null) {
        data = data.where((item) {
          final cats = item['categories'];
          if (cats is List) {
            return cats.any((c) => c['id'].toString() == categoryId);
          }
          return false;
        }).toList();
      }

      if (minPrice != null) {
        data = data.where((item) {
          final price =
              _toDouble(_first(item, ['salePrice', 'sale_price'])) ?? 0.0;
          return price >= minPrice;
        }).toList();
      }
      if (maxPrice != null) {
        data = data.where((item) {
          final price =
              _toDouble(_first(item, ['salePrice', 'sale_price'])) ?? 0.0;
          return price <= maxPrice;
        }).toList();
      }

      var products = data
          .map((json) => Product.fromJson(json))
          .where(_isValidProduct)
          .toList();

      if (sort == 'price_asc') {
        products.sort((a, b) => a.price.compareTo(b.price));
      } else if (sort == 'price_desc') {
        products.sort((a, b) => b.price.compareTo(a.price));
      } else if (sort == 'popular') {
        products.sort((a, b) => b.reviewCount.compareTo(a.reviewCount));
      } else if (sort == 'rating') {
        products.sort((a, b) => b.rating.compareTo(a.rating));
      } else {
        products = products.reversed.toList();
      }

      return products;
    }
    throw Exception('Failed to load products: ${response.statusCode}');
  }

  static Future<List<Product>> getSaleProducts() async {
    final uri = Uri.parse('$baseUrl/api/products/sale');
    final response = await _get(uri);

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data
          .map((json) => Product.fromJson(json))
          .where(_isValidProduct)
          .toList();
    }
    throw Exception('Failed to load sale products');
  }

  static Future<List<Product>> getNewProducts() async {
    final uri = Uri.parse('$baseUrl/api/products/new');
    final response = await _get(uri);

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data
          .map((json) => Product.fromJson(json))
          .where(_isValidProduct)
          .take(20)
          .toList();
    }
    throw Exception('Failed to load new products');
  }

  static Future<Product> getProductById(String id) async {
    final uri = Uri.parse('$baseUrl/api/products/$id');
    final response = await _get(uri);

    if (response.statusCode == 200) {
      return Product.fromJson(jsonDecode(response.body));
    }
    throw Exception('Product not found');
  }

  static Future<List<Product>> getRelatedProducts(
    String productId, {
    int limit = 10,
  }) async {
    final response = await _get(Uri.parse('$baseUrl/api/products'));
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      final thisProductJson = data.firstWhere(
        (item) => item['id'].toString() == productId,
        orElse: () => null,
      );
      if (thisProductJson == null) return [];
      final thisCats = thisProductJson['categories'];
      final List<String> thisCatIds = [];
      if (thisCats is List) {
        for (final c in thisCats) {
          thisCatIds.add(c['id'].toString());
        }
      }

      final relatedJson = data.where((item) {
        if (item['id'].toString() == productId) return false;
        final cats = item['categories'];
        if (cats is List) {
          return cats.any((c) => thisCatIds.contains(c['id'].toString()));
        }
        return false;
      }).toList();

      return relatedJson
          .take(limit)
          .map((json) => Product.fromJson(json))
          .where(_isValidProduct)
          .toList();
    }
    throw Exception('Failed to load related products');
  }

  static Future<Map<String, dynamic>> getProductShipping(
    String productId,
  ) async {
    try {
      final uri = Uri.parse('$baseUrl/api/product-shipping-infos');
      final response = await _get(uri);
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final matching = data.firstWhere((item) {
          final prod = item['product'];
          return prod != null && prod['id'].toString() == productId;
        }, orElse: () => null);
        if (matching != null) {
          return {
            'estimated_days': matching['estimated_days'] ?? '3-5',
            'carrier': matching['carrier'] ?? 'Standard Shipping',
            'free_threshold': matching['free_threshold'] ?? 50.0,
            'return_days': matching['return_days'] ?? 30,
            'note': matching['note'] ?? 'Standard shipping applies.',
          };
        }
      }
    } catch (_) {}
    return {
      'estimated_days': '3-5',
      'carrier': 'Standard Shipping',
      'free_threshold': 50,
      'return_days': 30,
      'note': 'Standard shipping applies.',
    };
  }

  static Future<Map<String, dynamic>> getProductSupport(
    String productId,
  ) async {
    return {
      'contact_email': 'support@fashionstore.com',
      'phone': '+1 (800) 123-4560',
      'hours': 'Mon–Fri 9am–6pm EST',
      'faq': 'Machine washable. Standard care.',
      'warranty': '30-day quality guarantee.',
    };
  }

  // ── Reviews ──────────────────────────────────────────────────────────

  static Future<List<Map<String, dynamic>>> getProductReviews(
    String productId,
  ) async {
    final uri = Uri.parse('$baseUrl/api/products/$productId/reviews');
    final response = await _get(uri);
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);

      // Try to detect current user (if logged in) so client can mark their review
      final currentUser = await getCurrentUser();
      final currentUsername = (currentUser?['username'] ?? currentUser?['name'])
          ?.toString()
          .toLowerCase();
      final currentEmail = currentUser?['email']?.toString().toLowerCase();

      return data.map((item) {
        final Map<String, dynamic> review = Map<String, dynamic>.from(item);

        // ✅ Parse + resolve host/port cho từng URL ảnh
        final resolvedPhotos = _parsePhotoUrls(
          review['photoUrls'] ?? review['photo_urls'],
        ).map((url) => resolveImageUrl(url) ?? url).toList();

        review['photo_urls'] = resolvedPhotos;
        review['has_photo'] = resolvedPhotos.isNotEmpty;

        // Mark review as belonging to current user when possible
        try {
          // Prefer comparing user_id (added on server) to current user id
          final revUserId =
              review['user_id'] ?? review['userId'] ?? review['user']?['id'];
          final curId = currentUser?['id'];
          if (curId != null &&
              revUserId != null &&
              revUserId.toString() == curId.toString()) {
            review['is_current_user'] = true;
          } else {
            final reviewer = (review['reviewer_name'] ?? review['name'] ?? '')
                .toString()
                .toLowerCase();
            if (currentUsername != null &&
                currentUsername.isNotEmpty &&
                (reviewer == currentUsername ||
                    reviewer.contains(currentUsername))) {
              review['is_current_user'] = true;
            } else if (currentEmail != null &&
                currentEmail.isNotEmpty &&
                (reviewer == currentEmail || reviewer.contains(currentEmail))) {
              review['is_current_user'] = true;
            }
          }
        } catch (_) {}

        return _normalizeReview(review);
      }).toList();
    }
    return [];
  }

  /// Returns current authenticated user via Spring `/api/auth/me`, or null when not logged.
  static Future<Map<String, dynamic>?> getCurrentUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      if (token == null || token.isEmpty) return null;

      final uri = Uri.parse('$baseUrl/api/auth/me');
      final resp = await _get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );
      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body);
        if (data is Map<String, dynamic>) return data;
      }
    } catch (_) {}
    return null;
  }

  /// Update an existing review (requires backend support at PATCH /api/products/:id/reviews/:reviewId)
  static Future<Map<String, dynamic>?> updateProductReview(
    String productId,
    String reviewId, {
    required int rating,
    required String reviewText,
    List<String>? photoUrls,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      if (token == null || token.isEmpty) return null;

      final uri = Uri.parse(
        '$baseUrl/api/products/$productId/reviews/$reviewId',
      );
      final body = jsonEncode({
        'rating': rating,
        'review_text': reviewText,
        'photo_urls': photoUrls,
      });

      final resp = await _put(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: body,
      );

      if (resp.statusCode == 200 || resp.statusCode == 201) {
        final json = jsonDecode(resp.body) as Map<String, dynamic>;
        return _normalizeReview(json);
      }
    } catch (_) {}
    return null;
  }

  /// Delete a review (requires backend support at DELETE /api/products/:id/reviews/:reviewId)
  static Future<bool> deleteProductReview(
    String productId,
    String reviewId,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      if (token == null || token.isEmpty) return false;

      final uri = Uri.parse(
        '$baseUrl/api/products/$productId/reviews/$reviewId',
      );
      final resp = await _delete(
        uri,
        headers: {'Authorization': 'Bearer $token'},
      );
      return resp.statusCode >= 200 && resp.statusCode < 300;
    } catch (_) {}
    return false;
  }

  static Future<Map<String, dynamic>?> postProductReview(
    String productId, {
    required String reviewerName,
    required String avatarLetter,
    required String avatarColor,
    required int rating,
    required String reviewText,
    List<XFile> photos = const [],
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      if (token == null || token.isEmpty) {
        debugPrint('postProductReview: không có auth_token, cần đăng nhập');
        return null;
      }

      final uri = Uri.parse('$baseUrl/api/products/$productId/reviews');
      final request = http.MultipartRequest('POST', uri);

      request.headers['Authorization'] = 'Bearer $token';
      request.fields['rating'] = rating.toString();
      // Spring Boot ProductReviewController expects `reviewText` (camelCase param name)
      request.fields['reviewText'] = reviewText.trim();

      for (final xfile in photos) {
        final path = xfile.path.trim();
        final mimeType = xfile.mimeType ?? 'image/jpeg';
        final parts = mimeType.split('/');
        request.files.add(
          await http.MultipartFile.fromPath(
            'photos',
            path,
            contentType: MediaType(
              parts[0],
              parts.length > 1 ? parts[1] : 'jpeg',
            ),
          ),
        );
      }

      final streamed = await request.send();
      final response = await http.Response.fromStream(streamed);

      debugPrint('postProductReview: ${response.statusCode}');
      debugPrint('postProductReview body: ${response.body}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;

        // ✅ Parse + resolve host/port cho từng URL ảnh
        final resolvedPhotos = _parsePhotoUrls(
          json['photoUrls'] ?? json['photo_urls'],
        ).map((url) => resolveImageUrl(url) ?? url).toList();

        json['photo_urls'] = resolvedPhotos;
        json['has_photo'] = resolvedPhotos.isNotEmpty;
        final normalized = _normalizeReview(json);
        normalized['is_current_user'] = true;
        return normalized;
      }

      if (response.statusCode == 400) {
        final err = jsonDecode(response.body);
        if (err is Map<String, dynamic>) {
          final msg = err['message']?.toString();
          if (msg != null && msg.isNotEmpty) {
            throw Exception(msg);
          }
        }
      }
      return null;
    } catch (e) {
      debugPrint('postProductReview error: $e');
      return null;
    }
  }

  /// Upload a single image via Spring `POST /api/upload` (multipart field `file`).
  static Future<List<String>> uploadReviewImages(List<XFile> photos) async {
    if (photos.isEmpty) return [];
    final List<String> uploadedUrls = [];
    for (final xfile in photos) {
      try {
        final uri = Uri.parse('$baseUrl/api/upload');
        final request = http.MultipartRequest('POST', uri);
        final mimeType = xfile.mimeType ?? 'image/jpeg';
        final parts = mimeType.split('/');
        request.files.add(
          await http.MultipartFile.fromPath(
            'file',
            xfile.path.trim(),
            contentType: MediaType(
              parts[0],
              parts.length > 1 ? parts[1] : 'jpeg',
            ),
          ),
        );
        final streamedResponse = await request.send();
        final response = await http.Response.fromStream(streamedResponse);
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body) as Map<String, dynamic>;
          final url = data['url']?.toString().trim();
          if (url != null && url.isNotEmpty) {
            uploadedUrls.add(resolveImageUrl(url) ?? url);
          }
        }
      } catch (e) {
        debugPrint('uploadReviewImages error: $e');
      }
    }
    return uploadedUrls;
  }

  /// True when the logged-in user already reviewed this product.
  static Future<bool> hasUserReviewedProduct(String productId) async {
    final reviews = await getProductReviews(productId);
    return reviews.any((r) => r['is_current_user'] == true);
  }

  static Map<String, dynamic> _normalizeReview(Map<String, dynamic> review) {
    review['user_id'] ??= review['userId'];
    review['reviewer_name'] ??= review['reviewerName'];
    review['avatar_letter'] ??= review['avatarLetter'];
    review['avatar_color'] ??= review['avatarColor'];
    review['review_text'] ??= review['reviewText'];
    review['has_photo'] ??= review['hasPhoto'];
    review['helpful_count'] ??= review['helpfulCount'];

    // ✅ Nếu photo_urls chưa có hoặc rỗng, thử parse + resolve lại
    if (review['photo_urls'] == null ||
        (review['photo_urls'] as List).isEmpty) {
      final photos = _parsePhotoUrls(
        review['photoUrls'] ?? review['photoUrlsRaw'],
      ).map((url) => resolveImageUrl(url) ?? url).toList();
      if (photos.isNotEmpty) review['photo_urls'] = photos;
    }

    return review;
  }

  // ── Categories ───────────────────────────────────────────────────────

  static Future<List<CategoryModel>> getRootCategories() async {
    final uri = Uri.parse('$baseUrl/api/categories');
    final response = await _get(uri);

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data
          .map((json) => CategoryModel.fromJson(json))
          .where((c) => c.parentId == null)
          .toList();
    }
    throw Exception('Failed to load categories');
  }

  static Future<List<CategoryModel>> getSubCategories(String parentId) async {
    final uri = Uri.parse('$baseUrl/api/categories');
    final response = await _get(uri);

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data
          .map((json) => CategoryModel.fromJson(json))
          .where((c) => c.parentId == parentId)
          .toList();
    }
    throw Exception('Failed to load subcategories');
  }

  static Future<List<CategoryModel>> getAllCategories() async {
    final uri = Uri.parse('$baseUrl/api/categories');
    final response = await _get(uri);

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => CategoryModel.fromJson(json)).toList();
    }
    throw Exception('Failed to load categories');
  }

  // ── Favorites ────────────────────────────────────────────────────────

  static Future<bool> hasAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    return token != null && token.isNotEmpty;
  }

  static Future<Map<String, String>> _authHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token') ?? '';
    return {'Authorization': 'Bearer $token', 'Accept': 'application/json'};
  }

  static Future<List<Product>> getFavoriteProducts() async {
    final headers = await _authHeaders();
    if (headers['Authorization'] == 'Bearer ') return [];

    final uri = Uri.parse('$baseUrl/api/favorites');
    final response = await _get(uri, headers: headers);
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data
          .map((json) => Product.fromJson(json as Map<String, dynamic>))
          .where((p) => p.name.trim().isNotEmpty)
          .toList();
    }
    return [];
  }

  static Future<Set<String>> getFavoriteProductIds() async {
    final headers = await _authHeaders();
    if (headers['Authorization'] == 'Bearer ') return {};

    final uri = Uri.parse('$baseUrl/api/favorites/ids');
    final response = await _get(uri, headers: headers);
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => e.toString()).toSet();
    }
    return {};
  }

  static Future<bool> addFavorite(String productId) async {
    final headers = await _authHeaders();
    if (headers['Authorization'] == 'Bearer ') return false;

    final uri = Uri.parse('$baseUrl/api/favorites/$productId');
    final response = await _post(uri, headers: headers);
    return response.statusCode == 200 || response.statusCode == 201;
  }

  static Future<bool> removeFavorite(String productId) async {
    final headers = await _authHeaders();
    if (headers['Authorization'] == 'Bearer ') return false;

    final uri = Uri.parse('$baseUrl/api/favorites/$productId');
    final response = await _delete(uri, headers: headers);
    return response.statusCode >= 200 && response.statusCode < 300;
  }

  // ── Brands ───────────────────────────────────────────────────────────

  static Future<List<String>> getBrands() async {
    final uri = Uri.parse('$baseUrl/api/products');
    final response = await _get(uri);

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      final Set<String> uniqueBrands = {};
      for (final item in data) {
        final b = item['brand']?.toString().trim();
        if (b != null && b.isNotEmpty) {
          uniqueBrands.add(b);
        }
      }
      return uniqueBrands.toList()..sort();
    }
    throw Exception('Failed to load brands');
  }
}

// ── CategoryModel ────────────────────────────────────────────────────

class CategoryModel {
  final String id;
  final String? parentId;
  final String categoryName;
  final String? categoryDescription;
  final String? icon;
  final String? image;
  final bool active;

  CategoryModel({
    required this.id,
    this.parentId,
    required this.categoryName,
    this.categoryDescription,
    this.icon,
    this.image,
    required this.active,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    final imageResolved = ApiService.resolveImageUrl(json['image']?.toString());

    return CategoryModel(
      id: json['id'].toString(),
      parentId: ApiService._first(json, ['parentId', 'parent_id'])?.toString(),
      categoryName:
          ApiService._first(json, [
            'categoryName',
            'category_name',
          ])?.toString() ??
          '',
      categoryDescription: ApiService._first(json, [
        'categoryDescription',
        'category_description',
      ])?.toString(),
      icon: json['icon']?.toString(),
      image: imageResolved,
      active: json['active'] as bool? ?? true,
    );
  }
}
