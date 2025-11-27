import 'package:flutter/material.dart';
import '../List_Manager.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:intl/intl.dart';
import 'package:data_table_2/data_table_2.dart';
import '../models/product.dart';
import '../services/product_service.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:io';
import 'package:image_picker/image_picker.dart';


class InventoryContentD extends StatefulWidget {
  const InventoryContentD({super.key});

  @override
  State<InventoryContentD> createState() => _InventoryContentDState();
}

Future<bool> addProductToInventory({
  required String name,
  required String categoryId,
  required double price,
  required int stock,
  required String unit,
}) async {
  var url = Uri.parse("http://127.0.0.1:5000/api/add_product");  // CHANGE FOR PHONE TESTING

  var request = http.MultipartRequest('POST', url);
  request.fields['product_name'] = name;
  request.fields['category_id'] = categoryId;
  request.fields['price'] = price.toString();
  request.fields['stock_quantity'] = stock.toString();
  request.fields['unit'] = unit;

  try {
    var response = await request.send();
    return response.statusCode == 200;
  } catch (e) {
    print("ERROR: $e");
    return false;
  }
}

class _InventoryContentDState extends State<InventoryContentD> {
  final _productService = ProductService();
  List<Product> _products = [];
  bool _isLoading = true;
  String? _error;
  Timer? _autoRefreshTimer;
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();


  @override
  void initState() {
    super.initState();

    _loadProducts();              // load products
    _loadCategoriesFromBackend(); // load categories from backend

    // 🔁 Auto-refresh products every 5 seconds
    _autoRefreshTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      _loadProducts();  // calls backend and updates _products + UI
    });
  }

  @override
  void dispose() {
    _autoRefreshTimer?.cancel(); // stop the timer when screen is destroyed
    super.dispose();
  }

  Future<void> _loadProducts() async {
    try {
      final products = await _productService.fetchProducts();

      // 👇 DEBUG
      print('---- PRODUCTS FROM API ----');
      for (var p in products) {
        print('${p.productName}  stock: ${p.stockQuantity}');
      }
      print('---------------------------');

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
  Future<void> _pickImage(StateSetter setInner) async {
    final XFile? picked = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80, // compress
    );

    if (picked != null) {
      setInner(() {
        _selectedImage = File(picked.path);
      });
    }
  }

// =============================================================
// CATEGORY CRUD
// =============================================================
  // ---- CALL API TO ADD CATEGORY ----
  Future<int?> addCategoryToBackend(String name) async {
    final url = Uri.parse("http://127.0.0.1:5000/api/add_category");

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"name": name}),  // MUST MATCH BACKEND
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['category_id']; // return new category ID
      } else {
        print("ADD CATEGORY FAILED: ${response.body}");
        return null;
      }
    } catch (e) {
      print("ERROR ADD CATEGORY: $e");
      return null;
    }
  }
  // ---- LOAD CATEGORIES FROM BACKEND INTO Dash_categories ----
  Future<void> _loadCategoriesFromBackend() async {
    final url = Uri.parse("http://127.0.0.1:5000/categories");

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);

        setState(() {
          // Instead of assigning = (which causes error)
          Dash_categories.clear();       // remove old categories
          Dash_categories.addAll(        // add new ones from backend
            data.map((cat) {
              return {
                'id': cat['category_id'] as int,
                'name': cat['category_name'] as String,
                'image': 'assets/App_Icon.png', // default image
              };
            }),
          );
        });
      } 
      else {
        print("LOAD CATEGORIES FAILED: ${response.body}");
      }
    } catch (e) {
      print("ERROR LOADING CATEGORIES: $e");
    }
  }
  Future<bool> deleteCategoryFromBackend(int id) async {
  final url = Uri.parse("http://127.0.0.1:5000/api/categories/$id");

  try {
    final response = await http.delete(url);
    return response.statusCode == 200;
  } catch (e) {
    print("ERROR DELETE CATEGORY: $e");
    return false;
  }
}

  void addCategoryDialog() {
    TextEditingController nameCtrl = TextEditingController();
    TextEditingController imgCtrl  = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Add Category"),
        content: SizedBox(
          height: 160,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: "Category Name"),
              ),
              TextField(
                controller: imgCtrl,
                decoration: const InputDecoration(labelText: "Image Path"),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              final newId = await addCategoryToBackend(nameCtrl.text);

              if (newId != null) {
                Dash_categories.add({
                  'id': newId,                          // real ID from backend
                  'name': nameCtrl.text,
                  'image': imgCtrl.text.isEmpty
                      ? 'assets/App_Icon.png'           // fallback image
                      : imgCtrl.text,                   // custom image path
                });

                setState(() {});
                Navigator.pop(ctx);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Failed to add category"),
                  ),
                );
              }
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }



  void editCategoryDialog(int index) {
    Map<String, dynamic> cat = Dash_categories[index];

    TextEditingController nameCtrl = TextEditingController(text: cat['name']);
    TextEditingController imgCtrl = TextEditingController(text: cat['image']);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("Edit Category"),
        content: SizedBox(
          height: 160,
          child: Column(
            children: [
              TextField(controller: nameCtrl, decoration: InputDecoration(labelText: "Category Name")),
              TextField(controller: imgCtrl, decoration: InputDecoration(labelText: "Image Path")),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              cat['name'] = nameCtrl.text;
              cat['image'] = imgCtrl.text.isEmpty ? 'assets/App_Icon.png' : imgCtrl.text;
              setState(() {});
              Navigator.pop(ctx);
            },
            child: Text("Update"),
          )
        ],
      ),
    );
  }

  Future<void> deleteCategory(int index) async {
    final int catID = Dash_categories[index]['id'] as int;

    // 1) Call backend first
    final ok = await deleteCategoryFromBackend(catID);

    if (!ok) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Failed to delete category from server"),
        ),
      );
      return; // stop, don't remove locally
    }

    // 2) If backend delete is OK, remove locally too
    setState(() {
      for (var p in Pro_product) {
        p['categories'].remove(catID);
      }
      Dash_categories.removeAt(index);
    });
  }

