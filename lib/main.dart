import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'models/product_model.dart';
import 'providers/product_provider.dart';
import 'screens/detail_product_screen.dart';
import 'screens/form_product_screen.dart';
import 'screens/list_product_screen.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => ProductProvider(),
      child: const MyApp(),
    ),
  );
}

final GoRouter _router = GoRouter(routes: [
  GoRoute(path: '/', builder: (c, s) => const ListProductScreen()),
  GoRoute(
    path: '/detail/:id',
    builder: (c, s) => DetailProductScreen(id: int.parse(s.pathParameters['id']!)),
  ),
  GoRoute(path: '/add', builder: (c, s) => const FormProductScreen()),
  GoRoute(
    path: '/edit/:id',
    builder: (c, s) => FormProductScreen(product: s.extra as Product),
  ),
]);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'PPB Produk DummyJSON',
      debugShowCheckedModeBanner: false,
         theme: AppTheme.light,
      routerConfig: _router,
    );
  }
}
