import 'package:flutter/material.dart';
import 'orders_view.dart';    
import 'products_view.dart'; 
import 'downloads_view.dart'; // 🟢 1. Naya file import kiya

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('COPYSTAR CRM', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.5)),
        backgroundColor: const Color(0xFF121212),
        elevation: 2,
      ),
      body: Row(
        children: [
          Container(
            width: 250,
            color: const Color(0xFF121212),
            child: Column(
              children: [
                const SizedBox(height: 20),
                _buildMenuButton(0, Icons.shopping_cart, 'Live COD Orders'),
                _buildMenuButton(1, Icons.inventory_2, 'Manage Products'),
                _buildMenuButton(2, Icons.download, 'Software Downloads'), // 🟢 2. Naya button add kiya
              ],
            ),
          ),
          Expanded(
            child: Container(
              color: const Color(0xFF181818),
              padding: const EdgeInsets.all(30),
              // 🟢 3. Teesri screen dikhane ka logic add kiya
              child: _selectedIndex == 0 
                  ? const OrdersView() 
                  : _selectedIndex == 1 
                      ? const ProductsView()
                      : const DownloadsView(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuButton(int index, IconData icon, String title) {
    final isSelected = _selectedIndex == index;
    return ListTile(
      leading: Icon(icon, color: isSelected ? const Color(0xFF63D392) : Colors.grey),
      title: Text(title, style: TextStyle(
        color: isSelected ? const Color(0xFF63D392) : Colors.grey, 
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal
      )),
      selected: isSelected,
      onTap: () => setState(() => _selectedIndex = index),
    );
  }
}