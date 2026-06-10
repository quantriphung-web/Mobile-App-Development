import 'package:flutter/material.dart';
import 'package:backend/services/product_service.dart';
import 'package:backend/services/favorites_service.dart';
import 'package:backend/screens/product_model.dart' as model;
import 'package:backend/screens/productdetailscreen.dart';
import 'package:backend/screens/connection_helper.dart';
import 'package:backend/screens/app_bottom_nav.dart';
import 'package:backend/screens/api_service.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;

  final ScrollController _scrollController = ScrollController();
  final _service = ProductService();
  final PageController _bannerPageController = PageController();

  int _currentBannerPage = 0;
  double _bannerPageOffset = 0.0;

  final List<String> _bannerImages = [
    'assets/images/anhchu.png',
    'assets/images/anhchu1.jpg',
    'assets/images/anhchu2.jpg',
  ];

  late Future<List<Product>> _saleFuture;
  late Future<List<Product>> _newFuture;

  @override
  void initState() {
    super.initState();
    FavoritesService.instance.addListener(_onFavoritesChanged);
    FavoritesService.instance.refresh();
    _saleFuture = _loadSaleProducts();
    _newFuture = _loadNewProducts();
    _bannerPageController.addListener(() {
      if (_bannerPageController.hasClients) {
        setState(() {
          _bannerPageOffset = _bannerPageController.page ?? 0.0;
        });
      }
    });
  }

  @override
  void dispose() {
    FavoritesService.instance.removeListener(_onFavoritesChanged);
    _bannerPageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onCheckPressed() {
    _scrollController.animateTo(
      300,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOut,
    );
  }

  void _onFavoritesChanged() {
    if (mounted) setState(() {});
  }

  Future<List<Product>> _loadSaleProducts() async {
    final products = await _service.getSaleProducts();
    FavoritesService.instance.applyToProducts(
      products,
      (p) => p.id,
      (p, liked) => p.isFavorite = liked,
    );
    return products;
  }

  Future<List<Product>> _loadNewProducts() async {
    final products = await _service.getNewProducts();
    FavoritesService.instance.applyToProducts(
      products,
      (p) => p.id,
      (p, liked) => p.isFavorite = liked,
    );
    return products;
  }

  Future<void> _toggleFavorite(Product product) async {
    final result = await FavoritesService.instance.toggle(product.id);
    if (result == null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please login to save favorites')),
      );
      return;
    }
    if (mounted) {
      setState(() => product.isFavorite = result ?? product.isFavorite);
    }
  }

  Future<void> _onRefresh() async {
    await FavoritesService.instance.refresh();
    setState(() {
      _saleFuture = _loadSaleProducts();
      _newFuture = _loadNewProducts();
    });
  }

  // ── Convert Product (service) → Product (model) để navigate ──
  model.Product _toModelProduct(Product p) {
    // Resolve URL: thay host:port bất kỳ bằng baseUrl hiện tại
    String? resolveUrl(String? raw) {
      if (raw == null || raw.isEmpty) return null;
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
      }
      if (raw.startsWith('/images/') || raw.startsWith('/uploads/')) {
        return '${ApiService.baseUrl}$raw';
      }
      return raw;
    }

    final resolvedImages = p.images.isNotEmpty
        ? p.images.map(resolveUrl).whereType<String>().toList()
        : (p.image != null
              ? [resolveUrl(p.image)].whereType<String>().toList()
              : <String>[]);

    return model.Product(
      id: p.id,
      name: p.productName,
      brand: p.brand ?? '',
      rating: 0,
      reviewCount: 0,
      price: p.salePrice,
      originalPrice: p.comparePrice,
      imagePath: resolvedImages.isNotEmpty ? resolvedImages.first : null,
      images: resolvedImages,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      body: _selectedIndex == 0 ? _buildHomeTab() : _buildPlaceholderTab(),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // ───────────────────────── HOME TAB ─────────────────────────
  Widget _buildHomeTab() {
    final bool isPage3 = _currentBannerPage == 2;
    final mq = MediaQuery.of(context);
    final double availableHeight =
        mq.size.height -
        mq.padding.top -
        mq.padding.bottom -
        kBottomNavigationBarHeight;

    return RefreshIndicator(
      onRefresh: _onRefresh,
      color: const Color(0xFFDB3022),
      backgroundColor: Colors.white,
      child: MediaQuery.removePadding(
        context: context,
        removeTop: true,
        child: CustomScrollView(
          controller: _scrollController,
          physics: isPage3
              ? const NeverScrollableScrollPhysics()
              : const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Builder(
                builder: (context) {
                  final double tallHeight = availableHeight * 0.58;
                  final double shortHeight = availableHeight * 0.37;
                  final double page3Height = availableHeight;
                  final double offset = _bannerPageOffset;

                  double height;
                  if (offset <= 1.0) {
                    height =
                        tallHeight -
                        (tallHeight - shortHeight) * offset.clamp(0.0, 1.0);
                  } else {
                    final t = (offset - 1.0).clamp(0.0, 1.0);
                    height = shortHeight + (page3Height - shortHeight) * t;
                  }

                  return SizedBox(height: height, child: _buildHeroBanner());
                },
              ),
            ),

            if (!isPage3) ...[
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
                  child: _buildSectionHeader('Sale', 'Super summer sale'),
                ),
              ),
              SliverToBoxAdapter(
                child: FutureBuilder<List<Product>>(
                  future: _saleFuture,
                  builder: (context, snap) {
                    if (snap.connectionState == ConnectionState.waiting) {
                      return const SizedBox(
                        height: 290,
                        child: Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFFDB3022),
                          ),
                        ),
                      );
                    }
                    if (snap.hasError || !snap.hasData || snap.data!.isEmpty) {
                      final msg = snap.hasError
                          ? snap.error.toString()
                          : 'Không có sản phẩm (API: ${ApiService.baseUrl})';
                      return SizedBox(
                        height: 290,
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Text(
                              msg,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Color(0xFF9B9B9B),
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                      );
                    }
                    return _buildHorizontalProductList(
                      snap.data!,
                      isSale: true,
                    );
                  },
                ),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
                  child: _buildSectionHeader(
                    'New',
                    "You've never seen it before!",
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: FutureBuilder<List<Product>>(
                  future: _newFuture,
                  builder: (context, snap) {
                    if (snap.connectionState == ConnectionState.waiting) {
                      return const SizedBox(
                        height: 290,
                        child: Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFFDB3022),
                          ),
                        ),
                      );
                    }
                    if (snap.hasError || !snap.hasData || snap.data!.isEmpty) {
                      final msg = snap.hasError
                          ? snap.error.toString()
                          : 'Không có sản phẩm (API: ${ApiService.baseUrl})';
                      return SizedBox(
                        height: 290,
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Text(
                              msg,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Color(0xFF9B9B9B),
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                      );
                    }
                    return _buildHorizontalProductList(
                      snap.data!,
                      isSale: false,
                    );
                  },
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 24)),
            ],
          ],
        ),
      ),
    );
  }

  // ───────────────────────── HERO BANNER ─────────────────────────
  Widget _buildHeroBanner() {
    return PageView.builder(
      controller: _bannerPageController,
      itemCount: _bannerImages.length,
      onPageChanged: (index) {
        setState(() => _currentBannerPage = index);
      },
      itemBuilder: (context, index) {
        if (index == 2) {
          return _buildPage3Layout();
        }

        final double screenHeight = MediaQuery.of(context).size.height;
        final double shortHeight = screenHeight * 0.35;

        return SizedBox(
          height: index == 0 ? null : shortHeight,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(
                _bannerImages[index],
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
                alignment: Alignment.topCenter,
                errorBuilder: (_, e, s) => Container(
                  color: Colors.grey[300],
                  child: const Icon(Icons.image_not_supported),
                ),
              ),
              IgnorePointer(
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.transparent,
                        Color(0x55000000),
                        Color(0xBB000000),
                      ],
                      stops: [0.0, 0.35, 0.65, 1.0],
                    ),
                  ),
                ),
              ),
              if (index == 0)
                Positioned(
                  bottom: 40,
                  left: 20,
                  right: 20,
                  child: Builder(
                    builder: (ctx) {
                      final t = _bannerPageOffset.clamp(0.0, 1.0);
                      final double fontSize = 48 - (48 - 28) * t;
                      final bool isHorizontal = t > 0.5;

                      final textWidget = IgnorePointer(
                        child: Text(
                          isHorizontal ? 'Fashion sale' : 'Fashion\nsale',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: fontSize,
                            fontWeight: FontWeight.bold,
                            height: 1.1,
                          ),
                        ),
                      );

                      if (isHorizontal) return textWidget;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          textWidget,
                          const SizedBox(height: 20),
                          SizedBox(
                            width: 130,
                            height: 44,
                            child: ElevatedButton(
                              onPressed: _onCheckPressed,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFDB3022),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(24),
                                ),
                                elevation: 0,
                              ),
                              child: const Text(
                                'Check',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              if (index == 1)
                const Positioned(
                  bottom: 24,
                  left: 20,
                  child: IgnorePointer(
                    child: Text(
                      'Street clothes',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              Positioned(
                bottom: 16,
                left: 0,
                right: 0,
                child: IgnorePointer(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(_bannerImages.length, (i) {
                      final isActive = i == _currentBannerPage;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: isActive ? 20 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: isActive
                              ? const Color(0xFFDB3022)
                              : Colors.white.withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      );
                    }),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ───────────────────────── PAGE 3 LAYOUT ─────────────────────────
  Widget _buildPage3Layout() {
    return SizedBox.expand(
      child: Column(
        children: [
          Expanded(
            flex: 48,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset(
                  'assets/images/anhchu2.jpg',
                  fit: BoxFit.cover,
                  alignment: Alignment.topCenter,
                  errorBuilder: (_, e, s) => Container(color: Colors.grey[300]),
                ),
                IgnorePointer(
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Color(0x88000000)],
                        stops: [0.5, 1.0],
                      ),
                    ),
                  ),
                ),
                const Positioned(
                  bottom: 20,
                  left: 0,
                  right: 0,
                  child: IgnorePointer(
                    child: Text(
                      'New collection',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 52,
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Expanded(
                        child: Container(
                          color: Colors.white,
                          padding: const EdgeInsets.all(16),
                          alignment: Alignment.centerLeft,
                          child: const Text(
                            'Summer\nsale',
                            style: TextStyle(
                              color: Color(0xFFDB3022),
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              height: 1.2,
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.asset(
                              'assets/images/anhchu2_2.jpg',
                              fit: BoxFit.cover,
                              errorBuilder: (_, e, s) =>
                                  Container(color: Colors.grey[800]),
                            ),
                            IgnorePointer(
                              child: Container(
                                decoration: const BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Colors.transparent,
                                      Color(0x99000000),
                                    ],
                                    stops: [0.4, 1.0],
                                  ),
                                ),
                              ),
                            ),
                            const Positioned(
                              bottom: 14,
                              left: 14,
                              child: IgnorePointer(
                                child: Text(
                                  'Black',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.asset(
                        'assets/images/anhchu2_1.jpg',
                        fit: BoxFit.cover,
                        errorBuilder: (_, e, s) =>
                            Container(color: Colors.grey[600]),
                      ),
                      IgnorePointer(
                        child: Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [Colors.transparent, Color(0x88000000)],
                              stops: [0.4, 1.0],
                            ),
                          ),
                        ),
                      ),
                      const Positioned(
                        bottom: 20,
                        left: 14,
                        right: 14,
                        child: IgnorePointer(
                          child: Text(
                            "Men's\nhoodies",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              height: 1.2,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ───────────────────────── SECTION HEADER ─────────────────────────
  Widget _buildSectionHeader(String title, String subtitle) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF222222),
              ),
            ),
            Text(
              subtitle,
              style: const TextStyle(fontSize: 13, color: Color(0xFF9B9B9B)),
            ),
          ],
        ),
        TextButton(
          onPressed: () {},
          child: const Text(
            'View all',
            style: TextStyle(fontSize: 14, color: Color(0xFF222222)),
          ),
        ),
      ],
    );
  }

  // ───────────────────────── PRODUCT LIST ─────────────────────────
  Widget _buildHorizontalProductList(
    List<Product> products, {
    required bool isSale,
  }) {
    return SizedBox(
      height: 290,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
        itemCount: products.length,
        itemBuilder: (context, index) =>
            _buildProductCard(products[index], isSale: isSale),
      ),
    );
  }

  // ───────────────────────── PRODUCT CARD ─────────────────────────
  Widget _buildProductCard(Product product, {required bool isSale}) {
    final hasDiscount =
        product.comparePrice != null &&
        product.comparePrice! > product.salePrice;

    final discountLabel = isSale
        ? (hasDiscount
              ? '-${((1 - product.salePrice / product.comparePrice!) * 100).round()}%'
              : 'SALE')
        : 'NEW';

    return GestureDetector(
      // MỚI
      onTap: () => navigateToProduct(context, _toModelProduct(product)),
      child: Container(
        width: 160,
        margin: const EdgeInsets.only(right: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 180,
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: _buildProductImage(product.image),
                  ),
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF222222),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        discountLabel,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: () => _toggleFavorite(product),
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          product.isFavorite
                              ? Icons.favorite
                              : Icons.favorite_border,
                          size: 18,
                          color: product.isFavorite
                              ? const Color(0xFFDB3022)
                              : const Color(0xFF9B9B9B),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            Text(
              product.shortDescription,
              style: const TextStyle(fontSize: 11, color: Color(0xFF9B9B9B)),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              product.productName,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF222222),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Row(
              children: [
                if (hasDiscount) ...[
                  Text(
                    '${product.comparePrice!.toStringAsFixed(0)}\$',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF9B9B9B),
                      decoration: TextDecoration.lineThrough,
                    ),
                  ),
                  const SizedBox(width: 6),
                ],
                Text(
                  '${product.salePrice.toStringAsFixed(0)}\$',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFDB3022),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── Tự động detect URL hay asset ────────────────────────────────
  Widget _buildProductImage(String? path) {
    if (path == null || path.isEmpty) return _imagePlaceholder();

    if (path.startsWith('http://') || path.startsWith('https://')) {
      return Image.network(
        path,
        width: 160,
        height: 180,
        fit: BoxFit.cover,
        loadingBuilder: (_, child, progress) => progress == null
            ? child
            : Container(
                width: 160,
                height: 180,
                color: const Color(0xFFF5F5F5),
                child: const Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFFDB3022),
                    strokeWidth: 2,
                  ),
                ),
              ),
        errorBuilder: (_, e, s) => _imagePlaceholder(),
      );
    }

    return Image.asset(
      path,
      width: 160,
      height: 180,
      fit: BoxFit.cover,
      errorBuilder: (_, e, s) => _imagePlaceholder(),
    );
  }

  Widget _imagePlaceholder() => Container(
    width: 160,
    height: 180,
    decoration: BoxDecoration(
      color: const Color(0xFFEEEEEE),
      borderRadius: BorderRadius.circular(8),
    ),
    child: const Icon(Icons.image_not_supported, color: Color(0xFF9B9B9B)),
  );

  // ───────────────────────── PLACEHOLDER TABS ─────────────────────────
  Widget _buildPlaceholderTab() {
    const labels = ['Shop', 'Bag', 'Favorites', 'Profile'];
    return Center(
      child: Text(
        labels[_selectedIndex - 1],
        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      ),
    );
  }

  // ───────────────────────── BOTTOM NAV ─────────────────────────
  Widget _buildBottomNav() {
    return AppBottomNav(
      currentIndex: _selectedIndex,
      onTap: (i) {
        if (i == 3) {
          Navigator.pushNamed(context, '/favorites');
          return;
        }
        if (i != 1) setState(() => _selectedIndex = i);
      },
    );
  }
}
