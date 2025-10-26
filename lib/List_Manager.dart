import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:google_fonts/google_fonts.dart';

//==============================================================================
// Info List
//==============================================================================
final List<Map<String, dynamic>> dashboardInfo = [
  {'text': 'info 1', 'icon': Icons.notifications},
  {'text': 'info 2', 'icon': Icons.check_circle},
  {'text': 'info 3', 'icon': Icons.warehouse},
];

//==============================================================================
// Info Builder
//==============================================================================

class DashboardInfoBuilder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 250,
      child: ListView.builder(
        shrinkWrap: true,
        scrollDirection: Axis.horizontal,
        itemCount: dashboardInfo.length,
        itemBuilder: (context, index) {
          return InfoBoxStyle(
            text: dashboardInfo[index]['text'],
            icon: dashboardInfo[index]['icon'],
          );
        },
      ),
    );
  }
}

//==============================================================================
// Info Box Style
//==============================================================================

class InfoBoxStyle extends StatelessWidget {
  final String text;
  final IconData icon;

  InfoBoxStyle({required this.text, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Color.fromARGB( 250,150, 247, 164,),
      margin: const EdgeInsets.all(12),
      child: Container(
        width: 200,
        padding: const EdgeInsets.all(16),
        child: Container(
          color: Color.fromRGBO(234, 253, 237, 1),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon, // Use the provided icon
                size: 40,
                color: Colors.green[600],
              ),
              const SizedBox(height: 8),
              AutoSizeText(
                text,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

//==============================================================================
// Categories List
//==============================================================================
final List<Map<String, dynamic>> Dash_categories = [
  {'id': 1, 'name': 'Vegetables', 'image': 'assets/veg_cat.png'},
  {'id': 2, 'name': 'Fruits', 'image': 'assets/fru_cat.png'},
  {'id': 3, 'name': 'Dairy', 'image': 'assets/App_Icon.png'},
];

//==============================================================================
// Categories Builder
//==============================================================================

class DashboardCategoriesBuilder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 150,
      width: 1100,
      child: ListView.builder(
        shrinkWrap: true,
        scrollDirection: Axis.horizontal,
        itemCount: Dash_categories.length,
        itemBuilder: (context, index) {
          return CategoriesBoxStyle(
            name: Dash_categories[index]['name']!,
            imagePath: Dash_categories[index]['image']!,
            id: Dash_categories[index]['id']!,
          );
        },
      ),
    );
  }
}

//==============================================================================
// Categories Box Style
//==============================================================================

class CategoriesBoxStyle extends StatelessWidget {
  final String name;
  final String imagePath;
  final int id;

  CategoriesBoxStyle({required this.name, required this.imagePath, required this.id});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(12),
      child: Container(
        width: 200,
        padding: const EdgeInsets.all(5),
        child: Stack(
          children: [
            Flexible(
              flex: 1,
              child: Positioned.fill(
                child: Image.asset(
                  imagePath,
                  fit: BoxFit.cover,
                ),
              ),
            ),

            Positioned(
              bottom: 0,
              child: Container(
                decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey,
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
                borderRadius: BorderRadius.circular(5),
              ),
                child: SizedBox(
                  child: AutoSizeText(
                    name,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.right,

                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

//==============================================================================
// Top Items List
//==============================================================================
final List<Map<String, String>> TopSellingItems = [
  {'name': 'Top 1', 'image': 'assets/App_Icon.png'},
  {'name': 'Top 2', 'image': 'assets/App_Icon.png'},
  {'name': 'Top 3', 'image': 'assets/App_Icon.png'},
];

//==============================================================================
// Top Items Builder
//==============================================================================

class DashboardTopItemBuilder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 250,
      child: ListView.builder(
        shrinkWrap: true,
        scrollDirection: Axis.horizontal,
        itemCount: TopSellingItems.length,
        itemBuilder: (context, index) {
          return TopItemBoxStyle(
            name: TopSellingItems[index]['name']!,
            imagePath: TopSellingItems[index]['image']!,
          );
        },
      ),
    );
  }
}

//==============================================================================
// Top Items Box Style
//==============================================================================

class TopItemBoxStyle extends StatelessWidget {
  final String name;
  final String imagePath;

  TopItemBoxStyle({required this.name, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(12),
      child: Container(
        width: 200,
        padding: const EdgeInsets.all(5),
        child: Stack(
          children: [
            Flexible(
              flex: 1,
              child: Positioned.fill(
                child: Image.asset(
                  imagePath,
                  fit: BoxFit.cover,
                ),
              ),
            ),


            Positioned(
              left: 1,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey,
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                  borderRadius: BorderRadius.circular(5),
                ),
                child: SizedBox(
                  child: AutoSizeText(
                    name,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,

                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

//==============================================================================
// Pro_Product List
//==============================================================================
final List<Map<String, dynamic>> Pro_product = [

  {
    'name': 'Product 1',
    'image': 'assets/veg_cat.png',
    'categories': [1, 2],
    'price': 10,
    'stock': 50,
    'ID': 0
  },
  {
    'name': 'Product 2',
    'image': 'assets/fru_cat.png',
    'categories': [2, 1],
    'price': 20,
    'stock': 30,
    'ID': 1
  },
  {
    'name': 'Product 3',
    'image': 'assets/App_Icon.png',
    'categories': [3, 1],
    'price': 30,
    'stock': 20,
    'ID': 2
  },
  {
    'name': 'Product 4',
    'image': 'assets/App_Icon.png',
    'categories': [3, 1],
    'price': 40,
    'stock': 10,
    'ID': 3
  },
  {
    'name': 'Product 5',
    'image': 'assets/App_Icon.png',
    'categories': [2, 3],
    'price': 50,
    'stock': 5,
    'ID': 4
  },
];


//==============================================================================
// Pro_Product Builder
//==============================================================================

class ProProductBuilder extends StatelessWidget {
  final Function(Map<String, dynamic>) onAddToOrder;
  final int selectedCategoryId;

  ProProductBuilder({
    required this.onAddToOrder,
    required this.selectedCategoryId,
  });

  @override
  Widget build(BuildContext context) {
    // Filter products using selectedCategoryId
    final filteredProducts = selectedCategoryId == 0
        ? Pro_product
        : Pro_product
        .where((product) =>
        product['categories'].contains(selectedCategoryId))
        .toList();

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 1,
        ),
        itemCount: filteredProducts.length,
        itemBuilder: (context, index) {
          final product = filteredProducts[index];
          return ProProductBoxStyle(
            name: product['name'],
            imagePath: product['image'],
            price: product['price'],
            stock: product['stock'],
            onAdd: () {
              onAddToOrder(product);
            },
          );
        },
      ),
    );
  }
}

//==============================================================================
// Pro_Product Style
//==============================================================================

class ProProductBoxStyle extends StatelessWidget {
  final String name;
  final String imagePath;
  final int price;
  final int stock;
  final VoidCallback onAdd; // Callback when "Add" is pressed

  ProProductBoxStyle({
    required this.name,
    required this.imagePath,
    required this.price,
    required this.stock,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shadowColor: Colors.transparent,
      color: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(1),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Flexible(
              child: Container(
                margin: EdgeInsets.only(top: 10, bottom: 10),
                alignment: Alignment.center,
                height: 250,
                width: 250,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black, width: 0.1),
                  image: DecorationImage(
                    image: AssetImage(imagePath),
                    fit: BoxFit.fill,
                  ),
                ),
              ),
            ),
            AutoSizeText(
              name,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            AutoSizeText(
              'Stock: $stock',
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            AutoSizeText(
              NumberFormat.currency(
                symbol: '₱',
                decimalDigits: 2,
              ).format(double.parse(price.toString())),
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),

            Container(
              margin: EdgeInsets.only(top: 5),
              child: ElevatedButton(
                onPressed: onAdd,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                ),
                child: const Text(
                  "Add",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


//==============================================================================
// Pro_Categories Builder
//==============================================================================

class ProCategoriesBuilder extends StatelessWidget {
  final int selectedCategoryId;
  final Function(int) onCategorySelected;

  const ProCategoriesBuilder({
    super.key,
    required this.selectedCategoryId,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 5,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 1.5,
        ),
        itemCount: Dash_categories.length,
        itemBuilder: (context, index) {
          final category = Dash_categories[index];
          return ProCategoriesBoxStyle(
            name: category['name'],
            imagePath: category['image'],
            id: category['id'],
            isSelected: selectedCategoryId == category['id'],
            onTap: () => onCategorySelected(category['id']),
          );
        },
      ),
    );
  }
}

//==============================================================================
// Pro_Categories Box Style
//==============================================================================

class ProCategoriesBoxStyle extends StatelessWidget {
  final String name;
  final String imagePath;
  final int id;
  final bool isSelected;
  final VoidCallback onTap;

  const ProCategoriesBoxStyle({
    super.key,
    required this.name,
    required this.imagePath,
    required this.id,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: isSelected ? Colors.greenAccent.withOpacity(.3) : Colors.white,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? Colors.green : Colors.black,
              width: isSelected ? 2 : 0.2,
            ),
          ),
          child: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  image: DecorationImage(
                    image: AssetImage(imagePath),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  color: Colors.white,
                  child: AutoSizeText(
                    name,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

//==============================================================================
// History List
// =============================================================================
final List<Map<String, dynamic>> TransHistory = [];

//==============================================================================
// History Builder
//==============================================================================

class TransHistoryBuilder extends StatefulWidget {
  @override
  _TransHistoryBuilderState createState() => _TransHistoryBuilderState();
}

class _TransHistoryBuilderState extends State<TransHistoryBuilder> {
  List<bool> isExpandedList = List.generate(TransHistory.length, (index) => false);

  String _formatDate(String dateString) {
    try {
      DateTime date = DateTime.parse(dateString);
      return DateFormat('MMM dd, yyyy').format(date);
    } catch (e) {
      return dateString;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: TransHistory.length,
      itemBuilder: (context, groupIndex) {
        final group = TransHistory[groupIndex];
        final items = group['items'] as List<Map<String, dynamic>>;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 5,
              color: Colors.green[700],
              margin: const EdgeInsets.symmetric(vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                title: Text(
                  'Transaction ID: ${group['id']}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _formatDate(group['date']),
                      style: const TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                    Text(
                      "Cashier: ${group['cashierName']}",
                      style: const TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                    Text(
                      "Total: ₱${group['total']}",
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    )
                  ],
                ),
                trailing: IconButton(
                  onPressed: () {
                    setState(() {
                      isExpandedList[groupIndex] = !isExpandedList[groupIndex];
                    });
                  },
                  icon: Icon(
                    isExpandedList[groupIndex] ? Icons.expand_less : Icons.expand_more,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
              ),
            ),
            if (isExpandedList[groupIndex])
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  children: items
                      .map((item) => HistoryBoxStyle(
                    cashierName: group['cashierName'],
                    date: group['date'],
                    total: group['total'],
                    name: item['name'],
                    price: item['price'],
                    quantity: item['quantity'].toString(),
                  ))
                      .toList(),
                ),
              ),
          ],
        );
      },
    );
  }
}

//==============================================================================
// History Box Style
//==============================================================================

class HistoryBoxStyle extends StatelessWidget {
  final String name;
  final String price;
  final String cashierName;
  final String date;
  final String total;
  final String quantity;



  const HistoryBoxStyle({
    super.key,
    required this.name,
    required this.price,
    required this.cashierName,
    required this.date,
    required this.total,
    required this.quantity,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
        child: Row(
          children: [
            const SizedBox(width: 15),
            Expanded(
              child: Row(
                children: [
                  AutoSizeText(
                      "$name",
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.green[900],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    AutoSizeText(
                      "    qty: $quantity",
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w500,
                        fontSize: 10,
                        color: Colors.grey[900],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),

            const SizedBox(width: 10),
            AutoSizeText(
              NumberFormat.currency(symbol: '₱', decimalDigits: 2)
                  .format(double.tryParse(price) ?? 0),
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: Colors.green[800],
              ),
              maxLines: 1,
            ),
          ],
        ),
      ),
    );
  }
}