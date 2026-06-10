import 'package:flutter/material.dart';
import 'package:backend/screens/Product_list_screen.dart';
import 'package:backend/screens/api_service.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  String _query = '';

  final List<String> _recentSearches = ['Tops', 'Summer dress', 'Blazers'];

  // Categories load từ API
  List<CategoryModel> _categories = [];
  bool _isLoadingCategories = true;

  // Icon map theo tên category
  static const Map<String, IconData> _iconMap = {
    'Tops': Icons.dry_cleaning_outlined,
    'Shirts & Blouses': Icons.checkroom_outlined,
    'Cardigans & Sweaters': Icons.dry_cleaning_outlined,
    'Knitwear': Icons.texture,
    'Blazers': Icons.business_center_outlined,
    'Outerwear': Icons.umbrella_outlined,
    'Pants': Icons.checkroom_outlined,
    'Jeans': Icons.checkroom_outlined,
    'Shorts': Icons.dry_cleaning_outlined,
    'Skirts': Icons.dry_cleaning_outlined,
    'Dresses': Icons.dry_cleaning_outlined,
    'Jumpsuits': Icons.checkroom_outlined,
    'T-Shirts': Icons.dry_cleaning_outlined,
    'Shirts': Icons.checkroom_outlined,
    'Jackets': Icons.umbrella_outlined,
    'Girls': Icons.child_care,
    'Boys': Icons.child_care,
  };

  List<CategoryModel> get _filteredCategories {
    if (_query.isEmpty) return _categories;
    return _categories
        .where(
          (c) => c.categoryName.toLowerCase().contains(_query.toLowerCase()),
        )
        .toList();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      // Lấy tất cả categories (bao gồm sub-categories)
      final all = await ApiService.getAllCategories();
      // Chỉ hiển thị sub-categories (có parent_id) vì root quá chung
      setState(() {
        _categories = all.where((c) => c.parentId != null).toList();
        _isLoadingCategories = false;
      });
    } catch (e) {
      setState(() => _isLoadingCategories = false);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _goToProducts(String categoryName, String categoryId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            ProductListScreen(category: categoryName, categoryId: categoryId),
      ),
    );
  }

  void _submitSearch() {
    final q = _controller.text.trim();
    if (q.isEmpty) return;
    if (!_recentSearches.contains(q)) {
      setState(() => _recentSearches.insert(0, q));
    }
    // Tìm category khớp tên để truyền categoryId
    final match = _categories.firstWhere(
      (c) => c.categoryName.toLowerCase() == q.toLowerCase(),
      orElse: () => CategoryModel(id: '', categoryName: q, active: true),
    );
    _goToProducts(q, match.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        titleSpacing: 0,
        title: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 8, 0),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: TextField(
                    controller: _controller,
                    focusNode: _focusNode,
                    onChanged: (v) => setState(() => _query = v),
                    onSubmitted: (_) => _submitSearch(),
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF222222),
                    ),
                    decoration: InputDecoration(
                      hintText: 'Search...',
                      hintStyle: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF9B9B9B),
                      ),
                      prefixIcon: const Icon(
                        Icons.search,
                        color: Color(0xFF9B9B9B),
                        size: 20,
                      ),
                      suffixIcon: _query.isNotEmpty
                          ? IconButton(
                              icon: const Icon(
                                Icons.close,
                                color: Color(0xFF9B9B9B),
                                size: 18,
                              ),
                              onPressed: () {
                                _controller.clear();
                                setState(() => _query = '');
                              },
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 10),
                      isDense: true,
                    ),
                  ),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF222222),
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                ),
                child: const Text(
                  'Cancel',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
        ),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: Color(0xFFF0F0F0)),
        ),
      ),
      body: _query.isEmpty ? _buildDefault() : _buildSearchResults(),
    );
  }

  // ── Default state ────────────────────────────────────────────────────────────

  Widget _buildDefault() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_recentSearches.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Recent searches',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF222222),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => setState(() => _recentSearches.clear()),
                    child: const Text(
                      'Clear all',
                      style: TextStyle(fontSize: 13, color: Color(0xFFDB3022)),
                    ),
                  ),
                ],
              ),
            ),
            ..._recentSearches.map((s) => _buildRecentItem(s)),
            const SizedBox(height: 8),
            const Divider(height: 1, color: Color(0xFFF0F0F0)),
          ],
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 20, 16, 12),
            child: Text(
              'Choose category',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF222222),
              ),
            ),
          ),
          if (_isLoadingCategories)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: CircularProgressIndicator(color: Color(0xFFDB3022)),
              ),
            )
          else
            ..._categories.map((c) => _buildCategoryRow(c)),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildRecentItem(String text) {
    return InkWell(
      onTap: () {
        _controller.text = text;
        setState(() => _query = text);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Color(0xFFF5F5F5), width: 1),
          ),
        ),
        child: Row(
          children: [
            const Icon(Icons.history, size: 18, color: Color(0xFF9B9B9B)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                text,
                style: const TextStyle(fontSize: 14, color: Color(0xFF222222)),
              ),
            ),
            GestureDetector(
              onTap: () => setState(() => _recentSearches.remove(text)),
              child: const Icon(
                Icons.close,
                size: 16,
                color: Color(0xFFCCCCCC),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryRow(CategoryModel cat) {
    final icon = _iconMap[cat.categoryName] ?? Icons.checkroom_outlined;
    return InkWell(
      onTap: () => _goToProducts(cat.categoryName, cat.id),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Color(0xFFF5F5F5), width: 1),
          ),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: const Color(0xFF9B9B9B)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                cat.categoryName,
                style: const TextStyle(fontSize: 14, color: Color(0xFF222222)),
              ),
            ),
            const Icon(Icons.chevron_right, size: 18, color: Color(0xFFCCCCCC)),
          ],
        ),
      ),
    );
  }

  // ── Search results ───────────────────────────────────────────────────────────

  Widget _buildSearchResults() {
    final results = _filteredCategories;

    if (results.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.search_off, size: 48, color: Color(0xFFCCCCCC)),
            const SizedBox(height: 12),
            Text(
              'No results for "$_query"',
              style: const TextStyle(fontSize: 15, color: Color(0xFF9B9B9B)),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            '${results.length} categories found',
            style: const TextStyle(fontSize: 13, color: Color(0xFF9B9B9B)),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: results.length,
            itemBuilder: (_, i) => _buildCategoryRow(results[i]),
          ),
        ),
      ],
    );
  }
}