// =============================================================
// PRODUCT CRUD
// =============================================================

  void addProductDialog() {
    TextEditingController nameCtrl = TextEditingController();
    TextEditingController priceCtrl = TextEditingController();
    TextEditingController stockCtrl = TextEditingController();

    List<int> selectedCategories = [];

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setInner) {
            return AlertDialog(
              title: const Text("Add Product"),
              content: SizedBox(
                width: 400,
                height: 500,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // NAME
                      TextField(
                        controller: nameCtrl,
                        decoration: const InputDecoration(labelText: "Name"),
                      ),
                      const SizedBox(height: 10),

                      // IMAGE PICKER (NEW)
                      GestureDetector(
                        onTap: () => _pickImage(setInner),
                        child: Container(
                          height: 150,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey),
                          ),
                          child: _selectedImage == null
                              ? const Center(child: Text("Tap to select image"))
                              : ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.file(
                                    _selectedImage!,
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 15),

                      // PRICE
                      TextField(
                        controller: priceCtrl,
                        decoration: const InputDecoration(labelText: "Price"),
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 15),

                      // STOCK
                      TextField(
                        controller: stockCtrl,
                        decoration: const InputDecoration(labelText: "Stock"),
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 20),

                      const Text("Categories:",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      ...Dash_categories.map((e) {
                        return CheckboxListTile(
                          title: Text(e['name']),
                          value: selectedCategories.contains(e['id']),
                          onChanged: (v) {
                            setInner(() {
                              if (v == true) {
                                selectedCategories.add(e['id']);
                              } else {
                                selectedCategories.remove(e['id']);
                              }
                            });
                          },
                        );
                      }),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text("Cancel"),
                ),
                TextButton(
                  onPressed: () async {
                    final price = double.tryParse(priceCtrl.text) ?? 0;
                    final stock = int.tryParse(stockCtrl.text) ?? 0;

                    if (nameCtrl.text.trim().isEmpty ||
                        price <= 0 ||
                        stock <= 0 ||
                        selectedCategories.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Please fill all fields correctly"),
                        ),
                      );
                      return;
                    }

                    // --- SEND TO BACKEND WITH IMAGE ---
                    var url = Uri.parse("http://127.0.0.1:5000/api/add_product");
                    var request = http.MultipartRequest('POST', url);

                    request.fields['product_name'] = nameCtrl.text;
                    request.fields['category_id'] =
                        selectedCategories.first.toString();
                    request.fields['price'] = price.toString();
                    request.fields['stock_quantity'] = stock.toString();
                    request.fields['unit'] = "pcs";

                    if (_selectedImage != null) {
                      request.files.add(await http.MultipartFile.fromPath(
                        'image',                 // must match backend key
                        _selectedImage!.path,
                      ));
                    }

                    var response = await request.send();

                    if (response.statusCode == 200) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Product added!")),
                      );
                      await _loadProducts();
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                              "Failed: ${response.statusCode}"),
                        ),
                      );
                    }

                    Navigator.pop(ctx);
                  },
                  child: const Text("Save"),
                ),
              ],
            );
          },
        );
      },
    );
  }



