import 'package:dio/dio.dart';
import '../models/product_model.dart';

class ApiServiceProducts {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: 'https://dummyjson.com',
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 15),
    headers: {'Content-Type': 'application/json'},
  ));

  /// Satu method untuk: GET all (limit/skip/select), SEARCH, BY CATEGORY, SORT.
  Future<ProductsResponse> getProducts({
    int limit = 20,
    int skip = 0,
    String query = '',
    String category = '',
    String? sortBy,
    String order = 'asc',
    String? select,
  }) async {
    String path = '/products';
    final params = <String, dynamic>{'limit': limit, 'skip': skip};
    if (query.trim().isNotEmpty) {
      path = '/products/search';
      params['q'] = query.trim();
    } else if (category.isNotEmpty) {
      path = '/products/category/$category';
    }
    if (sortBy != null && sortBy.isNotEmpty) {
      params['sortBy'] = sortBy;
      params['order'] = order;
    }
    if (select != null) params['select'] = select;
    final res = await _dio.get(path, queryParameters: params);
    return ProductsResponse.fromJson(res.data);
  }

  Future<Product> getProduct(int id) async {
    final res = await _dio.get('/products/$id');
    return Product.fromJson(res.data);
  }

  Future<List<Category>> getCategories() async {
    final res = await _dio.get('/products/categories');
    return (res.data as List)
        .map((e) => Category.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<List<String>> getCategoryList() async {
    final res = await _dio.get('/products/category-list');
    return (res.data as List).map((e) => e.toString()).toList();
  }

  Future<Product> addProduct(Map<String, dynamic> data) async {
    final res = await _dio.post('/products/add', data: data);
    return Product.fromJson(res.data);
  }

  Future<Product> updateProduct(int id, Map<String, dynamic> data) async {
    final res = await _dio.put('/products/$id', data: data);
    return Product.fromJson(res.data);
  }

  Future<Product> patchProduct(int id, Map<String, dynamic> data) async {
    final res = await _dio.patch('/products/$id', data: data);
    return Product.fromJson(res.data);
  }

  Future<Product> deleteProduct(int id) async {
    final res = await _dio.delete('/products/$id');
    return Product.fromJson(res.data);
  }
}
