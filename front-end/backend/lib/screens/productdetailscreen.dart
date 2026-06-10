import 'package:flutter/material.dart';
import 'package:backend/screens/product_model.dart';
import 'package:backend/screens/api_service.dart';
import 'package:backend/services/favorites_service.dart';
import 'package:backend/screens/ratings_screen.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  String? selectedSize;
  String selectedColor = 'Black';
  bool isFavorite = false;
  int _pageIndex = 0;
  late PageController _pageController;

  final List<String> sizes = ['XS', 'S', 'M', 'L', 'XL'];

  late Future<List<Product>> _relatedFuture;
  late Future<Map<String, dynamic>> _shippingFuture;
  late Future<Map<String, dynamic>> _supportFuture;
  late Future<List<Map<String, dynamic>>> _reviewsFuture;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    isFavorite = FavoritesService.instance.isFavorite(widget.product.id);
    FavoritesService.instance.addListener(_onFavoritesChanged);
    _relatedFuture = ApiService.getRelatedProducts(widget.product.id);
    _shippingFuture = ApiService.getProductShipping(widget.product.id);
    _supportFuture = ApiService.getProductSupport(widget.product.id);
    _reviewsFuture = ApiService.getProductReviews(widget.product.id);
  }

  @override
  void dispose() {
    FavoritesService.instance.removeListener(_onFavoritesChanged);
    _pageController.dispose();
    super.dispose();
  }

  void _onFavoritesChanged() {
    if (!mounted) return;
    setState(() {
      isFavorite = FavoritesService.instance.isFavorite(widget.product.id);
    });
  }

  Future<void> _toggleFavorite() async {
    final result =
        await FavoritesService.instance.toggle(widget.product.id);
    if (result == null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please login to save favorites')),
      );
      return;
    }
    if (mounted) {
      setState(() {
        isFavorite = result ?? isFavorite;
        widget.product.isWishlisted = isFavorite;
      });
    }
  }

  Future<void> _openRatingsScreen({
    List<Map<String, dynamic>>? prefetchedReviews,
  }) async {
    final reviews = prefetchedReviews ?? await _reviewsFuture;
    if (!mounted) return;

    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => RatingsScreen(
          product: widget.product,
          reviews: reviews,
        ),
      ),
    );

    if (changed == true && mounted) {
      setState(() {
        _reviewsFuture = ApiService.getProductReviews(widget.product.id);
      });
    }
  }

  void _openSizeSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _SizeBottomSheet(
        sizes: sizes,
        selectedSize: selectedSize,
        onSelect: (size) {
          setState(() => selectedSize = size);
          Navigator.pop(context);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            pinned: true,
            leading: const BackButton(color: Colors.black),
            title: Text(
              widget.product.name,
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w600,
                fontSize: 17,
              ),
            ),
            centerTitle: true,
            actions: [
              IconButton(
                icon: const Icon(Icons.share_outlined, color: Colors.black),
                onPressed: () {},
              ),
            ],
          ),

          SliverToBoxAdapter(
            child: Column(
              children: [
                SizedBox(
                  height: 380,
                  child: Builder(
                    builder: (context) {
                      final imgs = widget.product.images.isNotEmpty
                          ? widget.product.images
                          : (widget.product.imagePath != null
                                ? [widget.product.imagePath!]
                                : <String>[]);

                      if (imgs.isEmpty) {
                        return _ProductImagePlaceholder(
                          color: const Color(0xFFF5F5F5),
                        );
                      }

                      return PageView.builder(
                        controller: _pageController,
                        itemCount: imgs.length,
                        onPageChanged: (i) => setState(() => _pageIndex = i),
                        itemBuilder: (_, i) => _buildProductImage(imgs[i]),
                      );
                    },
                  ),
                ),
                Builder(
                  builder: (context) {
                    final count = widget.product.images.isNotEmpty
                        ? widget.product.images.length
                        : (widget.product.imagePath != null ? 1 : 0);
                    if (count <= 1) return const SizedBox(height: 8);
                    return Padding(
                      padding: const EdgeInsets.only(top: 10, bottom: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(count, (i) {
                          final active = i == _pageIndex;
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            margin: const EdgeInsets.symmetric(horizontal: 3),
                            width: active ? 20 : 7,
                            height: 7,
                            decoration: BoxDecoration(
                              color: active
                                  ? const Color(0xFFE53935)
                                  : const Color(0xFFDDDDDD),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          );
                        }),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: _openSizeSheet,
                      child: _FilterChip(
                        label: selectedSize ?? 'Size',
                        hasValue: selectedSize != null,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _FilterChip(label: selectedColor, hasValue: true),
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: _toggleFavorite,
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xFFE0E0E0)),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: isFavorite
                            ? const Color(0xFFE53935)
                            : Colors.grey,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        widget.product.brand,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.5,
                        ),
                      ),
                      Text(
                        '\$${widget.product.price.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    widget.product.name,
                    style: const TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () => _openRatingsScreen(),
                    child: Row(
                      children: [
                        ...List.generate(
                          5,
                          (i) => Icon(
                            i < widget.product.rating.floor()
                                ? Icons.star
                                : (i < widget.product.rating.ceil() &&
                                      widget.product.rating % 1 >= 0.5)
                                ? Icons.star_half
                                : Icons.star_border,
                            color: const Color(0xFFFFC107),
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '(${widget.product.reviewCount})',
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '${widget.product.brand} · ${widget.product.name}',
                    style: const TextStyle(
                      color: Colors.black87,
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  FutureBuilder<List<Map<String, dynamic>>>(
                    future: _reviewsFuture,
                    builder: (_, snap) {
                      final reviews = snap.data ?? [];
                      if (reviews.isEmpty) return const SizedBox.shrink();
                      final avg =
                          reviews.fold<double>(
                            0,
                            (s, r) => s + (r['rating'] as num).toDouble(),
                          ) /
                          reviews.length;
                      return GestureDetector(
                        onTap: () => _openRatingsScreen(prefetchedReviews: reviews),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF8E1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: const Color(0xFFFFCC02),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.star,
                                color: Color(0xFFFFC107),
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                avg.toStringAsFixed(1),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '(${reviews.length} reviews)',
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(
                                Icons.chevron_right,
                                size: 16,
                                color: Colors.grey,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE53935),
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'ADD TO CART',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ),
          ),

          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Divider(thickness: 3, color: Colors.black),
            ),
          ),

          SliverToBoxAdapter(
            child: Column(
              children: [
                FutureBuilder<Map<String, dynamic>>(
                  future: _shippingFuture,
                  builder: (ctx, snap) {
                    final data = snap.data;
                    return _ExpandableInfoTile(
                      icon: Icons.local_shipping_outlined,
                      title: 'Shipping info',
                      subtitle: data != null
                          ? '${data['estimated_days']} business days · ${data['carrier']}'
                          : 'Loading...',
                      onTap: data == null
                          ? null
                          : () => _showShippingSheet(data),
                    );
                  },
                ),
                FutureBuilder<Map<String, dynamic>>(
                  future: _supportFuture,
                  builder: (ctx, snap) {
                    final data = snap.data;
                    return _ExpandableInfoTile(
                      icon: Icons.headset_mic_outlined,
                      title: 'Support',
                      subtitle: data != null
                          ? data['hours'] as String
                          : 'Loading...',
                      onTap: data == null
                          ? null
                          : () => _showSupportSheet(data),
                    );
                  },
                ),
              ],
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
              child: FutureBuilder<List<Product>>(
                future: _relatedFuture,
                builder: (_, snap) {
                  final count = snap.data?.length ?? 0;
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'You can also like this',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        count > 0 ? '$count items' : '',
                        style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: SizedBox(
              height: 220,
              child: FutureBuilder<List<Product>>(
                future: _relatedFuture,
                builder: (_, snap) {
                  if (snap.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFFE53935),
                        strokeWidth: 2,
                      ),
                    );
                  }
                  if (!snap.hasData || snap.data!.isEmpty) {
                    return const Center(
                      child: Text(
                        'Không có sản phẩm liên quan',
                        style: TextStyle(color: Colors.grey),
                      ),
                    );
                  }
                  return ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemCount: snap.data!.length,
                    itemBuilder: (_, i) =>
                        _RelatedProductCard(product: snap.data![i]),
                  );
                },
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      ),
    );
  }

  Widget _buildProductImage(String? path) {
    if (path == null || path.isEmpty) {
      return _ProductImagePlaceholder(color: const Color(0xFFF5F5F5));
    }
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
                    color: Color(0xFFE53935),
                    strokeWidth: 2,
                  ),
                ),
              ),
        errorBuilder: (_, e, s) =>
            _ProductImagePlaceholder(color: const Color(0xFFF5F5F5)),
      );
    }
    return Image.asset(
      path,
      fit: BoxFit.cover,
      errorBuilder: (_, e, s) =>
          _ProductImagePlaceholder(color: const Color(0xFFF5F5F5)),
    );
  }

  void _showShippingSheet(Map<String, dynamic> data) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ShippingBottomSheet(data: data),
    );
  }

  void _showSupportSheet(Map<String, dynamic> data) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _SupportBottomSheet(data: data),
    );
  }
}

