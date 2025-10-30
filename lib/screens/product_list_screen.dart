import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:aura_bloom/theme.dart';
import 'package:aura_bloom/models/product.dart';
import 'package:aura_bloom/services/product_service.dart';
import 'package:aura_bloom/widgets/product_card.dart';
import 'package:aura_bloom/constants/app_constants.dart';

class ProductListScreen extends StatefulWidget {
  final String? category;

  const ProductListScreen({super.key, this.category});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  final ProductService _productService = ProductService();
  List<Product> _products = [];
  List<Product> _filteredProducts = [];
  bool _isLoading = true;
  bool _isGridView = true;
  String _sortBy = 'Relevance';
  final TextEditingController _searchController = TextEditingController();

  List<String> _selectedCategories = [];
  List<String> _selectedSizes = [];
  List<String> _selectedColors = [];
  double _minPrice = 0;
  double _maxPrice = 20000;

  @override
  void initState() {
    super.initState();
    if (widget.category != null) _selectedCategories = [widget.category!];
    _loadProducts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadProducts() async {
    setState(() => _isLoading = true);
    var products = await _productService.getAllProducts();
    if (widget.category != null) {
      products = products.where((p) => p.category == widget.category).toList();
    }
    if (mounted) {
      setState(() {
        _products = products;
        _filteredProducts = products;
        _isLoading = false;
      });
      _applyFilters();
    }
  }

  void _applyFilters() async {
    var filtered = await _productService.filterProducts(
      categories: _selectedCategories.isEmpty ? null : _selectedCategories,
      sizes: _selectedSizes.isEmpty ? null : _selectedSizes,
      colors: _selectedColors.isEmpty ? null : _selectedColors,
      minPrice: _minPrice,
      maxPrice: _maxPrice,
    );
    
    if (_searchController.text.isNotEmpty) {
      final query = _searchController.text.toLowerCase();
      filtered = filtered.where((p) => p.name.toLowerCase().contains(query) || p.description.toLowerCase().contains(query)).toList();
    }

    filtered = await _productService.sortProducts(filtered, _sortBy);
    
    setState(() => _filteredProducts = filtered);
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _FilterSheet(
        selectedCategories: _selectedCategories,
        selectedSizes: _selectedSizes,
        selectedColors: _selectedColors,
        minPrice: _minPrice,
        maxPrice: _maxPrice,
        onApply: (categories, sizes, colors, minPrice, maxPrice) {
          setState(() {
            _selectedCategories = categories;
            _selectedSizes = sizes;
            _selectedColors = colors;
            _minPrice = minPrice;
            _maxPrice = maxPrice;
          });
          _applyFilters();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.category ?? 'All Products'),
        actions: [
          IconButton(onPressed: () => setState(() => _isGridView = !_isGridView), icon: Icon(_isGridView ? Icons.view_list : Icons.grid_view)),
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort),
            onSelected: (value) {
              setState(() => _sortBy = value);
              _applyFilters();
            },
            itemBuilder: (context) => AppConstants.sortOptions.map((option) => PopupMenuItem(value: option, child: Text(option))).toList(),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search products...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    onChanged: (_) => _applyFilters(),
                  ),
                ),
                const SizedBox(width: 12),
                IconButton(
                  onPressed: _showFilterSheet,
                  icon: const Icon(Icons.filter_list),
                  style: IconButton.styleFrom(backgroundColor: AuraColors.dustyRose, foregroundColor: Colors.white, padding: const EdgeInsets.all(12)),
                ),
              ],
            ),
          ),
          if (_selectedCategories.isNotEmpty || _selectedSizes.isNotEmpty || _selectedColors.isNotEmpty)
            Container(
              height: 40,
              margin: const EdgeInsets.only(bottom: 8),
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  ..._selectedCategories.map((c) => _FilterChip(label: c, onRemove: () {
                    setState(() => _selectedCategories.remove(c));
                    _applyFilters();
                  })),
                  ..._selectedSizes.map((s) => _FilterChip(label: s, onRemove: () {
                    setState(() => _selectedSizes.remove(s));
                    _applyFilters();
                  })),
                  ..._selectedColors.map((c) => _FilterChip(label: c, onRemove: () {
                    setState(() => _selectedColors.remove(c));
                    _applyFilters();
                  })),
                ],
              ),
            ),
          Expanded(
            child: _isLoading ? const Center(child: CircularProgressIndicator()) : _filteredProducts.isEmpty ? Center(child: Text('No products found', style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AuraColors.mediumGrey))) : AnimationLimiter(
              child: _isGridView ? GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 0.65, crossAxisSpacing: 12, mainAxisSpacing: 12),
                itemCount: _filteredProducts.length,
                itemBuilder: (context, index) => AnimationConfiguration.staggeredGrid(
                  position: index,
                  duration: const Duration(milliseconds: 375),
                  columnCount: 2,
                  child: ScaleAnimation(child: FadeInAnimation(child: ProductCard(product: _filteredProducts[index]))),
                ),
              ) : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _filteredProducts.length,
                itemBuilder: (context, index) => AnimationConfiguration.staggeredList(
                  position: index,
                  duration: const Duration(milliseconds: 375),
                  child: SlideAnimation(verticalOffset: 50.0, child: FadeInAnimation(child: Padding(padding: const EdgeInsets.only(bottom: 12), child: ProductCard(product: _filteredProducts[index])))),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final VoidCallback onRemove;

  const _FilterChip({required this.label, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(color: AuraColors.dustyRose.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: TextStyle(color: AuraColors.dustyRose, fontSize: 12)),
          const SizedBox(width: 4),
          GestureDetector(onTap: onRemove, child: Icon(Icons.close, size: 16, color: AuraColors.dustyRose)),
        ],
      ),
    );
  }
}

