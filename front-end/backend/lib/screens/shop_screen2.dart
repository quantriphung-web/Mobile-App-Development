import 'package:flutter/material.dart';
import 'package:backend/screens/api_service.dart';
import 'package:backend/screens/Product_list_screen.dart';
import 'package:backend/screens/search_screen.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  // Tất cả sub-categories từ mọi root gộp lại để hiển thị danh sách phẳng
  List<CategoryModel> _allCategories = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadAllCategories();
  }

  Future<void> _loadAllCategories() async {
    try {
      // Lấy root categories (Women / Men / Kids ...)
      final roots = await ApiService.getRootCategories();

      final allSubs = <CategoryModel>[];
      for (final root in roots) {
        // Lấy sub-categories của từng root
        final subs = await ApiService.getSubCategories(root.id);
        allSubs.addAll(subs);
      }

      setState(() {
        _allCategories = allSubs;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Không thể tải danh mục. Vui lòng thử lại.';
        _isLoading = false;
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

  void _navigateToProducts(String categoryName, String categoryId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            ProductListScreen(category: categoryName, categoryId: categoryId),
      ),
    );
  }

  void _viewAllItems() {
    // Điều hướng tới ProductListScreen không lọc category
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            const ProductListScreen(category: 'All Items', categoryId: ''),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F5F5),
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.chevron_left,
            size: 28,
            color: Color(0xFF222222),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Categories',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: Color(0xFF222222),
            letterSpacing: 0.2,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.search, size: 26, color: Color(0xFF222222)),
            onPressed: _openSearch,
          ),
        ],
      ),
      body: _buildBody(),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBody() {
    // Loading state
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFFDB3022)),
      );
    }

    // Error state
    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Color(0xFF9B9B9B)),
            const SizedBox(height: 12),
            Text(
              _errorMessage!,
              style: const TextStyle(color: Color(0xFF9B9B9B), fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                setState(() {
                  _isLoading = true;
                  _errorMessage = null;
                });
                _loadAllCategories();
              },
              child: const Text(
                'Thử lại',
                style: TextStyle(color: Color(0xFFDB3022)),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // VIEW ALL ITEMS button
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _viewAllItems,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFDB3022),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text(
                'VIEW ALL ITEMS',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ),
        ),

        // "Choose category" label
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: Text(
            'Choose category',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
              fontWeight: FontWeight.w400,
            ),
          ),
        ),

        // Category list từ API
        Expanded(
          child: _allCategories.isEmpty
              ? const Center(
                  child: Text(
                    'Không có danh mục nào',
                    style: TextStyle(color: Color(0xFF9B9B9B), fontSize: 14),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.only(bottom: 16),
                  itemCount: _allCategories.length,
                  separatorBuilder: (context, index) => Divider(
                    height: 1,
                    thickness: 0.8,
                    color: Colors.grey[300],
                    indent: 16,
                    endIndent: 0,
                  ),
                  itemBuilder: (context, index) {
                    final cat = _allCategories[index];
                    return _CategoryTile(
                      label: cat.categoryName,
                      onTap: () =>
                          _navigateToProducts(cat.categoryName, cat.id),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildBottomNav() {
    return BottomNavigationBar(
      currentIndex: 1,
      onTap: (i) {
        if (i == 0) {
          Navigator.pushReplacementNamed(context, '/main');
        }
      },
      type: BottomNavigationBarType.fixed,
      selectedItemColor: const Color(0xFFDB3022),
      unselectedItemColor: const Color(0xFF9B9B9B),
      backgroundColor: Colors.white,
      elevation: 8,
      selectedLabelStyle: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w600,
      ),
      unselectedLabelStyle: const TextStyle(fontSize: 11),
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Home'),
        BottomNavigationBarItem(
          icon: Icon(Icons.shopping_cart_outlined),
          label: 'Shop',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.shopping_bag_outlined),
          label: 'Bag',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.favorite_border),
          label: 'Favorites',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          label: 'Profile',
        ),
      ],
    );
  }
}

// ─── Category Tile ────────────────────────────────────────────────────────────

class _CategoryTile extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _CategoryTile({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        color: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w400,
                color: Color(0xFF222222),
              ),
            ),
            const Icon(Icons.chevron_right, size: 20, color: Color(0xFF9B9B9B)),
          ],
        ),
      ),
    );
  }
}
