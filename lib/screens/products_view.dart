import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class ProductsView extends StatelessWidget {
  const ProductsView({super.key});

  // 🟢 UPDATED: Isme selectedCategory pass karne ka option add kiya hai auto-fill ke liye
  void _showAddProductDialog(BuildContext context, {String? selectedCategory}) {
    final nameController = TextEditingController();
    final categoryController = TextEditingController(text: selectedCategory ?? ''); // Auto-fill category
    final priceController = TextEditingController();
    final imageUrlController = TextEditingController();
    final descriptionController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF2A2A2A),
          title: const Text('Add New Product', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: SizedBox(
              width: 400,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController, 
                    style: const TextStyle(color: Colors.white), 
                    decoration: const InputDecoration(labelText: 'Product Name (e.g. Cyan Toner 1Kg)', labelStyle: TextStyle(color: Colors.grey))
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: categoryController, 
                    style: const TextStyle(color: Colors.white), 
                    decoration: const InputDecoration(labelText: 'Category Title (e.g. Color Toner)', labelStyle: TextStyle(color: Colors.grey))
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: descriptionController, 
                    style: const TextStyle(color: Colors.white), 
                    decoration: const InputDecoration(labelText: 'Description', labelStyle: TextStyle(color: Colors.grey))
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: imageUrlController, 
                    style: const TextStyle(color: Colors.white), 
                    decoration: const InputDecoration(labelText: 'Image URL', labelStyle: TextStyle(color: Colors.grey))
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: priceController, 
                    style: const TextStyle(color: Colors.white), 
                    decoration: const InputDecoration(labelText: 'Price (₹)', labelStyle: TextStyle(color: Colors.grey))
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context), 
              child: const Text('Cancel', style: TextStyle(color: Colors.grey))
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF63D392), foregroundColor: Colors.black),
              onPressed: () async {
                if(nameController.text.isNotEmpty && categoryController.text.isNotEmpty) {
                  await FirebaseDatabase.instance.ref().child('products').push().set({
                    'name': nameController.text.trim(),
                    'category': categoryController.text.trim(),
                    'description': descriptionController.text.trim(),
                    'image_url': imageUrlController.text.trim(),
                    'price': priceController.text.trim(),
                    'is_active': true,
                    'timestamp': DateTime.now().toIso8601String(),
                  });
                  Navigator.pop(context);
                }
              },
              child: const Text('Save Product', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  void _showEditProductDialog(BuildContext context, Map<String, dynamic> product) {
    final nameController = TextEditingController(text: product['name']);
    final categoryController = TextEditingController(text: product['category']);
    final priceController = TextEditingController(text: product['price']);
    final imageUrlController = TextEditingController(text: product['image_url']);
    final descriptionController = TextEditingController(text: product['description']);
    final String productId = product['id'];

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF2A2A2A),
          title: const Text('Edit Product', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: SizedBox(
              width: 400,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(controller: nameController, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: 'Product Name', labelStyle: TextStyle(color: Colors.grey))),
                  const SizedBox(height: 10),
                  TextField(controller: categoryController, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: 'Category Title', labelStyle: TextStyle(color: Colors.grey))),
                  const SizedBox(height: 10),
                  TextField(controller: descriptionController, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: 'Description', labelStyle: TextStyle(color: Colors.grey))),
                  const SizedBox(height: 10),
                  TextField(controller: imageUrlController, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: 'Image URL', labelStyle: TextStyle(color: Colors.grey))),
                  const SizedBox(height: 10),
                  TextField(controller: priceController, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: 'Price (₹)', labelStyle: TextStyle(color: Colors.grey))),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context), 
              child: const Text('Cancel', style: TextStyle(color: Colors.grey))
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4A90E2), foregroundColor: Colors.white),
              onPressed: () async {
                if(nameController.text.isNotEmpty) {
                  await FirebaseDatabase.instance.ref().child('products').child(productId).update({
                    'name': nameController.text.trim(),
                    'category': categoryController.text.trim(),
                    'description': descriptionController.text.trim(),
                    'image_url': imageUrlController.text.trim(),
                    'price': priceController.text.trim(),
                  });
                  Navigator.pop(context);
                }
              },
              child: const Text('Update Product', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  void _deleteProduct(BuildContext context, String productId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF2A2A2A),
          title: const Text('Delete Product', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          content: const Text('Are you sure you want to delete this product? This action cannot be undone.', style: TextStyle(color: Colors.grey)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, foregroundColor: Colors.white),
              onPressed: () async {
                await FirebaseDatabase.instance.ref().child('products').child(productId).remove();
                Navigator.pop(context);
              },
              child: const Text('Delete', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Product Catalog', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF63D392), 
                foregroundColor: Colors.black, 
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15)
              ),
              onPressed: () => _showAddProductDialog(context),
              icon: const Icon(Icons.add),
              label: const Text('Add New Category & Product', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
        const SizedBox(height: 30),
        
        Expanded(
          child: StreamBuilder(
            stream: FirebaseDatabase.instance.ref().child('products').onValue,
            builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator(color: Color(0xFF63D392)));
              if (!snapshot.hasData || snapshot.data!.snapshot.value == null) {
                return const Center(child: Text('No products added yet.', style: TextStyle(color: Colors.grey, fontSize: 18)));
              }

              Map<dynamic, dynamic> productsMap = snapshot.data!.snapshot.value as Map<dynamic, dynamic>;
              Map<String, List<Map<String, dynamic>>> groupedProducts = {};
              
              productsMap.forEach((key, value) {
                var prod = Map<String, dynamic>.from(value);
                prod['id'] = key;
                String category = prod['category'] ?? 'Uncategorized';
                
                if (!groupedProducts.containsKey(category)) {
                  groupedProducts[category] = [];
                }
                groupedProducts[category]!.add(prod);
              });

              List<String> categories = groupedProducts.keys.toList();
              categories.sort();

              return ListView.builder(
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  String category = categories[index];
                  List<Map<String, dynamic>> categoryProducts = groupedProducts[category]!;

                  return Column(
                    children: [
                      // 🟢 UPDATED: Category Title ke bagal mein "+ Add Here" ka button
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 25),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              category,
                              style: const TextStyle(
                                fontSize: 26, 
                                fontWeight: FontWeight.bold, 
                                color: Color(0xFF4A90E2)
                              ),
                            ),
                            const SizedBox(width: 15),
                            InkWell(
                              onTap: () => _showAddProductDialog(context, selectedCategory: category),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF63D392).withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: const Color(0xFF63D392), width: 1.5)
                                ),
                                child: const Row(
                                  children: [
                                    Icon(Icons.add, size: 16, color: Color(0xFF63D392)),
                                    SizedBox(width: 5),
                                    Text('Add Here', style: TextStyle(color: Color(0xFF63D392), fontSize: 12, fontWeight: FontWeight.bold))
                                  ],
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                      
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 450, 
                          childAspectRatio: 2.2, 
                          crossAxisSpacing: 20, 
                          mainAxisSpacing: 20
                        ),
                        itemCount: categoryProducts.length,
                        itemBuilder: (context, prodIndex) {
                          final prod = categoryProducts[prodIndex];
                          String imageUrl = prod['image_url'] ?? '';
                          
                          return Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFF232323),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.white10),
                            ),
                            padding: const EdgeInsets.all(15),
                            child: Row(
                              children: [
                                Container(
                                  width: 90,
                                  height: 90,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF1A1A1A),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: imageUrl.isNotEmpty
                                      ? ClipRRect(
                                          borderRadius: BorderRadius.circular(10),
                                          child: Image.network(imageUrl, fit: BoxFit.cover, errorBuilder: (c, e, s) => const Icon(Icons.image_not_supported, color: Colors.grey)),
                                        )
                                      : const Icon(Icons.water_drop, color: Colors.cyan, size: 40),
                                ),
                                const SizedBox(width: 15),
                                
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            prod['name'] ?? '', 
                                            style: const TextStyle(color: Color(0xFF4A90E2), fontSize: 16, fontWeight: FontWeight.bold), 
                                            maxLines: 2, 
                                            overflow: TextOverflow.ellipsis
                                          ),
                                          const SizedBox(height: 5),
                                          Text(
                                            prod['description'] ?? '', 
                                            style: const TextStyle(color: Colors.grey, fontSize: 12),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                      
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text('₹${prod['price']}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                                          
                                          Row(
                                            children: [
                                              IconButton(
                                                icon: const Icon(Icons.edit, color: Colors.blueAccent, size: 20),
                                                padding: EdgeInsets.zero,
                                                constraints: const BoxConstraints(),
                                                onPressed: () => _showEditProductDialog(context, prod),
                                              ),
                                              const SizedBox(width: 15),
                                              IconButton(
                                                icon: const Icon(Icons.delete, color: Colors.redAccent, size: 20),
                                                padding: EdgeInsets.zero,
                                                constraints: const BoxConstraints(),
                                                onPressed: () => _deleteProduct(context, prod['id']),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 20),
                      const Divider(color: Colors.white10),
                    ],
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}