void editProductDialog(int index) {
  // use the OLD local list, not _products
  var p = Pro_product[index];

  TextEditingController nameCtrl =
      TextEditingController(text: p['name']);
  TextEditingController imageCtrl =
      TextEditingController(text: p['image']);
  TextEditingController priceCtrl =
      TextEditingController(text: p['price'].toString());
  TextEditingController stockCtrl =
      TextEditingController(text: p['stock'].toString());

  List<int> selectedCategories = List.from(p['categories']);

  showDialog(
    context: context,
    builder: (ctx) =>
        StatefulBuilder(builder: (ctx, setInner) {
      return AlertDialog(
        title: const Text("Edit Product"),
        content: SizedBox( 
          width: 400,
          height: 400,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                    controller: nameCtrl,
                    decoration: const InputDecoration(
                        labelText: "Name")),
                TextField(
                    controller: imageCtrl,
                    decoration: const InputDecoration(
                        labelText: "Image Path")),
                TextField(
                    controller: priceCtrl,
                    decoration: const InputDecoration(
                        labelText: "Price")),
                TextField(
                    controller: stockCtrl,
                    decoration: const InputDecoration(
                        labelText: "Stock")),
                const SizedBox(height: 20),
                const Text("Categories:",
                    style: TextStyle(fontWeight: FontWeight.bold)),
                ...Dash_categories.map((e) {
                  return CheckboxListTile(
                    title: Text(e['name']),
                    value: selectedCategories.contains(e['id']),
                    onChanged: (v) {
                      setInner(() {
                        if (v == true) {
                          selectedCategories.add(e['id']);
                        } else {
                          selectedCategories.remove(e['id']);
                        }
                      });
                    },
                  );
                }).toList(),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Pro_product.add({
                'name': nameCtrl.text,
                'image': imageCtrl.text.isEmpty
                    ? 'assets/App_Icon.png'
                    : imageCtrl.text,
                'categories': selectedCategories,
                'price': int.tryParse(priceCtrl.text) ?? 0,
                'stock': int.tryParse(stockCtrl.text) ?? 0,
                'ID': Pro_product.length,
              });

              setState(() {});
              Navigator.pop(ctx);
            },
            child: const Text("Save"),
          )
        ],
      );
    }),
  );
}

  void deleteProduct(int index) {
    Pro_product.removeAt(index);
    setState(() {});
  }
  void _editProductDialog(Product p) {
    TextEditingController nameCtrl =
        TextEditingController(text: p.productName);
    TextEditingController priceCtrl =
        TextEditingController(text: p.price.toString());
    TextEditingController stockCtrl =
        TextEditingController(text: p.stockQuantity.toString());

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("Edit ${p.productName}"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(labelText: "Name"),
            ),
            TextField(
              controller: priceCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Price"),
            ),
            TextField(
              controller: stockCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Stock"),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              bool ok = await _updateProductToBackend(
                p.productId,
                nameCtrl.text,
                double.tryParse(priceCtrl.text) ?? p.price,
                int.tryParse(stockCtrl.text) ?? p.stockQuantity,
              );

              if (ok) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Product updated!")),
                );
                await _loadProducts(); // refresh products
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Failed to update product")),
                );
              }

              Navigator.pop(ctx);
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  Future<bool> _updateProductToBackend(
    int id,
    String name,
    double price,
    int stock,
  ) async {
    var url = Uri.parse("http://127.0.0.1:5000/api/update_product/$id");

    try {
      var response = await http.put(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "product_name": name,
          "price": price,
          "stock_quantity": stock,
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      print("ERROR EDIT: $e");
      return false;
    }
  }

  String getCategoryNames(List<int> catIDs) {
    return catIDs
        .map((id) => Dash_categories.firstWhere((e) => e['id'] == id)['name'])
        .join(", ");
  }

  Future<void> _deleteProductFromBackend(Product p) async {
    final ok = await _productService.deleteProduct(p.productId);

    if (!mounted) return;

    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Product deleted successfully")),
      );
      await _loadProducts(); // refresh table from backend
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to delete product")),
      );
    }
  }

  
