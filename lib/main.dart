import 'dart:convert';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My Order',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.deepOrange,
        scaffoldBackgroundColor: const Color(0xFFFDFBF7),
      ),
      home: const OrderScreen(),
    );
  }
}

// 1. Model Class Order (2 điểm)
class Order {
  String item;
  String itemName;
  double price;
  int quantity;
  String currency;

  Order({
    required this.item,
    required this.itemName,
    required this.price,
    required this.quantity,
    required this.currency,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      item: json['Item']?.toString() ?? '',
      itemName: json['ItemName']?.toString() ?? '',
      price: (json['Price'] as num?)?.toDouble() ?? 0.0,
      quantity: (json['Quantity'] as num?)?.toInt() ?? 1,
      currency: json['Currency']?.toString() ?? 'USD',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Item': item,
      'ItemName': itemName,
      'Price': price,
      'Quantity': quantity,
      'Currency': currency,
    };
  }
}

class OrderScreen extends StatefulWidget {
  const OrderScreen({super.key});

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  // Chuỗi JSON mẫu đề bài cung cấp (5 điểm)
  final String rawJson = '''[
    {"Item": "A1000", "ItemName": "Iphone 15", "Price": 1200, "Currency": "USD", "Quantity": 1},
    {"Item": "A1001", "ItemName": "Iphone 16", "Price": 1500, "Currency": "USD", "Quantity": 1}
  ]''';

  List<Order> _allOrders = [];
  List<Order> _filteredOrders = [];

  // Controller cho Form và Search
  final _itemController = TextEditingController();
  final _itemNameController = TextEditingController();
  final _priceController = TextEditingController();
  final _quantityController = TextEditingController();
  final _currencyController = TextEditingController(text: 'USD');
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadInitialOrders();
  }

  // Parse dữ liệu JSON ban đầu
  void _loadInitialOrders() {
    final List<dynamic> listMap = jsonDecode(rawJson);
    setState(() {
      _allOrders = listMap.map((e) => Order.fromJson(e)).toList();
      _filteredOrders = List.from(_allOrders);
    });
  }

  // 3. Thêm Order mới vào danh sách (4 điểm)
  void _addOrder() {
    if (_itemController.text.isEmpty || _itemNameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập đầy đủ thông tin!')),
      );
      return;
    }

    final newOrder = Order(
      item: _itemController.text,
      itemName: _itemNameController.text,
      price: double.tryParse(_priceController.text) ?? 0.0,
      quantity: int.tryParse(_quantityController.text) ?? 1,
      currency: _currencyController.text.isEmpty ? 'USD' : _currencyController.text,
    );

    setState(() {
      _allOrders.add(newOrder);
      _filterOrders(_searchController.text);
    });

    // Reset Form
    _itemController.clear();
    _itemNameController.clear();
    _priceController.clear();
    _quantityController.clear();
  }

  // 4. Tìm kiếm theo ItemName (3 điểm)
  void _filterOrders(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredOrders = List.from(_allOrders);
      } else {
        _filteredOrders = _allOrders
            .where((order) =>
                order.itemName.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  // Xóa đơn hàng
  void _deleteOrder(int index) {
    setState(() {
      final itemToDelete = _filteredOrders[index];
      _allOrders.remove(itemToDelete);
      _filteredOrders.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    final headerColor = const Color(0xFFC7624C); // Tông màu cam mâu theo đề thi

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Header Title
                Text(
                  'My Order',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: headerColor,
                  ),
                ),
                const SizedBox(height: 20),

                // Form nhập thông tin
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField('Item', _itemController),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: _buildTextField('Item Name', _itemNameController),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField('Price', _priceController, isNumber: true),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: _buildTextField('Quantity', _quantityController, isNumber: true),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: _buildTextField('Currency', _currencyController),
                    ),
                  ],
                ),
                const SizedBox(height: 15),

                // Nút Add Item
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    onPressed: _addOrder,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: headerColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    child: const Text('Add Item to Cart'),
                  ),
                ),
                const SizedBox(height: 25),

                // Thanh tìm kiếm (Search Bar)
                TextField(
                  controller: _searchController,
                  onChanged: _filterOrders,
                  decoration: InputDecoration(
                    labelText: 'Search Order by ItemName...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                  ),
                ),
                const SizedBox(height: 20),

                // Bảng danh sách Order (Table UI - Bonus điểm UI)
                Container(
                  color: headerColor,
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                  child: const Row(
                    children: [
                      SizedBox(width: 30, child: Text('Id', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                      Expanded(flex: 2, child: Text('Item', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                      Expanded(flex: 3, child: Text('Item Name', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                      Expanded(flex: 2, child: Text('Quantity', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                      Expanded(flex: 2, child: Text('Price', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                      Expanded(flex: 2, child: Text('Currency', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                      SizedBox(width: 40),
                    ],
                  ),
                ),

                // Danh sách item
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _filteredOrders.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final item = _filteredOrders[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                      child: Row(
                        children: [
                          SizedBox(width: 30, child: Text('${index + 1}')),
                          Expanded(flex: 2, child: Text(item.item)),
                          Expanded(flex: 3, child: Text(item.itemName)),
                          Expanded(flex: 2, child: Text('${item.quantity}')),
                          Expanded(flex: 2, child: Text(item.price.toStringAsFixed(3))),
                          Expanded(flex: 2, child: Text(item.currency)),
                          SizedBox(
                            width: 40,
                            child: IconButton(
                              icon: const Icon(Icons.delete_outline, color: Colors.blueGrey, size: 20),
                              onPressed: () => _deleteOrder(index),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: 40),

                // Footer
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  color: headerColor,
                  child: const Text(
                    'Số 8, Tôn Thất Thuyết, Cầu Giấy, Hà Nội',
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {bool isNumber = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 4),
        SizedBox(
          height: 40,
          child: TextField(
            controller: controller,
            keyboardType: isNumber ? TextInputType.number : TextInputType.text,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            ),
          ),
        ),
      ],
    );
  }
}