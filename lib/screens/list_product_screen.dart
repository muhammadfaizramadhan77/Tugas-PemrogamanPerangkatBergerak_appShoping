import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../models/product_model.dart';
import '../providers/product_provider.dart';
import '../theme/app_theme.dart';

class ListProductScreen extends StatefulWidget {
  const ListProductScreen({super.key});

  @override
  State<ListProductScreen> createState() => _ListProductScreenState();
}

class _ListProductScreenState extends State<ListProductScreen> {
  final _scroll = ScrollController();
  final _searchCtrl = TextEditingController();
  Timer? _debounce;
  String _sortKey = 'Default';

  static const _sortOptions = <String, List<String>>{
    'Default': ['', 'asc'],
    'Harga termurah': ['price', 'asc'],
    'Harga termahal': ['price', 'desc'],
    'Nama A-Z': ['title', 'asc'],
    'Nama Z-A': ['title', 'desc'],
    'Rating tertinggi': ['rating', 'desc'],
  };

  @override
  void initState() {
    super.initState();
    _scroll.addListener(() {
      if (_scroll.position.pixels >= _scroll.position.maxScrollExtent - 300) {
        context.read<ProductProvider>().fetchProducts(refresh: false);
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final p = context.read<ProductProvider>();
      p.fetchCategories();
      p.fetchProducts();
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _scroll.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  void _onSearchChanged(String q) {
    setState(() {});
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      context.read<ProductProvider>().search(q);
    });
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<ProductProvider>();

    return AppBackdrop(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => context.push('/add'),
          backgroundColor: AppColors.ink,
          foregroundColor: Colors.white,
          elevation: 0,
          highlightElevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          icon: const Icon(Icons.add_rounded),
          label: const Text('Tambah',
              style: TextStyle(fontWeight: FontWeight.w700)),
        ),
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              _header(p),
              _searchBar(),
              _categoryChips(p),
              Expanded(child: _buildBody(p)),
            ],
          ),
        ),
      ),
    );
  }

  // ---------- Header ----------

  Widget _header(ProductProvider p) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 16, 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Temukan produk',
                  style: TextStyle(
                    fontSize: 28,
                    height: 1.1,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.8,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.lemon,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${p.products.length} dari ${p.total} produk',
                    style: const TextStyle(
                        fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
          _sortButton(),
        ],
      ),
    );
  }

  Widget _sortButton() {
    return PopupMenuButton<String>(
      tooltip: 'Urutkan',
      offset: const Offset(0, 52),
      onSelected: (key) {
        setState(() => _sortKey = key);
        final v = _sortOptions[key]!;
        context.read<ProductProvider>().sort(v[0], v[1]);
      },
      itemBuilder: (_) => _sortOptions.keys
          .map(
            (k) => PopupMenuItem<String>(
              value: k,
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      k,
                      style: TextStyle(
                        fontWeight:
                            k == _sortKey ? FontWeight.w800 : FontWeight.w500,
                      ),
                    ),
                  ),
                  if (k == _sortKey)
                    const Icon(Icons.check_rounded,
                        size: 18, color: AppColors.pinkDeep),
                ],
              ),
            ),
          )
          .toList(),
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: _sortKey == 'Default' ? Colors.white : AppColors.pink,
          shape: BoxShape.circle,
          boxShadow: AppShadows.soft,
        ),
        child: const Icon(Icons.tune_rounded, color: AppColors.ink),
      ),
    );
  }

  // ---------- Search & kategori ----------

  Widget _searchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: AppShadows.soft,
        ),
        child: TextField(
          controller: _searchCtrl,
          onChanged: _onSearchChanged,
          decoration: InputDecoration(
            hintText: 'Cari produk (mis. phone)',
            prefixIcon: const Icon(Icons.search_rounded),
            suffixIcon: _searchCtrl.text.isEmpty
                ? null
                : IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () {
                      _searchCtrl.clear();
                      context.read<ProductProvider>().search('');
                      setState(() {});
                    },
                  ),
          ),
        ),
      ),
    );
  }

  Widget _categoryChips(ProductProvider p) {
    return SizedBox(
      height: 54,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        children: [
          _chip('Semua', p.selectedCategory.isEmpty, () {
            _searchCtrl.clear();
            setState(() {});
            p.filterByCategory('');
          }),
          for (final c in p.categories)
            _chip(prettyLabel(c), p.selectedCategory == c, () {
              _searchCtrl.clear();
              setState(() {});
              p.filterByCategory(c);
            }),
        ],
      ),
    );
  }

  Widget _chip(String label, bool selected, VoidCallback onTap) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 9),
        child: GestureDetector(
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: selected
                  ? AppColors.ink
                  : Colors.white.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: selected ? Colors.white : AppColors.ink,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ),
        ),
      );

  // ---------- Body ----------

  Widget _stateMessage({
    required IconData icon,
    required Color tint,
    required String title,
    String? subtitle,
    Widget? action,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 84,
              height: 84,
              decoration: BoxDecoration(color: tint, shape: BoxShape.circle),
              child: Icon(icon, size: 38, color: AppColors.ink),
            ),
            const SizedBox(height: 16),
            Text(title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w700)),
            if (subtitle != null) ...[
              const SizedBox(height: 4),
              Text(subtitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.inkSoft)),
            ],
            if (action != null) ...[const SizedBox(height: 20), action],
          ],
        ),
      ),
    );
  }

  Widget _buildBody(ProductProvider p) {
    if (p.loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (p.error != null && p.products.isEmpty) {
      return _stateMessage(
        icon: Icons.wifi_off_rounded,
        tint: AppColors.rose,
        title: p.error!,
        action: ElevatedButton(
          onPressed: p.fetchProducts,
          child: const Text('Coba lagi'),
        ),
      );
    }
    if (p.products.isEmpty) {
      return _stateMessage(
        icon: Icons.search_off_rounded,
        tint: AppColors.lavender,
        title: 'Produk tidak ditemukan',
        subtitle: 'Coba kata kunci atau kategori lain',
      );
    }
    return RefreshIndicator(
      color: AppColors.ink,
      backgroundColor: AppColors.pink,
      onRefresh: p.fetchProducts,
      child: CustomScrollView(
        controller: _scroll,
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 6, 16, 16),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 14,
                crossAxisSpacing: 14,
                childAspectRatio: 0.66,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, i) => _ProductCard(
                  key: ValueKey(p.products[i].id),
                  product: p.products[i],
                  index: i,
                ),
                childCount: p.products.length,
              ),
            ),
          ),
          if (p.loadingMore)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Center(child: CircularProgressIndicator()),
              ),
            ),
          const SliverToBoxAdapter(child: SizedBox(height: 96)),
        ],
      ),
    );
  }
}

