import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class ProductsView extends StatelessWidget {
  const ProductsView({super.key});

  void _showAddProductDialog(BuildContext context) {
    final nameController = TextEditingController();
    final priceController = TextEditingController();
    final categoryController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF2A2A2A),
          title: const Text('Add New Product', style: TextStyle(color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameController, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: 'Product Name', labelStyle: TextStyle(color: Colors.grey))),
              TextField(controller: categoryController, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: 'Category (e.g., Toner, Gear)', labelStyle: TextStyle(color: Colors.grey))),
              TextField(controller: priceController, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: 'Price', labelStyle: TextStyle(color: Colors.grey))),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel', style: TextStyle(color: Colors.grey))),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF63D392), foregroundColor: Colors.black),
              onPressed: () async {
                // Firebase me Product Save karna
                if(nameController.text.isNotEmpty) {
                  await FirebaseDatabase.instance.ref().child('products').push().set({
                    'name': nameController.text,
                    'category': categoryController.text,
                    'price': priceController.text,
                    'is_active': true,
                  });
                  Navigator.pop(context);
                }
              },
              child: const Text('Save Product'),
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
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF63D392), foregroundColor: Colors.black, padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15)),
              onPressed: () => _showAddProductDialog(context),
              icon: const Icon(Icons.add),
              label: const Text('Add Product', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
        const SizedBox(height: 30),
        
        Expanded(
          child: StreamBuilder(
            stream: FirebaseDatabase.instance.ref().child('products').onValue,
            builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
              if (!snapshot.hasData || snapshot.data!.snapshot.value == null) {
                return const Center(child: Text('No products added yet.', style: TextStyle(color: Colors.grey, fontSize: 18)));
              }

              Map<dynamic, dynamic> productsMap = snapshot.data!.snapshot.value as Map<dynamic, dynamic>;
              List<Map<String, dynamic>> productsList = [];
              productsMap.forEach((key, value) {
                productsList.add(Map<String, dynamic>.from(value));
              });

              return GridView.builder(
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(maxCrossAxisExtent: 300, childAspectRatio: 1.5, crossAxisSpacing: 20, mainAxisSpacing: 20),
                itemCount: productsList.length,
                itemBuilder: (context, index) {
                  final prod = productsList[index];
                  return Card(
                    color: const Color(0xFF2A2A2A),
                    child: Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(prod['name'] ?? '', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold), maxLines: 2),
                          const SizedBox(height: 10),
                          Text('Category: ${prod['category']}', style: const TextStyle(color: Colors.grey)),
                          const Spacer(),
                          Text('₹ ${prod['price']}', style: const TextStyle(color: Color(0xFF63D392), fontSize: 20, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
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