class _FilterSheet extends StatefulWidget {
  final List<String> selectedCategories;
  final List<String> selectedSizes;
  final List<String> selectedColors;
  final double minPrice;
  final double maxPrice;
  final Function(List<String>, List<String>, List<String>, double, double) onApply;

  const _FilterSheet({required this.selectedCategories, required this.selectedSizes, required this.selectedColors, required this.minPrice, required this.maxPrice, required this.onApply});

  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  late List<String> _categories;
  late List<String> _sizes;
  late List<String> _colors;
  late RangeValues _priceRange;

  @override
  void initState() {
    super.initState();
    _categories = [...widget.selectedCategories];
    _sizes = [...widget.selectedSizes];
    _colors = [...widget.selectedColors];
    _priceRange = RangeValues(widget.minPrice, widget.maxPrice);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(border: Border(bottom: BorderSide(color: AuraColors.lightGrey))),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Filters', style: Theme.of(context).textTheme.titleLarge),
                TextButton(onPressed: () {
                  setState(() {
                    _categories.clear();
                    _sizes.clear();
                    _colors.clear();
                    _priceRange = const RangeValues(0, 20000);
                  });
                }, child: const Text('Clear All')),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Categories', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Wrap(spacing: 8, children: AppConstants.categories.map((c) => FilterChip(label: Text(c), selected: _categories.contains(c), onSelected: (selected) => setState(() => selected ? _categories.add(c) : _categories.remove(c)))).toList()),
                  const SizedBox(height: 16),
                  Text('Sizes', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Wrap(spacing: 8, children: AppConstants.sizes.map((s) => FilterChip(label: Text(s), selected: _sizes.contains(s), onSelected: (selected) => setState(() => selected ? _sizes.add(s) : _sizes.remove(s)))).toList()),
                  const SizedBox(height: 16),
                  Text('Colors', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Wrap(spacing: 8, children: AppConstants.colors.map((c) => FilterChip(label: Text(c), selected: _colors.contains(c), onSelected: (selected) => setState(() => selected ? _colors.add(c) : _colors.remove(c)))).toList()),
                  const SizedBox(height: 16),
                  Text('Price Range: ₹${_priceRange.start.toInt()} - ₹${_priceRange.end.toInt()}', style: Theme.of(context).textTheme.titleMedium),
                  RangeSlider(values: _priceRange, min: 0, max: 20000, divisions: 40, activeColor: AuraColors.dustyRose, onChanged: (values) => setState(() => _priceRange = values)),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  widget.onApply(_categories, _sizes, _colors, _priceRange.start, _priceRange.end);
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(backgroundColor: AuraColors.dustyRose, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), elevation: 0),
                child: const Text('Apply Filters', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