class _ProductCard extends StatefulWidget {
  final Product product;
  final int index;
  const _ProductCard({super.key, required this.product, required this.index});

  @override
  State<_ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<_ProductCard> {
  // Hanya tampilan (belum tersimpan ke provider / server).
  bool _liked = false;

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final disc = double.tryParse('${product.discountPercentage}') ?? 0;
    final subtitle =
        product.brand.isEmpty ? prettyLabel(product.category) : product.brand;

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        boxShadow: AppShadows.soft,
      ),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => context.push('/detail/${product.id}'),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Container(
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.tint(widget.index),
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Hero(
                            tag: 'product-${product.id}',
                            child: CachedNetworkImage(
                              imageUrl: product.thumbnail,
                              fit: BoxFit.contain,
                              placeholder: (_, __) => const Center(
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              ),
                              errorWidget: (_, __, ___) => const Icon(
                                Icons.image_not_supported_outlined,
                                color: AppColors.inkSoft,
                              ),
                            ),
                          ),
                        ),
                      ),
                      if (disc >= 1)
                        Positioned(
                          top: 8,
                          left: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.9),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '-${disc.round()}%',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: AppColors.ink,
                              ),
                            ),
                          ),
                        ),
                      Positioned(
                        top: 6,
                        right: 6,
                        child: GestureDetector(
                          onTap: () => setState(() => _liked = !_liked),
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.9),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              _liked
                                  ? Icons.favorite_rounded
                                  : Icons.favorite_border_rounded,
                              size: 17,
                              color: _liked
                                  ? AppColors.pinkDeep
                                  : AppColors.inkSoft,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      product.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        height: 1.25,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.inkSoft),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '\$${product.price.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.3,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.lemon,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.star_rounded,
                                  size: 14, color: AppColors.star),
                              const SizedBox(width: 2),
                              Text(
                                '${product.rating}',
                                style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}