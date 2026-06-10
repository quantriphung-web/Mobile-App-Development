import 'package:flutter/material.dart';
import 'package:backend/screens/product_model.dart';
import 'package:backend/screens/filter_screen.dart';
import 'package:backend/screens/api_service.dart';
import 'package:backend/screens/search_screen.dart';
import 'package:backend/screens/productdetailscreen.dart';
import 'package:backend/screens/connection_helper.dart';
import 'package:backend/screens/app_bottom_nav.dart';
import 'package:backend/services/favorites_service.dart';

enum ViewMode { list, grid }

class ProductListScreen extends StatefulWidget {
  final String category;
  final String? categoryId;

  const ProductListScreen({super.key, required this.category, this.categoryId});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  ViewMode _viewMode = ViewMode.list;
  List<Product> _products = [];
  bool _isLoading = true;
  String? _error;
  String _sortLabel = 'Newest';
  String _sortKey = 'newest';

  final List<String> _subcategories = [
    'T-shirts',
    'Crop tops',
    'Sleeveless',
    'Blouses',
    'Shirts',
  ];
  int _selectedSubcat = 0;

  @override
  void initState() {
    super.initState();
    FavoritesService.instance.addListener(_onFavoritesChanged);
    _loadProducts();
  }

  @override
  void dispose() {
    FavoritesService.instance.removeListener(_onFavoritesChanged);
    super.dispose();
  }

  void _onFavoritesChanged() {
    if (!mounted || _products.isEmpty) return;
    FavoritesService.instance.applyToProducts(
      _products,
      (p) => p.id,
      (p, liked) => p.isWishlisted = liked,
    );
    setState(() {});
  }

