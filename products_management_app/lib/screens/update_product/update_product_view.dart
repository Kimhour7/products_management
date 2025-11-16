import 'package:flutter/material.dart';
import 'package:products_management_app/providers/product_provider.dart';
import 'package:products_management_app/screens/products_view/products_view.dart';
import 'package:provider/provider.dart';

class UpdateProductView extends StatefulWidget {
  const UpdateProductView({
    super.key,
    required this.id,
    required this.productName,
    required this.price,
    required this.stock,
  });

  final int id;
  final String productName;
  final double price;
  final int stock;

  @override
  State<UpdateProductView> createState() => _UpdateProductViewState();
}

class _UpdateProductViewState extends State<UpdateProductView> {
  late TextEditingController productNameController;
  late TextEditingController priceController;
  late TextEditingController stockController;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    productNameController = TextEditingController(text: widget.productName);
    priceController = TextEditingController(text: widget.price.toString());
    stockController = TextEditingController(text: widget.stock.toString());
  }

  @override
  void dispose() {
    productNameController.dispose();
    priceController.dispose();
    stockController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Update Product"),
        centerTitle: true,
        backgroundColor: Colors.grey.shade200,
      ),
      backgroundColor: Colors.grey.shade200,
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Product Name",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 5),
                TextFormField(
                  controller: productNameController,
                  decoration: InputDecoration(
                    hintText: "Enter product name",
                    prefixIcon: const Icon(Icons.add_box_rounded),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                    isDense: true,
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter product name';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 15),
                const Text(
                  "Price",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 5),
                TextFormField(
                  controller: priceController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: InputDecoration(
                    hintText: "Enter price",
                    prefixIcon: const Icon(Icons.attach_money),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                    isDense: true,
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter price';
                    }
                    if (double.tryParse(value.trim()) == null) {
                      return 'Please enter valid price';
                    }
                    if (double.parse(value.trim()) <= 0) {
                      return 'Price must be greater than 0';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 15),
                const Text(
                  "Stock",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 5),
                TextFormField(
                  controller: stockController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: "Enter stock",
                    prefixIcon: const Icon(Icons.inventory_2_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                    isDense: true,
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter stock';
                    }
                    if (int.tryParse(value.trim()) == null) {
                      return 'Please enter valid stock number';
                    }
                    if (int.parse(value.trim()) < 0) {
                      return 'Stock cannot be negative';
                    }
                    return null;
                  },
                ),

                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _updateProduct,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: const Center(
                      child: Text(
                        "Update Product",
                        style: TextStyle(color: Colors.white, fontSize: 17),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: () => Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                      builder: (context) => const ProductsView(),
                    ),
                    (Route<dynamic> route) => false,
                  ),
                  child: const SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: Center(
                      child: Text(
                        "Cancel",
                        style: TextStyle(color: Colors.blue, fontSize: 17),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Update product function
  Future<void> _updateProduct() async {
    if (_formKey.currentState!.validate()) {
      final provider = context.read<ProductProvider>();

      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      // Call API
      bool success = await provider.updateProduct(
        widget.id,
        productName: productNameController.text,
        price: double.parse(priceController.text),
        stock: int.parse(stockController.text),
      );

      // Close loading dialog
      if (mounted) Navigator.pop(context);

      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Product updated successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const ProductsView()),
            (Route<dynamic> route) => false,
          );
        }
      } else {
        // Show error message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(provider.error ?? 'Failed to update product'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}
