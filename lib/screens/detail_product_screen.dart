import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../models/product_model.dart';
import '../providers/product_provider.dart';
import '../theme/app_theme.dart';

class DetailProductScreen extends StatefulWidget {
  final int id;
  const DetailProductScreen({super.key, required this.id});

  @override
  State<DetailProductScreen> createState() => _DetailProductScreenState();
}

class _DetailProductScreenState extends State<DetailProductScreen> {
  late Future<Product> _future;
  int _page = 0;

  @override
  void initState() {
    super.initState();
    _future = context.read<ProductProvider>().getProduct(widget.id);
  }

  void _back() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/');
    }
  }

  Future<void> _delete(Product p) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Hapus produk?'),
        content: Text(p.title),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal',
                style: TextStyle(color: AppColors.inkSoft)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.danger,
              foregroundColor: Colors.white,
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    await context.read<ProductProvider>().deleteProduct(p.id);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text('Produk dihapus (mock, tidak permanen di server)')),
    );
    context.pop();
  }

  // ---------- Bagian-bagian layar ----------

  Widget _roundBack() => Padding(
        padding: const EdgeInsets.only(left: 12),
        child: Center(
          child: Material(
            color: Colors.white.withValues(alpha: 0.85),
            shape: const CircleBorder(),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: _back,
              child: const SizedBox(
                width: 40,
                height: 40,
                child: Icon(Icons.arrow_back_rounded,
                    size: 20, color: AppColors.ink),
              ),
            ),
          ),
        ),
      );

  PreferredSizeWidget _appBar() => AppBar(
        leading: _roundBack(),
        leadingWidth: 56,
        title: const Text('Detail produk'),
      );

  Widget _gallery(List<String> images, int id, double disc) {
    return Container(
      height: 340,
      margin: const EdgeInsets.fromLTRB(16, 4, 16, 0),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.peach, AppColors.lavender],
        ),
        borderRadius: BorderRadius.circular(36),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          PageView.builder(
            itemCount: images.length,
            onPageChanged: (i) => setState(() => _page = i),
            itemBuilder: (_, i) {
              final img = CachedNetworkImage(
                imageUrl: images[i],
                fit: BoxFit.contain,
                placeholder: (_, __) =>
                    const Center(child: CircularProgressIndicator()),
                errorWidget: (_, __, ___) => const Icon(
                    Icons.image_not_supported_outlined,
                    size: 48,
                    color: AppColors.inkSoft),
              );
              return Padding(
                padding: const EdgeInsets.all(28),
                child: i == 0 ? Hero(tag: 'product-$id', child: img) : img,
              );
            },
          ),
          if (disc >= 1)
            Positioned(
              top: 16,
              left: 16,
              child: _pill('-${disc.round()}%', Colors.white.withValues(alpha: 0.9)),
            ),
          if (images.length > 1)
            Positioned(
              bottom: 14,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      for (var i = 0; i < images.length; i++)
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          height: 6,
                          width: i == _page ? 20 : 6,
                          decoration: BoxDecoration(
                            color: i == _page
                                ? AppColors.ink
                                : AppColors.ink.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _priceAndStock(Product p, double disc) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            flex: 3,
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.pink, AppColors.peach],
                ),
                borderRadius: BorderRadius.circular(28),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Harga',
                      style:
                          TextStyle(fontSize: 12, color: AppColors.inkSoft)),
                  const SizedBox(height: 2),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      '\$${p.price.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.8,
                      ),
                    ),
                  ),
                  if (disc >= 1) ...[
                    const SizedBox(height: 8),
                    _pill('Hemat ${disc.round()}%',
                        Colors.white.withValues(alpha: 0.7)),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.mint,
                borderRadius: BorderRadius.circular(28),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Stok',
                      style:
                          TextStyle(fontSize: 12, color: AppColors.inkSoft)),
                  const SizedBox(height: 2),
                  Text(
                    '${p.stock}',
                    style: const TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.8,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    p.availabilityStatus,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoTile(IconData icon, String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 18, color: AppColors.ink),
          ),
          const SizedBox(height: 10),
          Text(label,
              style: const TextStyle(fontSize: 12, color: AppColors.inkSoft)),
          const SizedBox(height: 2),
          Text(value,
              style: const TextStyle(
                  fontSize: 13, height: 1.3, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }

  Widget _infoRow(Widget a, Widget b) => IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(child: a),
            const SizedBox(width: 12),
            Expanded(child: b),
          ],
        ),
      );

  Widget _sectionTitle(String text) => Text(
        text,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.3,
        ),
      );

  Widget _stars(num rating) {
    final n = rating.round().clamp(0, 5);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < 5; i++)
          Icon(
            i < n ? Icons.star_rounded : Icons.star_outline_rounded,
            size: 16,
            color: i < n ? AppColors.star : AppColors.inkSoft,
          ),
      ],
    );
  }

  Widget _reviewCard(int i, dynamic r) {
    final name = '${r.reviewerName}';
    final rating = double.tryParse('${r.rating}') ?? 0;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: AppColors.tint(i + 1),
                child: Text(
                  name.isEmpty ? '?' : name[0].toUpperCase(),
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: AppColors.ink,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(name,
                    style: const TextStyle(fontWeight: FontWeight.w700)),
              ),
              _stars(rating),
            ],
          ),
          const SizedBox(height: 10),
          Text('${r.comment}',
              style: const TextStyle(height: 1.45, color: AppColors.ink)),
        ],
      ),
    );
  }

  Widget _bottomBar(Product p) {
    return SafeArea(
      top: false,
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 8, 16, 12),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.92),
          borderRadius: BorderRadius.circular(30),
          boxShadow: AppShadows.soft,
        ),
        child: Row(
          children: [
            Expanded(
              flex: 3,
              child: ElevatedButton.icon(
                onPressed: () => context.push('/edit/${p.id}', extra: p),
                icon: const Icon(Icons.edit_rounded, size: 18),
                label: const Text('Edit'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(0, 50),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              flex: 2,
              child: ElevatedButton.icon(
                onPressed: () => _delete(p),
                icon: const Icon(Icons.delete_outline_rounded, size: 18),
                label: const Text('Hapus'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(0, 50),
                  backgroundColor: AppColors.rose,
                  foregroundColor: AppColors.danger,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------- Build ----------

  @override
  Widget build(BuildContext context) {
    return AppBackdrop(
      child: FutureBuilder<Product>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return Scaffold(
              backgroundColor: Colors.transparent,
              appBar: _appBar(),
              body: const Center(child: CircularProgressIndicator()),
            );
          }
          if (snap.hasError || !snap.hasData) {
            return Scaffold(
              backgroundColor: Colors.transparent,
              appBar: _appBar(),
              body: const Center(child: Text('Gagal memuat detail produk')),
            );
          }
          final p = snap.data!;
          final images = p.images.isNotEmpty ? p.images : [p.thumbnail];
          final disc = double.tryParse('${p.discountPercentage}') ?? 0;

          return Scaffold(
            backgroundColor: Colors.transparent,
            appBar: _appBar(),
            bottomNavigationBar: _bottomBar(p),
            body: ListView(
              padding: const EdgeInsets.only(bottom: 16),
              children: [
                _gallery(images, p.id, disc),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _pill(prettyLabel(p.category), AppColors.peach),
                          if (p.brand.isNotEmpty)
                            _pill(p.brand, Colors.white.withValues(alpha: 0.85)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        p.title,
                        style: const TextStyle(
                          fontSize: 26,
                          height: 1.15,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.7,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.lemon,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.star_rounded,
                                    size: 18, color: AppColors.star),
                                const SizedBox(width: 3),
                                Text('${p.rating}',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w800)),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text('${p.reviews.length} review',
                              style: const TextStyle(
                                  color: AppColors.inkSoft, fontSize: 13)),
                        ],
                      ),
                      const SizedBox(height: 18),
                      _priceAndStock(p, disc),
                      const SizedBox(height: 24),
                      _sectionTitle('Deskripsi'),
                      const SizedBox(height: 8),
                      Text(p.description,
                          style: const TextStyle(
                              height: 1.55, color: AppColors.ink)),
                      if (p.tags.isNotEmpty) ...[
                        const SizedBox(height: 14),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: p.tags
                              .map((t) => _pill('#$t',
                                  Colors.white.withValues(alpha: 0.85)))
                              .toList(),
                        ),
                      ],
                      const SizedBox(height: 24),
                      _sectionTitle('Info produk'),
                      const SizedBox(height: 12),
                      _infoRow(
                        _infoTile(Icons.verified_user_outlined, 'Garansi',
                            p.warrantyInformation, AppColors.lavender),
                        _infoTile(Icons.local_shipping_outlined, 'Pengiriman',
                            p.shippingInformation, AppColors.sky),
                      ),
                      const SizedBox(height: 12),
                      _infoRow(
                        _infoTile(Icons.assignment_return_outlined, 'Retur',
                            p.returnPolicy, AppColors.mint),
                        _infoTile(Icons.shopping_bag_outlined, 'Min. order',
                            '${p.minimumOrderQuantity}', AppColors.lemon),
                      ),
                      const SizedBox(height: 28),
                      _sectionTitle('Review (${p.reviews.length})'),
                      const SizedBox(height: 12),
                      if (p.reviews.isEmpty)
                        const Text('Belum ada review',
                            style: TextStyle(color: AppColors.inkSoft)),
                      for (var i = 0; i < p.reviews.length; i++)
                        _reviewCard(i, p.reviews[i]),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _pill(String text, Color color) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          text,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
        ),
      );
}