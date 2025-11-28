import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../List_Manager.dart';
import 'package:auto_size_text/auto_size_text.dart';
import '../models/product.dart';
import '../services/product_service.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;


class ProcessOrderContentD extends StatefulWidget {
  const ProcessOrderContentD({super.key});

  @override
  State<ProcessOrderContentD> createState() => _ProcessOrderContentDState();
}

class _ProcessOrderContentDState extends State<ProcessOrderContentD> {
  // ========= BACKEND PRODUCTS =========
  final _productService = ProductService();
  List<Product> _products = [];
  bool _isLoading = true;
  String? _error;

  // ========= POS STATE =========
  int selectedCategoryId = 0;
  int orderIdCounter = 1;

  List<Map<String, dynamic>> currentOrder = [];

  double get totalAmount {
    return currentOrder.fold(
      0,
      (sum, item) => sum + (item['quantity'] as int) * (item['price'] as double),
    );
  }

  @override
  void initState() {
    super.initState();
    _loadProducts();
    _loadCategoriesFromBackend();
  }

  Future<void> _loadProducts() async {
    try {
      final products = await _productService.fetchProducts();
      setState(() {
        _products = products;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }
  
  Future<void> _loadCategoriesFromBackend() async {
    final url = Uri.parse("http://127.0.0.1:5000/categories");

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);

        setState(() {
          Dash_categories.clear();
          Dash_categories.addAll(
            data.map((cat) {
              final img = cat['image_path'];
              return {
                'id': cat['category_id'] as int,
                'name': cat['category_name'] as String,
                'image': img != null
                    ? 'http://127.0.0.1:5000/static/uploads/$img'
                    : 'assets/App_Icon.png',
              };
            }),
          );
        });
      } else {
        print("LOAD CATEGORIES FAILED: ${response.body}");
      }
    } catch (e) {
      print("ERROR LOADING CATEGORIES (ProcessOrder): $e");
    }
  }

