import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../List_Manager.dart';
import 'package:auto_size_text/auto_size_text.dart';

class Copy extends StatefulWidget {
  const Copy({super.key});

  @override
  State<Copy> createState() => _CopyState();
}

class _CopyState extends State<Copy> {
  int selectedCategoryId = 0; // default = show all products
  List<Map<String, dynamic>> currentOrder = [];

  void addToOrder(Map<String, dynamic> product) {
    setState(() {
      currentOrder.add(product);
    });
  }

  void updateCategory(int categoryId) {
    setState(() {
      selectedCategoryId = categoryId;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        // LEFT SIDE
        Flexible(
          flex: 2,
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
                      offset: Offset(-1, 4),
                    ),
                  ],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: ProProductBuilder(
                  selectedCategoryId: selectedCategoryId,
                  onAddToOrder: addToOrder,
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
                  onCategorySelected: updateCategory,
                ),
              ),
            ],
          ),
        ),

        // RIGHT SIDE
        Flexible(
          child: Container(
            margin: EdgeInsets.only(right: 20, left: 20),
            child: Column(
              children: [
                Container(
                  height: 600,
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      Container(
                        margin: EdgeInsets.all(10),
                        alignment: Alignment.topCenter,
                        child: AutoSizeText(
                          "Current Order",
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w500,
                            fontSize: 25,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      Divider(color: Colors.white, thickness: 0.4),
                    ],
                  ),
                ),

                SizedBox(height: 30),

                Container(
                  margin: EdgeInsets.all(10),
                  width: 800,
                  height: 50,
                  color: Colors.green,
                  padding: EdgeInsets.all(5),
                  child: AutoSizeText(
                    "Total: ₱${currentOrder.fold<double>(0.0,(sum, item) => sum + (item['price'] as double),).toStringAsFixed(2)}",

                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w500,
                      fontSize: 25,
                      color: Colors.white,
                    ),
                  ),
                ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Flexible(
                      child: Container(
                        margin: EdgeInsets.all(10),
                        height: 40,
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() => currentOrder.clear());
                          },
                          style: ElevatedButton.styleFrom(
                            side: BorderSide(color: Colors.red, width: 3),
                            backgroundColor: Colors.white,
                          ),
                          child: AutoSizeText(
                            "Cancel Order",
                            maxLines: 1,
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
                        height: 40,
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            side: BorderSide(color: Colors.green, width: 3),
                            backgroundColor: Colors.white,
                          ),
                          child: AutoSizeText(
                            "Pay",
                            maxLines: 1,
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
        )
      ],
    );
  }
}