// ==================================================================
// BUILD UI
// ==================================================================

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(50),
      child: Column(
        children: [

          // =============================================================
          // ADD BUTTONS
          // =============================================================
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              // Add Product
              OutlinedButton.icon(
                onPressed: addProductDialog,
                style: OutlinedButton.styleFrom(
                  backgroundColor: Color.fromRGBO(0, 123, 19, 1),
                ),
                icon: Icon(Icons.add, color: Colors.white),
                label: Text("Add Product", style: TextStyle(color: Colors.white)),
              ),

              SizedBox(width: 20),

              // Add Category
              OutlinedButton.icon(
                onPressed: addCategoryDialog,
                style: OutlinedButton.styleFrom(
                  backgroundColor: Colors.blue,
                ),
                icon: Icon(Icons.category, color: Colors.white),
                label: Text("Add Category", style: TextStyle(color: Colors.white)),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // =============================================================
          // TABLE HEADER
          // =============================================================
          Container(
            margin: EdgeInsets.only(top: 10, bottom: 20),
            height: 70,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.black45, width: 0.4),
              color: Colors.white,
            ),
            child: Stack(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 50),
                    child: Text(
                      "Image",
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        fontSize: 20,
                        color: Colors.green,
                      ),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 50),
                    child: Text(
                      "Actions:",
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        fontSize: 20,
                        color: Colors.green,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // =============================================================
          // DATA TABLE
          // =============================================================
          Container(
            height: 700,
            width: 1700,
            child: DataTable2(
              headingRowColor: WidgetStateColor.resolveWith((_) => Colors.white),
              headingRowHeight: 60,
              dataRowHeight: 110,
              minWidth: 1600,
              columns: const [
                DataColumn2(label: Text("ID")),
                DataColumn2(label: Text("Categories")),
                DataColumn2(label: Text("Product")),
                DataColumn2(label: Text("Price")),
                DataColumn2(label: Text("Stock")),
                DataColumn2(label: Text("Date")),
                DataColumn2(label: Text("")),
              ],
              rows: List.generate(_products.length, (index) {
                final p = _products[index];

                return DataRow(
                  cells: [
                    DataCell(Text(p.productId.toString())),
                    DataCell(Text(p.categoryName ?? '')),  // moved here
                    DataCell(Row(children: [
                      Text(
                        p.productName,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ])),
                    DataCell(Text(p.price.toString())),
                    DataCell(Text(p.stockQuantity.toString())),
                    DataCell(Text(
                      DateFormat("yyyy-MM-dd").format(DateTime.now()),
                      ),
                    ),
                    DataCell(
                      Row(
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              _editProductDialog(p);
                            },
                            child: const Text("Edit"),
                          ),
                          const SizedBox(width: 5),
                          ElevatedButton(
                            onPressed: () async {
                              // optional confirm dialog
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  title: const Text("Delete Product"),
                                  content: Text(
                                    "Are you sure you want to delete '${p.productName}'?",
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(ctx, false),
                                      child: const Text("Cancel"),
                                    ),
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(ctx, true),
                                      child: const Text(
                                        "Delete",
                                        style: TextStyle(color: Colors.red),
                                      ),
                                    ),
                                  ],
                                ),
                              );

                              if (confirm == true) {
                                await _deleteProductFromBackend(p);
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                            ),
                            child: const Text(
                              "Delete",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
              ),
            ),
          ),

          const SizedBox(height: 40),

          // =============================================================
          // CATEGORY MANAGER
          // =============================================================
          Text("Manage Categories", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),

          SizedBox(height: 10),

          Wrap(
            spacing: 20,
            children: List.generate(Dash_categories.length, (i) {
              var c = Dash_categories[i];

              return Container(
                padding: EdgeInsets.all(10),
                width: 200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.white,
                  border: Border.all(color: Colors.black26),
                ),
                child: Column(
                  children: [
                    Image.asset(c['image'], height: 60),
                    SizedBox(height: 5),
                    Text(c['name'], style: TextStyle(fontWeight: FontWeight.bold)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(icon: Icon(Icons.edit), onPressed: () => editCategoryDialog(i)),
                        IconButton(icon: Icon(Icons.delete, color: Colors.red), onPressed: () => deleteCategory(i)),
                      ],
                    )
                  ],
                ),
              );
            }),
          ),

        ],
      ),
    );
  }
}