  Product? _findProductById(int id) {
    try {
      return _products.firstWhere((p) => p.productId == id);
    } catch (_) {
      return null;
    }
  }
  Future<bool> _submitTransactionToBackend({
    required double totalAmount,
    required double amountReceived,
  }) async {
    // Build items list for backend
    final items = currentOrder.map((item) {
      return {
        'product_id': item['ID'],              // from currentOrder
        'quantity': item['quantity'],         // int
        'price': item['price'],               // double
      };
    }).toList();

    final body = {
      'user_id': 1,                // TODO: replace with real logged-in user id
      'payment_method': 'cash',    // or dynamic later
      'total_amount': totalAmount,
      'items': items,
    };

    print('SENDING TRANSACTION: ${jsonEncode(body)}');

    try {
      final url = Uri.parse('http://127.0.0.1:5000/transactions'); // desktop/web
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      print('RESPONSE STATUS: ${response.statusCode}');
      print('RESPONSE BODY: ${response.body}');

      if (response.statusCode == 201) {
        // success
        return true;
      } else {
        // show backend error
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Transaction failed: ${response.body}')),
          );
        }
        return false;
      }
    } catch (e) {
      print('ERROR sending transaction: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error sending transaction: $e')),
        );
      }
      return false;
    }
  }

  // ========= PAYMENT / RECEIPT =========
  void showPaymentDialog() {
    TextEditingController paymentCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Enter Payment"),
          content: TextField(
            controller: paymentCtrl,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: "Amount Received",
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                double amountReceived = double.tryParse(paymentCtrl.text) ?? 0;
                if (amountReceived < totalAmount) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Insufficient Payment")),
                  );
                  return;
                }

                Navigator.pop(context); // Close payment input
                showReceiptPreview(amountReceived);
              },
              child: const Text("Next"),
            ),
          ],
        );
      },
    );
  }

  void showReceiptPreview(double amountReceived) {
    double change = amountReceived - totalAmount;
    double finalTotal = totalAmount; // capture before any change

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Receipt Preview"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ...currentOrder.map((item) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("${item['name']} x${item['quantity']}"),
                    Text(
                      "₱${((item['quantity'] as int) * (item['price'] as double)).toStringAsFixed(2)}",
                    ),
                  ],
                );
              }).toList(),
              const Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Total:", style: TextStyle(fontWeight: FontWeight.bold)),
                  Text("₱${finalTotal.toStringAsFixed(2)}"),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Change:", style: TextStyle(fontWeight: FontWeight.bold)),
                  Text("₱${change.toStringAsFixed(2)}"),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () async {
                // 1) Send to backend
                final ok = await _submitTransactionToBackend(
                  totalAmount: finalTotal,
                  amountReceived: amountReceived,
                );

                if (!ok) {
                  // If backend failed, don't clear the order
                  return;
                }

                // 2) Close dialog
                if (mounted) Navigator.pop(context);

                // 3) Save to local history (optional)
                saveToHistory(finalTotal, amountReceived, change);

                // 4) Clear order in UI
                if (mounted) {
                  setState(() {
                    currentOrder.clear();
                  });
                }
              },
              child: const Text("Close"),
            ),
          ],
        );
      },
    );
  }

  void saveToHistory(double total, double received, double change) {
    TransHistory.add({
      'id': orderIdCounter++,
      'cashierName': 'John Doe', // adjust later
      'date': DateTime.now().toString(),
      'total': total.toStringAsFixed(2),
      'items': currentOrder.map((item) {
        return {
          'name': item['name'],
          'price':
              ((item['quantity'] as int) * (item['price'] as double)).toStringAsFixed(2),
          'quantity': item['quantity'],
        };
      }).toList(),
    });

    // NOTE: stock is not yet updated in backend.
    // When you build a /api/create_order endpoint, we’ll update stock there.
  }

  // ========= UI HELPERS =========

  Widget _buildProductGrid() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(child: Text("Failed to load products:\n$_error"));
    }

    final List<Product> filteredProducts = selectedCategoryId == 0
        ? _products
        : _products
            .where((p) => p.categoryId == selectedCategoryId)
            .toList();

    if (filteredProducts.isEmpty) {
      return const Center(child: Text("No products for this category"));
    }

    return GridView.builder(
      padding: const EdgeInsets.all(20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,       // more products per row
          childAspectRatio: 4 / 5, // smaller product box
          crossAxisSpacing: 15,    // smaller gaps
          mainAxisSpacing: 15,
      ),
      itemCount: filteredProducts.length,
      itemBuilder: (context, index) {
        final p = filteredProducts[index];

        return Card(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 3,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox(height: 8),
              // Image placeholder (you can later connect real images)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: p.imagePath != null
                      ? Image.network(
                          'http://127.0.0.1:5000/static/uploads/${p.imagePath}',
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.broken_image, size: 40),
                        )
                      : const Icon(Icons.image_not_supported, size: 40),
                ),
              ),

              const SizedBox(height: 4),
              Text(
                p.productName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    fontWeight: FontWeight.w600, fontSize: 16),
              ),
              Text("Stock: ${p.stockQuantity}"),
              Text("₱${p.price.toStringAsFixed(2)}"),
              const SizedBox(height: 4),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    final idx = currentOrder
                        .indexWhere((item) => item['ID'] == p.productId);
                    int currentQty =
                        idx >= 0 ? currentOrder[idx]['quantity'] as int : 0;

                    if (currentQty + 1 > p.stockQuantity) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Cannot add more than available stock"),
                        ),
                      );
                      return;
                    }

                    if (idx >= 0) {
                      currentOrder[idx]['quantity'] = currentQty + 1;
                    } else {
                      currentOrder.add({
                        'ID': p.productId,
                        'name': p.productName,
                        'price': p.price,
                        'quantity': 1,
                      });
                    }
                  });
                },
                child: const Text("Add"),
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  // ========= BUILD =========
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // LEFT: products + categories
        Flexible(
          flex: 2,
          child: Column(
            children: [
              // Products list
              Container(
                margin: const EdgeInsets.only(left: 50),
                height: 600,
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.grey,
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: Offset(-1, 4),
                    ),
                  ],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: _buildProductGrid(),
              ),

              // Categories row (still using global Dash_categories)
              Container(
                margin:
                    const EdgeInsets.only(left: 50, right: 10, top: 20),
                width: 1200,
                height: 300,
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: ProCategoriesBuilder(
                  selectedCategoryId: selectedCategoryId,
                  onCategorySelected: (id) {
                    setState(() {
                      selectedCategoryId = id;
                    });
                  },
                ),
              ),
            ],
          ),
        ),

        // RIGHT: current order
        Flexible(
          child: Container(
            margin: const EdgeInsets.only(right: 20, left: 20),
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                // Current Order box
                Container(
                  height: 600,
                  decoration: BoxDecoration(
                    color: const Color.fromRGBO(0, 113, 80, 1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      // Header
                      Container(
                        margin: const EdgeInsets.all(10),
                        alignment: Alignment.topCenter,
                        child: AutoSizeText(
                          "Current Order",
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w500,
                            fontSize: 25,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const Divider(color: Colors.white, thickness: 0.4),

                      // Order items
                      Expanded(
                        child: Container(
                          margin: const EdgeInsets.all(10),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: currentOrder.isEmpty
                              ? Center(
                                  child: Text(
                                    "No items added to order yet",
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.9),
                                      fontSize: 18,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                )
                              : ListView.builder(
                                  itemCount: currentOrder.length,
                                  itemBuilder: (context, index) {
                                    final item = currentOrder[index];
                                    return Container(
                                      margin:
                                          const EdgeInsets.only(bottom: 10),
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius:
                                            BorderRadius.circular(10),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          // name
                                          Expanded(
                                            flex: 4,
                                            child: Text(
                                              item['name'],
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),

                                          // minus
                                          IconButton(
                                            onPressed: () {
                                              setState(() {
                                                if (item['quantity'] > 1) {
                                                  item['quantity']--;
                                                } else {
                                                  currentOrder
                                                      .removeAt(index);
                                                }
                                              });
                                            },
                                            icon: const Icon(
                                              Icons.remove_circle,
                                              color: Colors.orange,
                                            ),
                                          ),

                                          // qty
                                          Text(
                                            "x${item['quantity']}",
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),

                                          // plus
                                          IconButton(
                                            onPressed: () {
                                              final prod =
                                                  _findProductById(
                                                      item['ID'] as int);
                                              if (prod != null &&
                                                  item['quantity'] >=
                                                      prod.stockQuantity) {
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  const SnackBar(
                                                    content: Text(
                                                      "Cannot add more than available stock",
                                                    ),
                                                  ),
                                                );
                                                return;
                                              }

                                              setState(() {
                                                item['quantity']++;
                                              });
                                            },
                                            icon: const Icon(
                                              Icons.add_circle,
                                              color: Colors.green,
                                            ),
                                          ),

                                          // line total
                                          Expanded(
                                            flex: 2,
                                            child: Text(
                                              "₱${((item['quantity'] as int) * (item['price'] as double)).toStringAsFixed(2)}",
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),

                                          // delete
                                          IconButton(
                                            onPressed: () {
                                              setState(() {
                                                currentOrder
                                                    .removeAt(index);
                                              });
                                            },
                                            icon: const Icon(
                                              Icons.delete,
                                              color: Colors.red,
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                // Total
                Container(
                  margin: const EdgeInsets.all(10),
                  width: 800,
                  height: 50,
                  decoration: const BoxDecoration(
                    color: Colors.green,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: AutoSizeText(
                      "Total: ₱${totalAmount.toStringAsFixed(2)}",
                      textAlign: TextAlign.left,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w500,
                        fontSize: 25,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),

                // Cancel / Pay buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Flexible(
                      child: Container(
                        margin: const EdgeInsets.all(10),
                        width: 200,
                        height: 40,
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              currentOrder.clear();
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            side: const BorderSide(
                              color: Colors.red,
                              width: 3.0,
                            ),
                            backgroundColor: Colors.white,
                          ),
                          child: AutoSizeText(
                            "Cancel Order",
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w500,
                              fontSize: 15,
                              color: Colors.red,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Flexible(
                      child: Container(
                        margin: const EdgeInsets.all(10),
                        width: 100,
                        height: 40.0,
                        child: ElevatedButton(
                          onPressed: () {
                            if (currentOrder.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("No items in order"),
                                ),
                              );
                              return;
                            }
                            showPaymentDialog();
                          },
                          style: ElevatedButton.styleFrom(
                            side: const BorderSide(
                              color: Colors.green,
                              width: 3.0,
                            ),
                            backgroundColor: Colors.white,
                          ),
                          child: AutoSizeText(
                            "Pay",
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w500,
                              fontSize: 15,
                              color: Colors.green,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
