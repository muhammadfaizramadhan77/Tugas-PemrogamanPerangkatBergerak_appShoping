import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../services/api_service_products.dart';

class ProductProvider extends ChangeNotifier {
  final ApiServiceProducts _api = ApiServiceProducts();
  static const int _limit = 20;

  final List<Product> _products = [];
  List<String> _categories = [];
  bool _loading = false;
  bool _loadingMore = false;
  String? _error;
  int _total = 0;
  String _query = '';
  String _category = '';
  String _sortBy = '';
  String _order = 'asc';

  List<Product> get products => _products;
  List<String> get categories => _categories;
  bool get loading => _loading;
  bool get loadingMore => _loadingMore;
  String? get error => _error;
  int get total => _total;
  String get selectedCategory => _category;
  String get sortBy => _sortBy;
  String get order => _order;
  bool get hasMore => _products.length < _total;

  /// refresh = true -> mulai dari awal (skip 0). false -> load halaman berikutnya.
  Future<void> fetchProducts({bool refresh = true}) async {
    if (refresh) {
      _loading = true;
      _products.clear();
      _total = 0;
    } else {
      if (_loadingMore || _loading || !hasMore) return;
      _loadingMore = true;
    }
    _error = null;
    notifyListeners();

    try {
      final res = await _api.getProducts(
        limit: _limit,
        skip: refresh ? 0 : _products.length,
        query: _query,
        category: _category,
        sortBy: _sortBy,
        order: _order,
      );
      _products.addAll(res.products);
      _total = res.total;
    } on DioException catch (e) {
      _error = e.message ?? 'Gagal memuat data';
    } catch (e) {
      _error = e.toString();
    }
    _loading = false;
    _loadingMore = false;
    notifyListeners();
  }

  Future<void> fetchCategories() async {
    try {
      _categories = await _api.getCategoryList();
      notifyListeners();
    } catch (_) {}
  }

  Future<void> search(String q) {
    _query = q;
    if (q.trim().isNotEmpty) _category = '';
    return fetchProducts();
  }

  Future<void> filterByCategory(String category) {
    _category = category;
    _query = '';
    return fetchProducts();
  }

  Future<void> sort(String sortBy, String order) {
    _sortBy = sortBy;
    _order = order;
    return fetchProducts();
  }

  Future<void> addProduct(Product p) async {
    final result = await _api.addProduct(p.toJson());
    // API mock tidak menyimpan permanen, jadi ditampilkan lokal saja.
    _products.insert(0, p.copyWith(id: result.id));
    _total++;
    notifyListeners();
  }

  Future<void> updateProduct(int id, Product updated) async {
    try {
      await _api.updateProduct(id, updated.toJson());
    } on DioException catch (e) {
      // Produk baru hasil mock (id > 194) memang 404 di server -> abaikan.
      if (e.response?.statusCode != 404) rethrow;
    }
    final idx = _products.indexWhere((p) => p.id == id);
    if (idx != -1) _products[idx] = updated;
    notifyListeners();
  }

  Future<void> deleteProduct(int id) async {
    try {
      await _api.deleteProduct(id);
    } on DioException catch (e) {
      if (e.response?.statusCode != 404) rethrow;
    }
    _products.removeWhere((p) => p.id == id);
    _total = _total > 0 ? _total - 1 : 0;
    notifyListeners();
  }

  Future<Product> getProduct(int id) => _api.getProduct(id);
}
