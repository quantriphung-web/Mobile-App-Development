import 'package:flutter/material.dart';

class BrandFilterScreen extends StatefulWidget {
  final Set<String> selectedBrands;

  const BrandFilterScreen({super.key, required this.selectedBrands});

  @override
  State<BrandFilterScreen> createState() => _BrandFilterScreenState();
}

class _BrandFilterScreenState extends State<BrandFilterScreen> {
  final List<String> _allBrands = [
    'adidas',
    'adidas Originals',
    'Blend',
    'Boutique Moschino',
    'Champion',
    'Diesel',
    'Dorothy Perkins',
    'Jack & Jones',
    'LOST Ink',
    'Mango',
    'Naf Naf',
    'Red Valentino',
    'River Island',
    's.Oliver',
    'Topshop',
  ];

  late Set<String> _selected;
  String _query = '';
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selected = Set.from(widget.selectedBrands);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  List<String> get _filtered {
    if (_query.isEmpty) return _allBrands;
    return _allBrands
        .where((b) => b.toLowerCase().contains(_query.toLowerCase()))
        .toList();
  }

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
          onPressed: () => Navigator.pop(context, _selected),
        ),
        title: const Text(
          'Brand',
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
          // Search bar
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(30),
              ),
              child: TextField(
                controller: _controller,
                onChanged: (v) => setState(() => _query = v),
                style: const TextStyle(fontSize: 14, color: Color(0xFF222222)),
                decoration: const InputDecoration(
                  hintText: 'Search',
                  hintStyle: TextStyle(fontSize: 14, color: Color(0xFF9B9B9B)),
                  prefixIcon: Icon(
                    Icons.search,
                    color: Color(0xFF9B9B9B),
                    size: 20,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 12),
                  isDense: true,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          // Brand list
          Expanded(
            child: Container(
              color: Colors.white,
              child: ListView.separated(
                padding: EdgeInsets.zero,
                itemCount: _filtered.length,
                separatorBuilder: (_, _i) => const Divider(
                  height: 1,
                  indent: 16,
                  endIndent: 16,
                  color: Color(0xFFF5F5F5),
                ),
                itemBuilder: (_, i) {
                  final brand = _filtered[i];
                  final checked = _selected.contains(brand);
                  return InkWell(
                    onTap: () => setState(() {
                      if (checked) {
                        _selected.remove(brand);
                      } else {
                        _selected.add(brand);
                      }
                    }),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 18,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            brand,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: checked
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                              color: checked
                                  ? const Color(0xFFDB3022)
                                  : const Color(0xFF222222),
                            ),
                          ),
                          _buildCheckbox(checked),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          _buildBottomButtons(),
        ],
      ),
    );
  }

  Widget _buildCheckbox(bool checked) {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: checked ? const Color(0xFFDB3022) : Colors.white,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: checked ? const Color(0xFFDB3022) : const Color(0xFFCCCCCC),
          width: 1.5,
        ),
      ),
      child: checked
          ? const Icon(Icons.check, color: Colors.white, size: 16)
          : null,
    );
  }

  Widget _buildBottomButtons() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFF0F0F0), width: 1)),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () {
                setState(() => _selected.clear());
                Navigator.pop(context, _selected);
              },
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
          Expanded(
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context, _selected),
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
