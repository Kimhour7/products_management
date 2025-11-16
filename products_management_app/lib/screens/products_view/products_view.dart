import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:products_management_app/providers/product_provider.dart';
import 'package:products_management_app/screens/add_products/add_product_view.dart';
import 'package:products_management_app/screens/update_product/update_product_view.dart';
import 'package:provider/provider.dart';

import '../../models/sort_product_model.dart';
import '../../widgets/custom_text_field.dart';

class ProductsView extends StatefulWidget {
  const ProductsView({super.key});

  @override
  State<ProductsView> createState() => _ProductsViewState();
}

class _ProductsViewState extends State<ProductsView> {
  final TextEditingController searchController = TextEditingController();
  int selectedSortIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductProvider>().fetchProducts();
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Products"),
        centerTitle: true,
        backgroundColor: Colors.grey.shade200,
      ),
      backgroundColor: Colors.grey.shade200,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Consumer<ProductProvider>(
            builder: (context, productProvider, child) {
              final sortProducts = getSortProducts(context);

              return Column(
                children: [
                  //Search Bar
                  CustomTextField(
                    controller: searchController,
                    hintText: "Search Products...",
                    onChanged: (value) {
                      productProvider.setSearchQuery(value);
                    },
                    icon: Icon(Icons.search),
                  ),

                  //Sort Item
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 40,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: sortProducts.length,
                      itemBuilder: (context, index) {
                        var data = sortProducts[index];
                        return GestureDetector(
                          onTap: () => data.functionCallBack?.call(),
                          child: Container(
                            padding: const EdgeInsets.only(left: 10, right: 10),
                            margin: const EdgeInsets.only(right: 10),
                            height: 40,
                            decoration: BoxDecoration(
                              color: data.isClicked == true
                                  ? Colors.blue.shade500
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Center(
                              child: Text(
                                data.text,
                                style: TextStyle(
                                  color: data.isClicked == true
                                      ? Colors.white
                                      : Colors.black,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  //List Products
                  const SizedBox(height: 10),
                  Expanded(child: _buildProductsList(productProvider)),
                ],
              );
            },
          ),
        ),
      ),
      floatingActionButton: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddProductView()),
          );
        },
        child: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: Colors.blue,
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Center(child: Icon(Icons.add, color: Colors.white)),
        ),
      ),
    );
  }

  // Build products list
  Widget _buildProductsList(ProductProvider productProvider) {
    // Show loading
    if (productProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // Show error
    if (productProvider.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              productProvider.error!,
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => productProvider.fetchProducts(),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    // Get filtered products
    final filteredProducts = productProvider.filteredProducts;

    // Show empty state
    if (filteredProducts.isEmpty) {
      return const Center(child: Text('No products available'));
    }

    // Show products list with RefreshIndicator
    return RefreshIndicator(
      onRefresh: _refreshProducts,
      child: ListView.builder(
        itemCount: filteredProducts.length,
        itemBuilder: (context, index) {
          var data = filteredProducts[index];

          // Stock status logic
          Color avatarColor;
          String statusText;

          if (data.stock == null || data.stock == 0) {
            avatarColor = Colors.grey;
            statusText = "Out of Stock";
          } else if (data.stock! <= 15) {
            avatarColor = Colors.red;
            statusText = "Low Stock";
          } else if (data.stock! <= 50) {
            avatarColor = Colors.yellow;
            statusText = "Medium Stock";
          } else {
            avatarColor = Colors.green;
            statusText = "In Stock";
          }

          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            height: 100,
            child: Slidable(
              key: ValueKey(data.productId),

              // End action (swipe from right to left)
              endActionPane: ActionPane(
                motion: const ScrollMotion(),
                extentRatio: 0.4,
                children: [
                  // Edit action
                  SlidableAction(
                    onPressed: (context) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => UpdateProductView(
                            id: data.productId!,
                            productName: data.productName!,
                            price: data.price!,
                            stock: data.stock!,
                          ),
                        ),
                      );
                    },
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    icon: Icons.edit,
                    label: 'Edit',
                    borderRadius: BorderRadius.circular(12),
                  ),
                  // Delete action
                  SlidableAction(
                    onPressed: (context) {
                      _deleteProduct(data.productId, data.productName);
                    },
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    icon: Icons.delete,
                    label: 'Delete',
                    borderRadius: BorderRadius.circular(12),
                  ),
                ],
              ),

              // Product card
              child: Container(
                padding: const EdgeInsets.all(12),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            data.productName ?? "",
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Text(
                          "\$${data.price}",
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.blue,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      "PRO-${data.productId}",
                      style: const TextStyle(color: Colors.grey),
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 5,
                                backgroundColor: avatarColor,
                              ),
                              const SizedBox(width: 5),
                              Text(statusText),
                            ],
                          ),
                        ),
                        Text(
                          "${data.stock ?? 0} units",
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // Sort products
  List<SortProduct> getSortProducts(BuildContext context) {
    return [
      SortProduct(
        text: "Sort By ID",
        functionCallBack: () {
          context.read<ProductProvider>().sortById();
          setState(() {
            selectedSortIndex = 0;
          });
        },
        isClicked: selectedSortIndex == 0,
      ),
      SortProduct(
        text: "Sort By Product Name",
        functionCallBack: () {
          context.read<ProductProvider>().sortByName();
          setState(() {
            selectedSortIndex = 1;
          });
        },
        isClicked: selectedSortIndex == 1,
      ),
      SortProduct(
        text: "Sort By Price",
        functionCallBack: () {
          context.read<ProductProvider>().sortByPrice();
          setState(() {
            selectedSortIndex = 2;
          });
        },
        isClicked: selectedSortIndex == 2,
      ),
      SortProduct(
        text: "Sort By Stock",
        functionCallBack: () {
          context.read<ProductProvider>().sortByStock();
          setState(() {
            selectedSortIndex = 3;
          });
        },
        isClicked: selectedSortIndex == 3,
      ),
    ];
  }

  // Delete product
  Future<void> _deleteProduct(int? productId, String? productName) async {
    if (productId == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Product'),
        content: Text('Are you sure you want to delete "$productName"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final provider = context.read<ProductProvider>();

      // Show loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (loadingContext) =>
            const Center(child: CircularProgressIndicator()),
      );

      bool success = await provider.deleteProduct(productId);

      // Close loading
      if (mounted) Navigator.of(context).pop();

      // Show result
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success
                  ? 'Product deleted successfully'
                  : provider.error ?? 'Failed to delete product',
            ),
            backgroundColor: success ? Colors.green : Colors.red,
          ),
        );
      }
    }
  }

  // Refresh products
  Future<void> _refreshProducts() async {
    await context.read<ProductProvider>().fetchProducts();
  }
}
