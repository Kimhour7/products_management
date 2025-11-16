import 'package:flutter/material.dart';
import 'package:products_management_app/providers/product_provider.dart';
import 'package:products_management_app/screens/products_view/products_view.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => ProductProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Product App',
      home: const ProductsView(),
    );
  }
}
