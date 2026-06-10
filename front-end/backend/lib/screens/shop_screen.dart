import 'package:flutter/material.dart';
import 'package:backend/screens/Product_list_screen.dart';
import 'package:backend/screens/search_screen.dart';
import 'package:backend/screens/api_service.dart';
import 'package:backend/screens/shop_screen2.dart';
import 'package:backend/screens/app_bottom_nav.dart';

class ShopScreen extends StatefulWidget {
  const ShopScreen({super.key});

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen>
    with SingleTickerProviderStateMixin {
  TabController? _tabController;

  List<CategoryModel> _rootCategories = [];
  Map<String, List<CategoryModel>> _subCategories = {};
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  Future<void> _loadCategories() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final roots = await ApiService.getRootCategories();

      const order = ['Women', 'Men', 'Kids'];
      roots.sort((a, b) {
        final ai = order.indexWhere(
          (o) => o.toLowerCase() == a.categoryName.toLowerCase(),
        );
        final bi = order.indexWhere(
          (o) => o.toLowerCase() == b.categoryName.toLowerCase(),
        );
        return (ai == -1 ? order.length : ai).compareTo(
          bi == -1 ? order.length : bi,
        );
      });

      final subMap = <String, List<CategoryModel>>{};
      for (final root in roots) {
        final subs = await ApiService.getSubCategories(root.id);
        subMap[root.id] = subs;
      }

      if (!mounted) return;

      _tabController?.dispose();

      final newController = TabController(
        length: roots.isEmpty ? 1 : roots.length,
        vsync: this,
      );

      setState(() {
        _rootCategories = roots;
        _subCategories = subMap;
        _tabController = newController;
        _isLoading = false;
        _error = null;
      });
    } catch (e) {
      if (!mounted) return;
      _tabController?.dispose();
      _tabController = TabController(length: 1, vsync: this);
      setState(() {
        _isLoading = false;
        _error = e.toString();
      });
    }
  }

  void _openSearch() {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const SearchScreen(),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 200),
      ),
    );
  }

  void _openCategories() {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const CategoriesScreen(),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 200),
      ),
    );
  }

  void _navigateToProducts(String categoryName, String categoryId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            ProductListScreen(category: categoryName, categoryId: categoryId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Loading state
    if (_isLoading) {
      return Scaffold(
        backgroundColor: const Color(0xFFF9F9F9),
        appBar: _buildSimpleAppBar(),
        body: const Center(
          child: CircularProgressIndicator(color: Color(0xFFDB3022)),
        ),
      );
    }

    // Error state — có nút thử lại
    if (_error != null || _rootCategories.isEmpty) {
      return Scaffold(
        backgroundColor: const Color(0xFFF9F9F9),
        appBar: _buildSimpleAppBar(),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.wifi_off, size: 48, color: Color(0xFFCCCCCC)),
              const SizedBox(height: 12),
              const Text(
                'Không thể tải danh mục',
                style: TextStyle(color: Color(0xFF9B9B9B), fontSize: 15),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadCategories,
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
        ),
        bottomNavigationBar: _buildBottomNav(),
      );
    }

    // Success state
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Color(0xFF222222),
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Categories',
          style: TextStyle(
            color: Color(0xFF222222),
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.sort_rounded,
              color: Color(0xFF222222),
              size: 24,
            ),
            onPressed: _openCategories,
          ),
          IconButton(
            icon: const Icon(Icons.search, color: Color(0xFF222222), size: 24),
            onPressed: _openSearch,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF222222),
          unselectedLabelColor: const Color(0xFF9B9B9B),
          labelStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w400,
          ),
          indicatorColor: const Color(0xFFDB3022),
          indicatorWeight: 2,
          tabs: _rootCategories
              .map((cat) => Tab(text: cat.categoryName))
              .toList(),
        ),
      ),
      body: RefreshIndicator(
        color: const Color(0xFFDB3022),
        onRefresh: _loadCategories,
        child: TabBarView(
          controller: _tabController,
          children: _rootCategories
              .map((root) => _buildCategoryList(root))
              .toList(),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  AppBar _buildSimpleAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(
          Icons.arrow_back_ios,
          color: Color(0xFF222222),
          size: 20,
        ),
        onPressed: () => Navigator.pop(context),
      ),
      title: const Text(
        'Categories',
        style: TextStyle(
          color: Color(0xFF222222),
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      centerTitle: true,
    );
  }

  Widget _buildBottomNav() {
    return const AppBottomNav(currentIndex: 1);
  }

  Widget _buildCategoryList(CategoryModel root) {
    final subs = _subCategories[root.id] ?? [];
    return SingleChildScrollView(
      // ✅ Bắt buộc để RefreshIndicator hoạt động kể cả khi content ngắn
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            height: 88,
            decoration: BoxDecoration(
              color: const Color(0xFFDB3022),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'SUMMER SALES',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Up to 50% off',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          if (subs.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.only(top: 40),
                child: Text(
                  'Không có danh mục',
                  style: TextStyle(color: Color(0xFF9B9B9B)),
                ),
              ),
            )
          else
            ...subs.map((cat) => _buildCategoryCard(cat)),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(CategoryModel category) {
    return GestureDetector(
      onTap: () => _navigateToProducts(category.categoryName, category.id),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        height: 120,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0D000000),
              offset: Offset(0, 1),
              blurRadius: 8,
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 20),
                child: Text(
                  category.categoryName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF222222),
                  ),
                ),
              ),
            ),
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(8),
                bottomRight: Radius.circular(8),
              ),
              child: category.image != null
                  ? Image.network(
                      category.image!,
                      width: 160,
                      height: 120,
                      fit: BoxFit.cover,
                      cacheWidth: 320,
                      cacheHeight: 240,
                      errorBuilder: (_, __, ___) => _imagePlaceholder(),
                    )
                  : _imagePlaceholder(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _imagePlaceholder() {
    return Container(
      width: 160,
      height: 120,
      color: const Color(0xFFEEEEEE),
      child: const Icon(Icons.image_not_supported, color: Color(0xFF9B9B9B)),
    );
  }
}
