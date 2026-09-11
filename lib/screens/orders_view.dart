import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_database/firebase_database.dart';
import 'dart:math';

class OrdersView extends StatefulWidget {
  const OrdersView({super.key});

  @override
  State<OrdersView> createState() => _OrdersViewState();
}

class _OrdersViewState extends State<OrdersView> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  String _formatDate(String? isoString) {
    if (isoString == null) return 'Time not available';
    try {
      DateTime dt = DateTime.parse(isoString).toLocal();
      int hour = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
      String ampm = dt.hour >= 12 ? "PM" : "AM";
      String minute = dt.minute.toString().padLeft(2, '0');
      return '${dt.day}/${dt.month}/${dt.year} at $hour:$minute $ampm';
    } catch (e) {
      return 'Time not available';
    }
  }

  String _getOrGenerateOrderId(Map<dynamic, dynamic> order, String firebaseKey) {
    if (order['order_id'] != null && order['order_id'].toString().isNotEmpty) {
      return order['order_id'];
    }
    int randomNum = 1000 + Random().nextInt(9000);
    String generatedId = 'CS-2026-$randomNum';
    
    FirebaseDatabase.instance.ref().child('cod_orders').child(firebaseKey).update({
      'order_id': generatedId,
    });
    
    return generatedId;
  }

  void _updateOrderStatus(String orderId, String newStatus) {
    FirebaseDatabase.instance.ref().child('cod_orders').child(orderId).update({
      'status': newStatus,
    });
  }

  // 🟢 NAYA: Manual Order Create karne ka Dialog Form
  void _showCreateManualOrderDialog(BuildContext context) {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    final addressController = TextEditingController();
    final productController = TextEditingController();
    final qtyController = TextEditingController(text: '1');
    final amountController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF2A2A2A),
          title: const Text('Create Manual Order', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: SizedBox(
              width: 400,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(labelText: 'Customer Name', labelStyle: TextStyle(color: Colors.grey)),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: phoneController,
                    keyboardType: TextInputType.phone,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(labelText: 'Phone Number', labelStyle: TextStyle(color: Colors.grey)),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: addressController,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(labelText: 'Delivery Address', labelStyle: TextStyle(color: Colors.grey)),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: productController,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(labelText: 'Product Name', labelStyle: TextStyle(color: Colors.grey)),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: qtyController,
                          keyboardType: TextInputType.number,
                          style: const TextStyle(color: Colors.white),
                          decoration: const InputDecoration(labelText: 'Quantity', labelStyle: TextStyle(color: Colors.grey)),
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: TextField(
                          controller: amountController,
                          keyboardType: TextInputType.number,
                          style: const TextStyle(color: Colors.white),
                          decoration: const InputDecoration(labelText: 'Total Amount (₹)', labelStyle: TextStyle(color: Colors.grey)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF63D392), foregroundColor: Colors.black),
              onPressed: () async {
                if (nameController.text.isNotEmpty && productController.text.isNotEmpty) {
                  int randomNum = 1000 + Random().nextInt(9000);
                  String manualOrderId = 'CS-2026-$randomNum';

                  // Firebase me naya order push karna
                  await FirebaseDatabase.instance.ref().child('cod_orders').push().set({
                    'customer_name': nameController.text.trim(),
                    'phone': phoneController.text.trim(),
                    'address': addressController.text.trim(),
                    'location': 'Manual Order',
                    'order_id': manualOrderId,
                    'status': 'Pending',
                    'total_amount': amountController.text.trim().isEmpty ? '0' : amountController.text.trim(),
                    'timestamp': DateTime.now().toIso8601String(),
                    'ordered_items': [
                      {
                        'item_name': productController.text.trim(),
                        'quantity': int.tryParse(qtyController.text) ?? 1,
                      }
                    ]
                  });

                  Navigator.pop(context);
                }
              },
              child: const Text('Save Order', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  void _showSetAmountDialog(BuildContext context, String orderId) {
    final TextEditingController amountController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF2A2A2A),
          title: const Text('Enter Total Amount', style: TextStyle(color: Colors.white)),
          content: TextField(
            controller: amountController,
            keyboardType: TextInputType.number,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              labelText: 'Total Amount (₹)',
              labelStyle: TextStyle(color: Colors.grey),
              enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
              focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF63D392))),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF63D392), foregroundColor: Colors.black),
              onPressed: () async {
                if (amountController.text.isNotEmpty) {
                  await FirebaseDatabase.instance.ref().child('cod_orders').child(orderId).update({
                    'total_amount': amountController.text.trim(),
                  });
                  Navigator.pop(context);
                }
              },
              child: const Text('Save Amount', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  String _extractProductNames(dynamic orderedItems, dynamic oldProductNames) {
    if (orderedItems != null && orderedItems is List) {
      List<String> itemsList = [];
      for (var item in orderedItems) {
        if (item != null && item is Map) {
          String name = item['item_name'] ?? 'Unknown Item';
          String qty = item['quantity']?.toString() ?? '1';
          itemsList.add('• $name (Qty: $qty)');
        }
      }
      return itemsList.join('\n'); 
    } else if (oldProductNames != null) {
      return oldProductNames.toString();
    }
    return "No Items Found";
  }

  Widget _buildBadge(String text, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: color, width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 8),
          Text(text, style: TextStyle(color: color, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // --- HEADER WITH MANUAL ORDER BUTTON & SEARCH ---
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Text('Customer COD Orders', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(width: 20),
                // 🟢 MANUAL ORDER BUTTON
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF63D392),
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
                  ),
                  onPressed: () => _showCreateManualOrderDialog(context),
                  icon: const Icon(Icons.add_shopping_cart, size: 18),
                  label: const Text('Create Manual Order', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            
            SizedBox(
              width: 280,
              child: TextField(
                controller: _searchController,
                style: const TextStyle(color: Colors.white),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value.trim().toLowerCase();
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Search Order ID...',
                  hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 13),
                  prefixIcon: const Icon(Icons.search, color: Colors.grey),
                  filled: true,
                  fillColor: const Color(0xFF2A2A2A),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                  contentPadding: const EdgeInsets.symmetric(vertical: 0),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        
        Expanded(
          child: StreamBuilder(
            stream: FirebaseDatabase.instance.ref().child('cod_orders').onValue,
            builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) {
              if (snapshot.hasError) return const Text('Error loading orders', style: TextStyle(color: Colors.red));
              if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator(color: Color(0xFF63D392)));
              
              if (!snapshot.hasData || snapshot.data!.snapshot.value == null) {
                return const Center(child: Text('No orders found.', style: TextStyle(color: Colors.grey, fontSize: 18)));
              }

              Map<dynamic, dynamic> ordersMap = snapshot.data!.snapshot.value as Map<dynamic, dynamic>;
              List<Map<String, dynamic>> ordersList = [];
              
              ordersMap.forEach((key, value) {
                Map<String, dynamic> order = Map<String, dynamic>.from(value);
                order['id'] = key;
                order['generated_order_id'] = _getOrGenerateOrderId(order, key);
                ordersList.add(order);
              });

              if (_searchQuery.isNotEmpty) {
                ordersList = ordersList.where((order) {
                  String orderId = order['generated_order_id'].toString().toLowerCase();
                  String customerName = order['customer_name'].toString().toLowerCase();
                  return orderId.contains(_searchQuery) || customerName.contains(_searchQuery);
                }).toList();
              }

              if (ordersList.isEmpty) {
                return const Center(child: Text('No matching orders found.', style: TextStyle(color: Colors.grey, fontSize: 16)));
              }

              ordersList.sort((a, b) => b['timestamp'].toString().compareTo(a['timestamp'].toString()));

              return ListView.builder(
                itemCount: ordersList.length,
                itemBuilder: (context, index) {
                  final order = ordersList[index];
                  String orderKey = order['id'];
                  String uniqueOrderId = order['generated_order_id'];
                  String orderTime = _formatDate(order['timestamp']);
                  String currentStatus = order['status'] ?? 'Pending';
                  String products = _extractProductNames(order['ordered_items'], order['product_names']);
                  
                  var rawAmount = order['total_amount'];
                  bool hasAmount = rawAmount != null && rawAmount.toString().isNotEmpty && rawAmount.toString() != "0";
                  String totalAmount = hasAmount ? rawAmount.toString() : "Not Set";

                  return Container(
                    margin: const EdgeInsets.only(bottom: 25),
                    decoration: BoxDecoration(
                      color: const Color(0xFF232323),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white10),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.4), blurRadius: 10, offset: const Offset(0, 5))
                      ]
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(25),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 24,
                                    backgroundColor: const Color(0xFF63D392).withOpacity(0.2),
                                    child: const Icon(Icons.shopping_bag, color: Color(0xFF63D392), size: 24),
                                  ),
                                  const SizedBox(width: 15),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(order['customer_name'] ?? 'Unknown Customer', style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                                          const SizedBox(width: 12),
                                          
                                          InkWell(
                                            onTap: () {
                                              Clipboard.setData(ClipboardData(text: uniqueOrderId));
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(
                                                  content: Text('Order ID Copied: $uniqueOrderId'),
                                                  duration: const Duration(seconds: 2),
                                                  backgroundColor: const Color(0xFF4A90E2),
                                                ),
                                              );
                                            },
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                              decoration: BoxDecoration(
                                                color: Colors.blue.withOpacity(0.15),
                                                borderRadius: BorderRadius.circular(6),
                                                border: Border.all(color: Colors.blue.shade300, width: 1),
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Text(uniqueOrderId, style: const TextStyle(color: Color(0xFF4A90E2), fontWeight: FontWeight.bold, fontSize: 13)),
                                                  const SizedBox(width: 6),
                                                  const Icon(Icons.copy, size: 14, color: Color(0xFF4A90E2)),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 5),
                                      Row(
                                        children: [
                                          const Icon(Icons.phone, size: 14, color: Colors.grey),
                                          const SizedBox(width: 5),
                                          Text(order['phone'] ?? 'No Phone', style: const TextStyle(color: Colors.grey, fontSize: 14)),
                                          const SizedBox(width: 15),
                                          const Icon(Icons.access_time, size: 14, color: Colors.grey),
                                          const SizedBox(width: 5),
                                          Text(orderTime, style: const TextStyle(color: Colors.grey, fontSize: 14)),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              if (currentStatus == 'Delivered') 
                                _buildBadge('DELIVERED', Colors.green, Icons.check_circle)
                              else if (currentStatus == 'Cancelled')
                                _buildBadge('CANCELLED', Colors.red, Icons.cancel)
                              else 
                                _buildBadge('PENDING', Colors.orange, Icons.hourglass_empty),
                            ],
                          ),
                          
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 20),
                            child: Divider(color: Colors.white10, height: 1),
                          ),

                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 1,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Delivery Address', style: TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.bold, letterSpacing: 1)),
                                    const SizedBox(height: 10),
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Icon(Icons.location_on, color: Color(0xFF4A90E2), size: 18),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text('${order['address'] ?? ''}\n${order['location'] ?? ''}', style: const TextStyle(color: Colors.white70, fontSize: 15, height: 1.4)),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 20),
                              Expanded(
                                flex: 2,
                                child: Container(
                                  padding: const EdgeInsets.all(15),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF1A1A1A),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: Colors.white10)
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text('Ordered Items', style: TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.bold, letterSpacing: 1)),
                                      const SizedBox(height: 10),
                                      Text(products, style: const TextStyle(color: Color(0xFF4A90E2), fontSize: 15, height: 1.5)),
                                      const Padding(
                                        padding: EdgeInsets.symmetric(vertical: 12),
                                        child: Divider(color: Colors.white12, height: 1),
                                      ),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text('Total Amount:', style: TextStyle(color: Colors.white70, fontSize: 16)),
                                          Row(
                                            children: [
                                              Text(
                                                hasAmount ? '₹$totalAmount' : 'Not Set', 
                                                style: TextStyle(
                                                  color: hasAmount ? const Color(0xFF63D392) : Colors.orange, 
                                                  fontWeight: FontWeight.bold, 
                                                  fontSize: 20
                                                ),
                                              ),
                                              const SizedBox(width: 10),
                                              if (!hasAmount)
                                                ElevatedButton.icon(
                                                  style: ElevatedButton.styleFrom(
                                                    backgroundColor: Colors.orange,
                                                    foregroundColor: Colors.black,
                                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                                  ),
                                                  onPressed: () => _showSetAmountDialog(context, orderKey),
                                                  icon: const Icon(Icons.add, size: 16),
                                                  label: const Text('Add Amount', style: TextStyle(fontSize: 12)),
                                                ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),

                          if (currentStatus != 'Delivered' && currentStatus != 'Cancelled') ...[
                            const SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                OutlinedButton.icon(
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: Colors.red,
                                    side: const BorderSide(color: Colors.red),
                                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                                  onPressed: () => _updateOrderStatus(orderKey, 'Cancelled'),
                                  icon: const Icon(Icons.close, size: 18),
                                  label: const Text('Cancel Order', style: TextStyle(fontWeight: FontWeight.bold)),
                                ),
                                const SizedBox(width: 15),
                                ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF63D392),
                                    foregroundColor: Colors.black,
                                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                                  onPressed: () => _updateOrderStatus(orderKey, 'Delivered'),
                                  icon: const Icon(Icons.local_shipping, size: 18),
                                  label: const Text('Mark as Delivered', style: TextStyle(fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ),
                          ],
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