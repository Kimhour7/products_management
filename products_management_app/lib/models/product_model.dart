class ProductResponse {
  List<Product>? products;

  ProductResponse({this.products});

  ProductResponse.fromJson(Map<String, dynamic> json) {
    if (json['products'] != null) {
      products = <Product>[];
      json['products'].forEach((v) {
        products!.add(Product.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (products != null) {
      data['products'] = products!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Product {
  int? productId;
  String? productName;
  double? price;
  int? stock;

  Product({this.productId, this.productName, this.price, this.stock});

  Product.fromJson(Map<String, dynamic> json) {
    productId = json['PRODUCTID'];
    productName = json['PRODUCTNAME'];
    price = json['PRICE']?.toDouble();
    stock = json['STOCK'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['PRODUCTID'] = productId;
    data['PRODUCTNAME'] = productName;
    data['PRICE'] = price;
    data['STOCK'] = stock;
    return data;
  }
}
