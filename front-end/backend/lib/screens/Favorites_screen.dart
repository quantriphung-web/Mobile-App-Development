import 'package:flutter/material.dart';
import 'package:backend/screens/app_bottom_nav.dart';
import 'package:backend/screens/search_screen.dart';
import 'package:backend/screens/product_model.dart';
import 'package:backend/screens/connection_helper.dart';
import 'package:backend/services/favorites_service.dart';
import 'package:backend/screens/api_service.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final List<String> _chips = [
    'Summer',
    'T-Shirts',
    'Shirts',
    'Dresses',
    'Jeans',
  ];

  List<Product> _items = [];
  bool _isLoading = true;
  bool _isLoggedIn = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    FavoritesService.instance.addListener(_onFavoritesChanged);
    _loadFavorites();
  }

  @override
  void dispose() {
    FavoritesService.instance.removeListener(_onFavoritesChanged);
    super.dispose();
  }

  void _onFavoritesChanged() {
    if (!mounted) return;
    _loadFavorites(showLoading: false);
  }

  Future<void> _loadFavorites({bool showLoading = true}) async {
    if (showLoading) {
      setState(() {
        _isLoading = true;
        _error = null;
      });
    }

    final loggedIn = await ApiService.hasAuthToken();
    if (!loggedIn) {
      setState(() {
        _isLoggedIn = false;
        _items = [];
        _isLoading = false;
      });
      return;
    }

    try {
      final products = await FavoritesService.instance.loadFavoriteProducts();
      if (!mounted) return;
      setState(() {
        _isLoggedIn = true;
        _items = products;
        _isLoading = false;
        _error = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoggedIn = true;
        _isLoading = false;
        _error = e.toString();
      });
    }
  }

  Future<void> _removeItem(Product product) async {
    final ok = await FavoritesService.instance.remove(product.id);
    if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not remove favorite. Try again.')),
      );
      return;
    }
    setState(() => _items.removeWhere((e) => e.id == product.id));
  }

  void _addToBag(Product product) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${product.name} added to bag'),
        duration: const Duration(seconds: 2),
        backgroundColor: const Color(0xFF222222),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTopBar(),
            _buildFilterRow(),
            const Divider(height: 1, color: Color(0xFFF0F0F0)),
            Expanded(child: _buildBody()),
          ],
        ),
      ),
      bottomNavigationBar: AppBottomNav(currentIndex: 3),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFFDB3022)),
      );
    }

    if (!_isLoggedIn) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.favorite_border, size: 56, color: Colors.grey[300]),
            const SizedBox(height: 12),
            const Text(
              'Please login to see your favorites',
              style: TextStyle(fontSize: 15, color: Color(0xFF9B9B9B)),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () =>
                  Navigator.pushReplacementNamed(context, '/login'),
              child: const Text('Go to Login'),
            ),
          ],
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_error!, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            TextButton(onPressed: _loadFavorites, child: const Text('Retry')),
          ],
        ),
      );
    }

    return _buildList();
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: IconButton(
              padding: const EdgeInsets.only(top: 8, bottom: 4),
              constraints: const BoxConstraints(),
              icon: const Icon(
                Icons.search,
                color: Color(0xFF111111),
                size: 24,
              ),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SearchScreen()),
              ),
            ),
          ),
          const Text(
            'Favorites',
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w700,
              color: Color(0xFF111111),
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 38,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _chips.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) => _buildChip(_chips[i]),
            ),
          ),
          const SizedBox(height: 14),
        ],
      ),
    );
  }

  Widget _buildChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 9),
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildFilterRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {},
            child: const Row(
              children: [
                Icon(Icons.tune, size: 18, color: Color(0xFF444444)),
                SizedBox(width: 5),
                Text(
                  'Filters',
                  style: TextStyle(fontSize: 13, color: Color(0xFF444444)),
                ),
              ],
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () {},
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.swap_vert, size: 16, color: Color(0xFF444444)),
                  SizedBox(width: 4),
                  Text(
                    'Price: lowest to high',
                    style: TextStyle(fontSize: 13, color: Color(0xFF444444)),
                  ),
                ],
              ),
            ),
          ),
          GestureDetector(
            onTap: () {},
            child: const Icon(
              Icons.grid_view,
              size: 20,
              color: Color(0xFF444444),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildList() {
    if (_items.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.favorite_border, size: 56, color: Color(0xFFCCCCCC)),
            SizedBox(height: 12),
            Text(
              'No favorites yet',
              style: TextStyle(fontSize: 15, color: Color(0xFF9B9B9B)),
            ),
            SizedBox(height: 6),
            Text(
              'Tap the heart on a product to save it here',
              style: TextStyle(fontSize: 13, color: Color(0xFFBBBBBB)),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadFavorites,
      color: const Color(0xFFDB3022),
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: _items.length,
        separatorBuilder: (_, __) =>
            const Divider(height: 1, color: Color(0xFFF5F5F5)),
        itemBuilder: (_, i) => _buildItem(_items[i]),
      ),
    );
  }

  Widget _buildItem(Product item) {
    final imageUrl = item.imagePath;
    final badge = item.computedDiscount > 0 ? '-${item.computedDiscount}%' : null;

    return GestureDetector(
      onTap: () => navigateToProduct(context, item),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: imageUrl != null && imageUrl.isNotEmpty
                      ? Image.network(
                          imageUrl,
                          width: 112,
                          height: 112,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _imagePlaceholder(),
                        )
                      : _imagePlaceholder(),
                ),
                if (badge != null) _buildBadge(badge),
              ],
            ),
            const SizedBox(width: 14),
            Expanded(
              child: SizedBox(
                height: 112,
                child: Stack(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.brand,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF9B9B9B),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              item.name,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF111111),
                                height: 1.2,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  '\$${item.price.toStringAsFixed(0)}',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF111111),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                _buildStars(item.rating),
                                const SizedBox(width: 3),
                                Text(
                                  '(${item.reviewCount})',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF9B9B9B),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                    Positioned(
                      top: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: () => _removeItem(item),
                        child: const Icon(
                          Icons.close,
                          size: 16,
                          color: Color(0xFFCCCCCC),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: () => _addToBag(item),
                        child: Container(
                          width: 38,
                          height: 38,
                          decoration: const BoxDecoration(
                            color: Color(0xFFDB3022),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.shopping_bag_outlined,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _imagePlaceholder() {
    return Container(
      width: 112,
      height: 112,
      color: const Color(0xFFEEEEEE),
      child: const Icon(
        Icons.checkroom_outlined,
        size: 40,
        color: Color(0xFFBBBBBB),
      ),
    );
  }

  Widget _buildBadge(String text) {
    final bool isSale = text.startsWith('-');
    return Positioned(
      top: 8,
      left: 8,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: isSale ? const Color(0xFFDB3022) : const Color(0xFF111111),
          borderRadius: BorderRadius.circular(isSale ? 20 : 4),
        ),
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.3,
          ),
        ),
      ),
    );
  }

  Widget _buildStars(double rating) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        final filled = i < rating.floor();
        final half = !filled && i < rating;
        return Icon(
          half ? Icons.star_half : (filled ? Icons.star : Icons.star_border),
          size: 13,
          color: (filled || half)
              ? const Color(0xFFF5A623)
              : const Color(0xFFDDDDDD),
        );
      }),
    );
  }
}