  Future<void> _toggleWishlist(int index) async {
    final product = _products[index];
    final result = await FavoritesService.instance.toggle(product.id);
    if (result == null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please login to save favorites')),
      );
      return;
    }
    if (mounted) {
      setState(() => product.isWishlisted = result ?? product.isWishlisted);
    }
  }

  void _openProductDetail(Product product) {
    navigateToProduct(context, product);
  }

  Future<void> _loadProducts() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      await FavoritesService.instance.refresh();
      final products = await ApiService.getProducts(
        categoryId: widget.categoryId,
        sort: _sortKey,
      );
      FavoritesService.instance.applyToProducts(
        products,
        (p) => p.id,
        (p, liked) => p.isWishlisted = liked,
      );
      setState(() {
        _products = products;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  String get _displayTitle {
    if (widget.category == 'All Items' || widget.category == 'Tops') {
      return "Women's tops";
    }
    final c = widget.category;
    return c.isNotEmpty ? c[0].toUpperCase() + c.substring(1) : c;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),
      appBar: _buildAppBar(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_viewMode == ViewMode.list) _buildLargeTitle(),
          _buildSubcategoryRow(),
          _buildFilterBar(),
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Color(0xFFDB3022)),
                  )
                : _error != null
                ? _buildErrorState()
                : _products.isEmpty
                ? _buildEmptyState()
                : RefreshIndicator(
                    color: const Color(0xFFDB3022),
                    onRefresh: _loadProducts,
                    child: _viewMode == ViewMode.list
                        ? _buildListView()
                        : _buildGridView(),
                  ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // ── AppBar ───────────────────────────────────────────────────────────────────

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: IconButton(
        icon: const Icon(
          Icons.arrow_back_ios,
          color: Color(0xFF222222),
          size: 20,
        ),
        onPressed: () => Navigator.pop(context),
      ),
      title: _viewMode == ViewMode.grid
          ? Text(
              _displayTitle,
              style: const TextStyle(
                color: Color(0xFF222222),
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
            )
          : null,
      centerTitle: true,
      actions: [
        IconButton(
          icon: const Icon(Icons.search, color: Color(0xFF222222), size: 24),
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const SearchScreen()),
          ),
        ),
      ],
    );
  }

  // ── Large Title (list mode only) ─────────────────────────────────────────────

  Widget _buildLargeTitle() {
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 14),
      child: Text(
        _displayTitle,
        style: const TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w800,
          color: Color(0xFF222222),
          height: 1.15,
        ),
      ),
    );
  }

  // ── Subcategory chips ────────────────────────────────────────────────────────

  Widget _buildSubcategoryRow() {
    return Container(
      color: Colors.white,
      height: 56,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: _subcategories.length,
        itemBuilder: (_, i) {
          final selected = i == _selectedSubcat;
          final isDark = _viewMode == ViewMode.grid ? true : selected;
          return GestureDetector(
            onTap: () => setState(() => _selectedSubcat = i),
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 7),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF222222)
                    : const Color(0xFFF2F2F2),
                borderRadius: BorderRadius.circular(24),
              ),
              alignment: Alignment.center,
              child: Text(
                _subcategories[i],
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  color: isDark ? Colors.white : const Color(0xFF222222),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ── Filter bar ───────────────────────────────────────────────────────────────

  Widget _buildFilterBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFF0F0F0), width: 1)),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const FilterScreen()),
            ),
            child: Row(
              children: const [
                Icon(Icons.tune, size: 18, color: Color(0xFF222222)),
                SizedBox(width: 6),
                Text(
                  'Filters',
                  style: TextStyle(fontSize: 14, color: Color(0xFF222222)),
                ),
              ],
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: _showSortModal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.swap_vert,
                    size: 18,
                    color: Color(0xFF222222),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _sortLabel,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF222222),
                    ),
                  ),
                ],
              ),
            ),
          ),
          GestureDetector(
            onTap: () => setState(() {
              _viewMode = _viewMode == ViewMode.list
                  ? ViewMode.grid
                  : ViewMode.list;
            }),
            child: Icon(
              _viewMode == ViewMode.list ? Icons.grid_view : Icons.view_list,
              size: 22,
              color: const Color(0xFF222222),
            ),
          ),
        ],
      ),
    );
  }

  void _sortProducts(String option) {
    final map = {
      'Popular': 'popular',
      'Newest': 'newest',
      'Customer review': 'rating',
      'Price: lowest to high': 'price_asc',
      'Price: highest to low': 'price_desc',
    };
    setState(() {
      _sortLabel = option;
      _sortKey = map[option] ?? 'newest';
    });
    _loadProducts();
  }

  void _showSortModal() {
    final options = [
      'Popular',
      'Newest',
      'Customer review',
      'Price: lowest to high',
      'Price: highest to low',
    ];
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 8),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFFE0E0E0),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Sort by',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          ...options.map((opt) {
            final sel = opt == _sortLabel;
            return InkWell(
              onTap: () {
                _sortProducts(opt);
                Navigator.pop(context);
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 18,
                ),
                color: sel ? const Color(0xFFDB3022) : Colors.white,
                child: Text(
                  opt,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: sel ? FontWeight.w600 : FontWeight.w400,
                    color: sel ? Colors.white : const Color(0xFF222222),
                  ),
                ),
              ),
            );
          }),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  // ── Error State ──────────────────────────────────────────────────────────────

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.wifi_off, size: 48, color: Color(0xFFCCCCCC)),
          const SizedBox(height: 12),
          const Text(
            'Không thể tải dữ liệu',
            style: TextStyle(fontSize: 15, color: Color(0xFF9B9B9B)),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: _loadProducts,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDB3022),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: const Text('Thử lại'),
          ),
        ],
      ),
    );
  }

  // ── Empty State ──────────────────────────────────────────────────────────────

  Widget _buildEmptyState() {
    // ✅ Wrap bằng scroll view để RefreshIndicator hoạt động khi không có sản phẩm
    return RefreshIndicator(
      color: const Color(0xFFDB3022),
      onRefresh: _loadProducts,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.5,
          child: const Center(
            child: Text(
              'Không có sản phẩm',
              style: TextStyle(color: Color(0xFF9B9B9B)),
            ),
          ),
        ),
      ),
    );
  }

  // ── List View ────────────────────────────────────────────────────────────────

  Widget _buildListView() {
    return ListView.builder(
      // ✅ Bắt buộc để RefreshIndicator hoạt động kể cả khi ít item
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: _products.length,
      itemBuilder: (_, i) => _buildListCard(i),
    );
  }

  Widget _buildListCard(int index) {
    final p = _products[index];
    return GestureDetector(
      onTap: () => _openProductDetail(p),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0D000000),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        clipBehavior: Clip.hardEdge,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 130,
              height: 170,
              child: _buildProductImage(p.imagePath, 40),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 16, 12, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      p.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF222222),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      p.brand,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF9B9B9B),
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildStarRow(p.rating, p.reviewCount, size: 14),
                    const SizedBox(height: 10),
                    _buildPriceWidget(p, isGrid: false),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 12, right: 12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const SizedBox(height: 110),
                  _buildWishlistButton(index, size: 34),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Grid View ────────────────────────────────────────────────────────────────

  Widget _buildGridView() {
    return GridView.builder(
      // ✅ Bắt buộc để RefreshIndicator hoạt động kể cả khi ít item
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.58,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: _products.length,
      itemBuilder: (_, i) => _buildGridCard(i),
    );
  }

  Widget _buildGridCard(int index) {
    final p = _products[index];
    return GestureDetector(
      onTap: () => _openProductDetail(p),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
        clipBehavior: Clip.hardEdge,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  SizedBox.expand(child: _buildProductImage(p.imagePath, 48)),
                  if (p.hasDiscount)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFDB3022),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '-${p.discountPercent}%',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: _buildWishlistButton(index, size: 32),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStarRow(p.rating, p.reviewCount, size: 12),
                  const SizedBox(height: 3),
                  Text(
                    p.brand,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF9B9B9B),
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    p.name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF222222),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 5),
                  _buildPriceWidget(p, isGrid: true),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Shared Widgets ───────────────────────────────────────────────────────────

  Widget _buildProductImage(String? path, double iconSize) {
    if (path == null || path.isEmpty) return _imagePlaceholder(iconSize);
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return Image.network(
        path,
        fit: BoxFit.cover,
        loadingBuilder: (_, child, progress) => progress == null
            ? child
            : Container(
                color: const Color(0xFFF5F5F5),
                child: const Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFFDB3022),
                    strokeWidth: 2,
                  ),
                ),
              ),
        errorBuilder: (_, e, s) => _imagePlaceholder(iconSize),
      );
    }
    return Image.asset(
      path,
      fit: BoxFit.cover,
      errorBuilder: (_, e, s) => _imagePlaceholder(iconSize),
    );
  }

  Widget _imagePlaceholder(double iconSize) {
    return Container(
      color: const Color(0xFFEEEEEE),
      child: Icon(
        Icons.checkroom,
        color: const Color(0xFFBBBBBB),
        size: iconSize,
      ),
    );
  }

  Widget _buildStarRow(double rating, int count, {double size = 14}) {
    return Row(
      children: [
        ...List.generate(5, (i) {
          final filled = i < rating.floor();
          final half = !filled && i < rating.ceil() && rating % 1 >= 0.5;
          return Icon(
            filled || half ? Icons.star : Icons.star_border,
            size: size,
            color: const Color(0xFFF5A623),
          );
        }),
        const SizedBox(width: 4),
        Text(
          '($count)',
          style: TextStyle(fontSize: size - 2, color: const Color(0xFF9B9B9B)),
        ),
      ],
    );
  }

  Widget _buildPriceWidget(Product p, {required bool isGrid}) {
    if (p.hasDiscount) {
      return Row(
        children: [
          Text(
            '${p.originalPrice!.toInt()}\$',
            style: TextStyle(
              fontSize: isGrid ? 12 : 14,
              color: const Color(0xFF9B9B9B),
              decoration: TextDecoration.lineThrough,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            '${p.price.toInt()}\$',
            style: TextStyle(
              fontSize: isGrid ? 14 : 16,
              fontWeight: FontWeight.w700,
              color: const Color(0xFFDB3022),
            ),
          ),
        ],
      );
    }
    return Text(
      '${p.price.toInt()}\$',
      style: TextStyle(
        fontSize: isGrid ? 14 : 16,
        fontWeight: FontWeight.w700,
        color: const Color(0xFF222222),
      ),
    );
  }

  Widget _buildWishlistButton(int index, {double size = 32}) {
    final liked = _products[index].isWishlisted;
    return GestureDetector(
      onTap: () => _toggleWishlist(index),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: const [
            BoxShadow(
              color: Color(0x1A000000),
              blurRadius: 4,
              offset: Offset(0, 1),
            ),
          ],
        ),
        child: Icon(
          liked ? Icons.favorite : Icons.favorite_border,
          size: size * 0.55,
          color: liked ? const Color(0xFFDB3022) : const Color(0xFFCCCCCC),
        ),
      ),
    );
  }

  // ── Bottom Nav ───────────────────────────────────────────────────────────────

  Widget _buildBottomNav() {
    return const AppBottomNav(currentIndex: 1);
  }
}
