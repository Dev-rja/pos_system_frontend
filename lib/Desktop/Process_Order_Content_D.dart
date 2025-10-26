import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../List_Manager.dart';
import 'package:auto_size_text/auto_size_text.dart';

class ProcessOrderContentD extends StatefulWidget {
  const ProcessOrderContentD({super.key});

  @override
  State<ProcessOrderContentD> createState() => _ProcessOrderContentDState();
}

class _ProcessOrderContentDState extends State<ProcessOrderContentD> {

  int selectedCategoryId = 0;
  int orderIdCounter = 1;
  double get totalAmount {
    return currentOrder.fold(
        0, (sum, item) => sum + item['quantity'] * item['price']);
  }

  void showPaymentDialog() {
    TextEditingController paymentCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Enter Payment"),
          content: TextField(
            controller: paymentCtrl,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: "Amount Received",
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                double amountReceived = double.tryParse(paymentCtrl.text) ?? 0;
                if (amountReceived < totalAmount) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Insufficient Payment")),
                  );
                  return;
                }

                Navigator.pop(context); // Close payment input
                showReceiptPreview(amountReceived);
              },
              child: Text("Next"),
            ),
          ],
        );
      },
    );
  }
  void showReceiptPreview(double amountReceived) {
    double change = amountReceived - totalAmount;

    // Save total before clearing the order
    double finalTotal = totalAmount;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Receipt Preview"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ...currentOrder.map((item) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("${item['name']} x${item['quantity']}"),
                    Text("₱${(item['quantity'] * item['price']).toStringAsFixed(2)}"),
                  ],
                );
              }).toList(),
              Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Total:", style: TextStyle(fontWeight: FontWeight.bold)),
                  Text("₱${finalTotal.toStringAsFixed(2)}"), // FIX
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Change:", style: TextStyle(fontWeight: FontWeight.bold)),
                  Text("₱${change.toStringAsFixed(2)}"),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);

                // SAVE HISTORY HERE
                saveToHistory(finalTotal, amountReceived, change);

                // Clear order AFTER preview is closed
                currentOrder.clear();
                setState(() {});
              },
              child: Text("Close"),
            ),
          ],
        );
      },
    );
  }
  void saveToHistory(double total, double received, double change) {

    for (var item in currentOrder) {
      final productIndex = Pro_product.indexWhere((p) => p['ID'] == item['ID']);
      if (productIndex != -1) {
        Pro_product[productIndex]['stock'] -= item['quantity'];
        if (Pro_product[productIndex]['stock'] < 0) {
          Pro_product[productIndex]['stock'] = 0; // prevent negative stock
        }
      }
    }

    TransHistory.add({
      'id': orderIdCounter++,                      // auto ID
      'cashierName': 'John Doe',                   // you can change
      'date': DateTime.now().toString(),
      'total': total.toStringAsFixed(2),
      'items': currentOrder.map((item) {
        return {
          'name': item['name'],
          'price': (item['quantity'] * item['price']).toStringAsFixed(2),
          'quantity': item['quantity'],
        };
      }).toList(),
    });
  }

  List<Map<String, dynamic>> currentOrder = [];

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Flexible(
          flex: 2,
          // Left Column: Product List
          child: Column(
            children: [
              Container(
                margin: EdgeInsets.only(left: 50),
                height: 600,
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey,
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: const Offset(-1, 4),
                    ),
                  ],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: ProProductBuilder(
                  selectedCategoryId: selectedCategoryId,
                  onAddToOrder: (product) {
                    setState(() {
                      final index = currentOrder.indexWhere((item) => item['ID'] == product['ID']);
                      int currentQty = index >= 0 ? currentOrder[index]['quantity'] : 0;

                      // Check stock limit
                      if (currentQty + 1 > product['stock']) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Cannot add more than available stock")),
                        );
                        return;
                      }

                      if (index >= 0) {
                        currentOrder[index]['quantity'] += 1;
                      } else {
                        currentOrder.add({
                          'ID': product['ID'],
                          'name': product['name'],
                          'price': product['price'],
                          'quantity': 1,
                        });
                      }
                    });
                  },
                ),
              ),

              Container(
                margin: EdgeInsets.only(left: 50, right: 10, top: 20),
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
                  },),
              ),
            ],
          ),
        ),

        // Right Column: Current Order
        Flexible(
          child: Container(
            margin: EdgeInsets.only(right: 20, left: 20),
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                // Current Order Container
                Container(
                  height: 600,
                  decoration: BoxDecoration(
                    color: Color.fromRGBO(0, 113, 80, 1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      // Header
                      Container(
                        margin: EdgeInsets.all(10),
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
                      Divider(color: Colors.white, thickness: 0.4),

                      // Order list holder
                      Expanded(
                        child: Container(
                          margin: EdgeInsets.all(10),
                          padding: EdgeInsets.all(10),
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
                                margin: EdgeInsets.only(bottom: 10),
                                padding: EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      flex: 4,
                                      child: Text(item['name'],
                                          style: TextStyle(
                                              fontSize: 16, fontWeight: FontWeight.w600)),
                                    ),

                                    // Minus button
                                    IconButton(
                                      onPressed: () {
                                        setState(() {
                                          if (item['quantity'] > 1) {
                                            item['quantity']--;
                                          } else {
                                            currentOrder.removeAt(index);
                                          }
                                        });
                                      },
                                      icon: Icon(Icons.remove_circle, color: Colors.orange),
                                    ),

                                    // Quantity
                                    Text("x${item['quantity']}",
                                        style:
                                        TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),

                                    // Plus button
                                    IconButton(
                                      onPressed: () {
                                        setState(() {
                                          if (item['quantity'] < Pro_product[item['ID']]['stock']) {
                                            item['quantity']++;
                                          } else {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(content: Text("Cannot add more than available stock")),
                                            );
                                          }
                                        });
                                      },
                                      icon: Icon(Icons.add_circle, color: Colors.green),
                                    ),

                                    // Total price for this item
                                    Expanded(
                                      flex: 2,
                                      child: Text(
                                        "₱${(item['quantity'] * item['price']).toStringAsFixed(2)}",
                                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),

                                    // Delete button
                                    IconButton(
                                      onPressed: () {
                                        setState(() {
                                          currentOrder.removeAt(index);
                                        });
                                      },
                                      icon: Icon(Icons.delete, color: Colors.red),
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

                SizedBox(height: 30),

                // Total Amount
                Container(
                  margin: EdgeInsets.all(10),
                  width: 800,
                  height: 50,
                  decoration: BoxDecoration(
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

                // Cancel & Pay Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Flexible(
                      child: Container(
                        margin: EdgeInsets.all(10),
                        width: 200,
                        height: 40,
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              currentOrder.clear();
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            side: BorderSide(
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
                        margin: EdgeInsets.all(10),
                        width: 100,
                        height: 40.0,
                        child: ElevatedButton(
                          onPressed: () {
                            if (currentOrder.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text("No items in order")),
                              );
                              return;
                            }

                            showPaymentDialog();
                          },
                          style: ElevatedButton.styleFrom(
                            side: BorderSide(
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


