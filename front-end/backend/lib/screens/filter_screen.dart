import 'package:flutter/material.dart';
import 'package:backend/screens/brand_filter_screen.dart';

class FilterScreen extends StatefulWidget {
  const FilterScreen({super.key});

  @override
  State<FilterScreen> createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> {
  // Price range
  double _minPrice = 78;
  double _maxPrice = 143;
  final double _priceMin = 0;
  final double _priceMax = 300;

  // Colors
  final List<Map<String, dynamic>> _colors = [
    {'color': const Color(0xFF111111), 'selected': true},
    {'color': const Color(0xFFE0E0E0), 'selected': false},
    {'color': const Color(0xFFDB3022), 'selected': false},
    {'color': const Color(0xFFB0A0A0), 'selected': false},
    {'color': const Color(0xFFD4A96A), 'selected': true},
    {'color': const Color(0xFF1A237E), 'selected': false},
  ];

  // Sizes
  final List<String> _sizes = ['XS', 'S', 'M', 'L', 'XL'];
  final Set<String> _selectedSizes = {'S', 'M'};

  // Categories
  final List<String> _categoryOptions = [
    'All',
    'Women',
    'Men',
    'Boys',
    'Girls',
  ];
  String _selectedCategory = 'All';

  // Brands (selected from brand screen)
  final Set<String> _selectedBrands = {
    'adidas Originals',
    'Jack & Jones',
    's.Oliver',
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),
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
          'Filters',
          style: TextStyle(
            color: Color(0xFF222222),
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildSection('Price range', _buildPriceRange()),
                  _buildSection('Colors', _buildColors()),
                  _buildSection('Sizes', _buildSizes()),
                  _buildSection('Category', _buildCategories()),
                  _buildBrandRow(),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
          _buildBottomButtons(),
        ],
      ),
    );
  }

  // ── Section wrapper ──────────────────────────────────────────────────────────

  Widget _buildSection(String title, Widget content) {
    return Container(
      width: double.infinity,
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFF222222),
            ),
          ),
          const SizedBox(height: 16),
          content,
        ],
      ),
    );
  }

  // ── Price range ──────────────────────────────────────────────────────────────

  Widget _buildPriceRange() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '\$${_minPrice.toInt()}',
              style: const TextStyle(fontSize: 14, color: Color(0xFF222222)),
            ),
            Text(
              '\$${_maxPrice.toInt()}',
              style: const TextStyle(fontSize: 14, color: Color(0xFF222222)),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: const Color(0xFFDB3022),
            inactiveTrackColor: const Color(0xFFE0E0E0),
            thumbColor: const Color(0xFFDB3022),
            overlayColor: const Color(0x29DB3022),
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
            trackHeight: 2,
            rangeThumbShape: const RoundRangeSliderThumbShape(
              enabledThumbRadius: 10,
            ),
          ),
          child: RangeSlider(
            values: RangeValues(_minPrice, _maxPrice),
            min: _priceMin,
            max: _priceMax,
            onChanged: (v) => setState(() {
              _minPrice = v.start;
              _maxPrice = v.end;
            }),
          ),
        ),
      ],
    );
  }

  // ── Colors ───────────────────────────────────────────────────────────────────

  Widget _buildColors() {
    return Row(
      children: _colors.asMap().entries.map((e) {
        final i = e.key;
        final c = e.value;
        final selected = c['selected'] as bool;
        return GestureDetector(
          onTap: () =>
              setState(() => _colors[i]['selected'] = !_colors[i]['selected']),
          child: Container(
            width: 44,
            height: 44,
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: selected
                  ? Border.all(color: const Color(0xFFDB3022), width: 2)
                  : Border.all(color: Colors.transparent, width: 2),
            ),
            child: Container(
              margin: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: c['color'] as Color,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // ── Sizes ────────────────────────────────────────────────────────────────────

  Widget _buildSizes() {
    return Row(
      children: _sizes.map((s) {
        final selected = _selectedSizes.contains(s);
        return GestureDetector(
          onTap: () => setState(() {
            if (selected) {
              _selectedSizes.remove(s);
            } else {
              _selectedSizes.add(s);
            }
          }),
          child: Container(
            width: 52,
            height: 52,
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: selected ? const Color(0xFFDB3022) : Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: selected
                    ? const Color(0xFFDB3022)
                    : const Color(0xFFE0E0E0),
                width: 1,
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              s,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: selected ? Colors.white : const Color(0xFF222222),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // ── Categories ───────────────────────────────────────────────────────────────

  Widget _buildCategories() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _categoryOptions.map((cat) {
        final selected = cat == _selectedCategory;
        return GestureDetector(
          onTap: () => setState(() => _selectedCategory = cat),
          child: Container(
            width: (MediaQuery.of(context).size.width - 56) / 3,
            height: 48,
            decoration: BoxDecoration(
              color: selected ? const Color(0xFFDB3022) : Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: selected
                    ? const Color(0xFFDB3022)
                    : const Color(0xFFE0E0E0),
                width: 1,
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              cat,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: selected ? Colors.white : const Color(0xFF222222),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // ── Brand row ────────────────────────────────────────────────────────────────

  Widget _buildBrandRow() {
    final preview = _selectedBrands.isEmpty
        ? ''
        : _selectedBrands.take(3).join(', ');

    return GestureDetector(
      onTap: () async {
        final result = await Navigator.push<Set<String>>(
          context,
          MaterialPageRoute(
            builder: (_) =>
                BrandFilterScreen(selectedBrands: Set.from(_selectedBrands)),
          ),
        );
        if (result != null) {
          setState(() {
            _selectedBrands
              ..clear()
              ..addAll(result);
          });
        }
      },
      child: Container(
        color: Colors.white,
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Brand',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF222222),
                  ),
                ),
                if (preview.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    preview,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF9B9B9B),
                    ),
                  ),
                ],
              ],
            ),
            const Icon(Icons.chevron_right, color: Color(0xFF9B9B9B), size: 22),
          ],
        ),
      ),
    );
  }

  // ── Bottom buttons ───────────────────────────────────────────────────────────

  Widget _buildBottomButtons() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFF0F0F0), width: 1)),
      ),
      child: Row(
        children: [
          // Discard
          Expanded(
            child: OutlinedButton(
              onPressed: () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF222222),
                side: const BorderSide(color: Color(0xFF222222), width: 1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text(
                'Discard',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Apply
          Expanded(
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFDB3022),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text(
                'Apply',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
