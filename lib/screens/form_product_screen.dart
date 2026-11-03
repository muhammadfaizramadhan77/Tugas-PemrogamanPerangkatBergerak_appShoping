import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../models/product_model.dart';
import '../providers/product_provider.dart';
import '../theme/app_theme.dart';

/// Dipakai untuk ADD (product == null) dan EDIT (product != null).
class FormProductScreen extends StatefulWidget {
  final Product? product;
  const FormProductScreen({super.key, this.product});

  @override
  State<FormProductScreen> createState() => _FormProductScreenState();
}

class _FormProductScreenState extends State<FormProductScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _title;
  late final TextEditingController _price;
  late final TextEditingController _stock;
  late final TextEditingController _brand;
  late final TextEditingController _category;
  late final TextEditingController _desc;
  bool _saving = false;

  bool get _isEdit => widget.product != null;

  @override
  void initState() {
    super.initState();
    final p = widget.product;
    _title = TextEditingController(text: p?.title ?? '');
    _price = TextEditingController(text: p?.price.toString() ?? '');
    _stock = TextEditingController(text: p?.stock.toString() ?? '');
    _brand = TextEditingController(text: p?.brand ?? '');
    _category = TextEditingController(text: p?.category ?? '');
    _desc = TextEditingController(text: p?.description ?? '');
  }

  @override
  void dispose() {
    for (final c in [_title, _price, _stock, _brand, _category, _desc]) {
      c.dispose();
    }
    super.dispose();
  }

  // Terima koma sebagai pemisah desimal (keyboard Indonesia).
  double? _parsePrice(String? v) =>
      double.tryParse((v ?? '').trim().replaceAll(',', '.'));
  int? _parseStock(String? v) => int.tryParse((v ?? '').trim());

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final prov = context.read<ProductProvider>();
    try {
      if (_isEdit) {
        final updated = widget.product!.copyWith(
          title: _title.text.trim(),
          price: _parsePrice(_price.text)!,
          stock: _parseStock(_stock.text)!,
          brand: _brand.text.trim(),
          category: _category.text.trim(),
          description: _desc.text.trim(),
        );
        await prov.updateProduct(updated.id, updated);
      } else {
        await prov.addProduct(Product(
          id: 0,
          title: _title.text.trim(),
          price: _parsePrice(_price.text)!,
          stock: _parseStock(_stock.text)!,
          brand: _brand.text.trim(),
          category: _category.text.trim(),
          description: _desc.text.trim(),
        ));
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
            _isEdit ? 'Produk diperbarui (mock)' : 'Produk ditambahkan (mock)'),
      ));
      context.go('/');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Gagal: $e')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  String? _required(String? v) =>
      (v == null || v.trim().isEmpty) ? 'Wajib diisi' : null;

  Widget _field({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        validator: validator,
        keyboardType: keyboardType,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: AppColors.inkSoft),
          prefixIcon: Icon(icon),
          alignLabelWithHint: maxLines > 1,
        ),
      ),
    );
  }

  Widget _section({
    required String title,
    required IconData icon,
    required Color tint,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      decoration: BoxDecoration(
        color: tint,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 18, color: AppColors.ink),
              ),
              const SizedBox(width: 10),
              Text(title,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w800)),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppBackdrop(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar:
            AppBar(title: Text(_isEdit ? 'Edit produk' : 'Tambah produk')),
        body: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(4, 0, 4, 14),
                child: Text(
                  _isEdit
                      ? 'Ubah detail produk, lalu simpan.'
                      : 'Isi detail produk baru.',
                  style: const TextStyle(color: AppColors.inkSoft),
                ),
              ),
              _section(
                title: 'Informasi produk',
                icon: Icons.inventory_2_outlined,
                tint: AppColors.peach,
                children: [
                  _field(
                    controller: _title,
                    label: 'Judul',
                    icon: Icons.title_rounded,
                    validator: _required,
                  ),
                  _field(
                    controller: _brand,
                    label: 'Brand',
                    icon: Icons.sell_outlined,
                  ),
                  _field(
                    controller: _category,
                    label: 'Kategori',
                    icon: Icons.category_outlined,
                    validator: _required,
                  ),
                  _field(
                    controller: _desc,
                    label: 'Deskripsi',
                    icon: Icons.notes_rounded,
                    maxLines: 3,
                  ),
                ],
              ),
              const SizedBox(height: 14),
              _section(
                title: 'Harga dan stok',
                icon: Icons.payments_outlined,
                tint: AppColors.mint,
                children: [
                  _field(
                    controller: _price,
                    label: 'Harga (USD)',
                    icon: Icons.attach_money_rounded,
                    keyboardType: const TextInputType.numberWithOptions(
                        decimal: true),
                    validator: (v) {
                      final n = _parsePrice(v);
                      if (n == null) return 'Masukkan angka';
                      if (n < 0) return 'Tidak boleh negatif';
                      return null;
                    },
                  ),
                  _field(
                    controller: _stock,
                    label: 'Stok',
                    icon: Icons.inventory_outlined,
                    keyboardType: TextInputType.number,
                    validator: (v) {
                      final n = _parseStock(v);
                      if (n == null) return 'Masukkan angka bulat';
                      if (n < 0) return 'Tidak boleh negatif';
                      return null;
                    },
                  ),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                height: 54,
                child: ElevatedButton(
                  onPressed: _saving ? null : _save,
                  child: _saving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.check_rounded),
                            SizedBox(width: 8),
                            Text('Simpan',
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700)),
                          ],
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}