import 'package:dio/dio.dart';

class APIProvider {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: "http://10.0.2.2:3000",
      contentType: 'application/json',
      responseType: ResponseType.json,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      validateStatus: (status) => status! < 500,
    ),
  );

  // Common headers
  final Map<String, String> _headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  // Get all products
  Future<Response> getProducts() async {
    return await _dio.get("/products", options: Options(headers: _headers));
  }

  // Get single product by ID
  Future<Response> getProductById(int id) async {
    return await _dio.get("/products/$id", options: Options(headers: _headers));
  }

  // Create new product
  Future<Response> createProduct({
    required String productName,
    required double price,
    required int stock,
  }) async {
    final data = {"productname": productName, "price": price, "stock": stock};

    return await _dio.post(
      "/products",
      data: data,
      options: Options(headers: _headers),
    );
  }

  // Update product
  Future<Response> updateProduct(
    int id, {
    required String productName,
    required double price,
    required int stock,
  }) async {
    final data = {"productname": productName, "price": price, "stock": stock};

    return await _dio.put(
      "/products/$id",
      data: data,
      options: Options(headers: _headers),
    );
  }

  // Delete product
  Future<Response> deleteProduct(int id) async {
    return await _dio.delete(
      "/products/$id",
      options: Options(headers: _headers),
    );
  }
}