// ─────────────────────────────────────────────
// Related Product Card
// ─────────────────────────────────────────────
class _RelatedProductCard extends StatefulWidget {
  final Product product;
  const _RelatedProductCard({required this.product});

  @override
  State<_RelatedProductCard> createState() => _RelatedProductCardState();
}

class _RelatedProductCardState extends State<_RelatedProductCard> {
  @override
  void initState() {
    super.initState();
    FavoritesService.instance.addListener(_onFavoritesChanged);
  }

  @override
  void dispose() {
    FavoritesService.instance.removeListener(_onFavoritesChanged);
    super.dispose();
  }

  bool get _liked =>
      FavoritesService.instance.isFavorite(widget.product.id);

  void _onFavoritesChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _toggleLike() async {
    final result =
        await FavoritesService.instance.toggle(widget.product.id);
    if (result == null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please login to save favorites')),
      );
      return;
    }
    if (mounted) {
      setState(() => widget.product.isWishlisted = result ?? _liked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.product;
    final hasDiscount = p.hasDiscount;

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => ProductDetailScreen(product: p)),
      ),
      child: Container(
        width: 140,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: SizedBox(
                    width: 140,
                    height: 140,
                    child: _buildImage(p.imagePath),
                  ),
                ),
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: hasDiscount
                          ? const Color(0xFFE53935)
                          : Colors.black,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      hasDiscount ? '-${p.computedDiscount}%' : 'NEW',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: _toggleLike,
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _liked ? Icons.favorite : Icons.favorite_border,
                        size: 14,
                        color: _liked ? const Color(0xFFE53935) : Colors.grey,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: List.generate(5, (i) {
                return Icon(
                  i < p.rating.floor() ? Icons.star : Icons.star_border,
                  size: 12,
                  color: i < p.rating.floor()
                      ? const Color(0xFFFFC107)
                      : Colors.grey[300],
                );
              }),
            ),
            const SizedBox(height: 2),
            Text(
              p.brand,
              style: const TextStyle(color: Colors.grey, fontSize: 11),
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              p.name,
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
              overflow: TextOverflow.ellipsis,
            ),
            Row(
              children: [
                if (hasDiscount) ...[
                  Text(
                    '${p.originalPrice!.toInt()}\$',
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                      decoration: TextDecoration.lineThrough,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${p.price.toInt()}\$',
                    style: const TextStyle(
                      color: Color(0xFFE53935),
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ] else
                  Text(
                    '${p.price.toInt()}\$',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImage(String? path) {
    if (path == null || path.isEmpty) {
      return _ProductImagePlaceholder(color: const Color(0xFFEEEEEE));
    }
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return Image.network(
        path,
        fit: BoxFit.cover,
        errorBuilder: (_, e, s) =>
            _ProductImagePlaceholder(color: const Color(0xFFEEEEEE)),
      );
    }
    return Image.asset(
      path,
      fit: BoxFit.cover,
      errorBuilder: (_, e, s) =>
          _ProductImagePlaceholder(color: const Color(0xFFEEEEEE)),
    );
  }
}

// ─────────────────────────────────────────────
// Shared Widgets
// ─────────────────────────────────────────────
class _ProductImagePlaceholder extends StatelessWidget {
  final Color color;
  const _ProductImagePlaceholder({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: color,
      child: const Center(
        child: Icon(Icons.checkroom_outlined, size: 80, color: Colors.black26),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool hasValue;
  const _FilterChip({required this.label, required this.hasValue});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFE0E0E0)),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: hasValue ? Colors.black : Colors.grey,
            ),
          ),
          const Icon(Icons.keyboard_arrow_down, size: 18, color: Colors.grey),
        ],
      ),
    );
  }
}

