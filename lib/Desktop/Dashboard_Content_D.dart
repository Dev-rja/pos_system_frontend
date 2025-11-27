import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../List_Manager.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class DashboardContent extends StatefulWidget {
  const DashboardContent({super.key});

  @override
  State<DashboardContent> createState() => _DashboardContentState();
}

class _DashboardContentState extends State<DashboardContent> {
  List<dynamic> _categories = [];
  List<dynamic> _topSelling = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    const baseUrl = 'http://127.0.0.1:5000';

    try {
      final categoriesRes = await http.get(Uri.parse('$baseUrl/categories'));
      final topRes = await http.get(Uri.parse('$baseUrl/top-selling'));

      if (categoriesRes.statusCode == 200 && topRes.statusCode == 200) {
        setState(() {
          _categories = jsonDecode(categoriesRes.body);
          _topSelling = jsonDecode(topRes.body);
          _isLoading = false;
        });
      } else {
        setState(() {
          _error =
              'Failed to load data (categories: ${categoriesRes.statusCode}, top: ${topRes.statusCode})';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 1000,
      child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Text(
                    _error!,
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      color: Colors.red,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                )
              : Column(
                  children: [
                    // DASHBOARD TITLE
                    Container(
                      alignment: Alignment.centerLeft,
                      width: 1000,
                      margin:
                          const EdgeInsets.only(bottom: 20, top: 10, left: 10),
                      child: Text(
                        'Dashboard',
                        style: GoogleFonts.outfit(
                          fontSize: 40,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),

                    // EXISTING SUMMARY CARDS
                    DashboardInfoBuilder(),

                    // CATEGORIES TITLE
                    Container(
                      alignment: Alignment.centerLeft,
                      width: 1000,
                      margin:
                          EdgeInsets.only(bottom: 10, top: 10, left: 10),
                      child: Text(
                        'Categories',
                        style: GoogleFonts.outfit(
                          fontSize: 20,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),

                    // CATEGORIES LIST (FROM BACKEND)
                    SizedBox(
                      height: 160,
                      child: _categories.isEmpty
                          ? Center(
                              child: Text(
                                'No categories found',
                                style: GoogleFonts.outfit(fontSize: 14),
                              ),
                            )
                          : ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: _categories.length,
                              itemBuilder: (context, index) {
                                final cat = _categories[index];
                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8.0),
                                  child: CategoryCard(
                                    name: cat['category_name'] ?? 'Unknown',
                                  ),
                                );
                              },
                            ),
                    ),

                    // TOP 3 TITLE
                    Container(
                      alignment: Alignment.centerLeft,
                      width: 1000,
                      margin:
                          const EdgeInsets.only(top: 50, left: 10, bottom: 10),
                      child: Text(
                        'Top 3 Selling Items',
                        style: GoogleFonts.outfit(
                          fontSize: 25,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),

                    // TOP 3 ITEMS (FROM BACKEND)
                    _topSelling.isEmpty
                        ? Text(
                            'No sales data yet',
                            style: GoogleFonts.outfit(fontSize: 14),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: _topSelling.map((item) {
                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8.0),
                                child: TopItemCard(
                                  rank: item['rank'] ?? 0,
                                  name: item['product_name'] ?? 'Unknown',
                                ),
                              );
                            }).toList(),
                          ),
                  ],
                ),
    );
  }
}

// Simple category card – adjust design if you want to match your UI more
class CategoryCard extends StatelessWidget {
  final String name;

  const CategoryCard({super.key, required this.name});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      decoration: BoxDecoration(
        color: const Color(0xFFF8F8FF),
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            blurRadius: 4,
            offset: Offset(0, 2),
            color: Colors.black12,
          ),
        ],
      ),
      padding: const EdgeInsets.all(12),
      child: Center(
        child: Text(
          name,
          textAlign: TextAlign.center,
          style: GoogleFonts.outfit(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

// Simple top item card
class TopItemCard extends StatelessWidget {
  final int rank;
  final String name;

  const TopItemCard({super.key, required this.rank, required this.name});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 160,
      child: Column(
        children: [
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
            decoration: BoxDecoration(
              color: const Color(0xFFE0E7FF),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Top $rank',
              style: GoogleFonts.outfit(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            height: 110,
            decoration: BoxDecoration(
              color: const Color(0xFFF8F8FF),
              borderRadius: BorderRadius.circular(18),
              boxShadow: const [
                BoxShadow(
                  blurRadius: 4,
                  offset: Offset(0, 2),
                  color: Colors.black12,
                ),
              ],
            ),
            padding: const EdgeInsets.all(10),
            child: Center(
              child: Text(
                name,
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