class _ExpandableInfoTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  const _ExpandableInfoTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 2,
          ),
          leading: Icon(icon, color: Colors.black87, size: 22),
          title: Text(
            title,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          ),
          subtitle: Text(
            subtitle,
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
          trailing: const Icon(Icons.chevron_right),
          onTap: onTap,
        ),
        const Divider(height: 1, indent: 16, endIndent: 16),
      ],
    );
  }
}

// Shipping Bottom Sheet
// ─────────────────────────────────────────────
class _ShippingBottomSheet extends StatelessWidget {
  final Map<String, dynamic> data;
  const _ShippingBottomSheet({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Row(
            children: [
              Icon(Icons.local_shipping_outlined, size: 26),
              SizedBox(width: 10),
              Text(
                'Shipping Information',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _ShipRow(
            icon: Icons.schedule_outlined,
            label: 'Estimated delivery',
            value: '${data['estimated_days']} business days',
          ),
          _ShipRow(
            icon: Icons.local_post_office_outlined,
            label: 'Carrier',
            value: '${data['carrier']}',
          ),
          _ShipRow(
            icon: Icons.local_offer_outlined,
            label: 'Free shipping on orders over',
            value: '\$${data['free_threshold']}',
          ),
          _ShipRow(
            icon: Icons.replay_outlined,
            label: 'Free returns',
            value: 'Within ${data['return_days']} days',
          ),
          if ((data['note'] ?? '').toString().isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.info_outline, size: 16, color: Colors.grey),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      data['note'].toString(),
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.black87,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Got it',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ShipRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _ShipRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: const Color(0xFFE53935)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Support Bottom Sheet
// ─────────────────────────────────────────────
class _SupportBottomSheet extends StatelessWidget {
  final Map<String, dynamic> data;
  const _SupportBottomSheet({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Row(
            children: [
              Icon(Icons.headset_mic_outlined, size: 26),
              SizedBox(width: 10),
              Text(
                'Customer Support',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _SupportCard(
            icon: Icons.email_outlined,
            label: 'Email',
            value: '${data['contact_email']}',
          ),
          _SupportCard(
            icon: Icons.phone_outlined,
            label: 'Phone',
            value: '${data['phone']}',
          ),
          _SupportCard(
            icon: Icons.access_time_outlined,
            label: 'Hours',
            value: '${data['hours']}',
          ),
          if ((data['faq'] ?? '').toString().isNotEmpty) ...[
            const SizedBox(height: 12),
            const Text(
              'Care & FAQ',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                data['faq'].toString(),
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.black87,
                  height: 1.5,
                ),
              ),
            ),
          ],
          if ((data['warranty'] ?? '').toString().isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFF81C784)),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.verified_outlined,
                    color: Color(0xFF388E3C),
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      data['warranty'].toString(),
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF2E7D32),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Close',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SupportCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _SupportCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFFEEEEEE),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 18, color: Colors.black87),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// SIZE BOTTOM SHEET
// ─────────────────────────────────────────────
class _SizeBottomSheet extends StatefulWidget {
  final List<String> sizes;
  final String? selectedSize;
  final ValueChanged<String> onSelect;

  const _SizeBottomSheet({
    required this.sizes,
    required this.selectedSize,
    required this.onSelect,
  });

  @override
  State<_SizeBottomSheet> createState() => _SizeBottomSheetState();
}

class _SizeBottomSheetState extends State<_SizeBottomSheet> {
  String? _local;

  @override
  void initState() {
    super.initState();
    _local = widget.selectedSize;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Select size',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: widget.sizes.map((size) {
              final isSelected = _local == size;
              return GestureDetector(
                onTap: () {
                  setState(() => _local = size);
                  widget.onSelect(size);
                },
                child: Container(
                  width: (MediaQuery.of(context).size.width - 64) / 3,
                  height: 52,
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.black : Colors.white,
                    border: Border.all(
                      color: isSelected
                          ? Colors.black
                          : const Color(0xFFDDDDDD),
                      width: isSelected ? 2 : 1,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      size,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.black,
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          const Divider(),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text(
              'Size info',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
          const SizedBox(height: 4),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE53935),
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(52),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 0,
              ),
              child: const Text(
                'ADD TO CART',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
