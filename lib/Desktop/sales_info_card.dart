import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';

class SalesInfoCard extends StatefulWidget {
  final String title;
  final String type; // "daily", "weekly", "monthly", "transactions_today"

  const SalesInfoCard({
    super.key,
    required this.title,
    required this.type,
  });

  @override
  State<SalesInfoCard> createState() => _SalesInfoCardState();
}

class _SalesInfoCardState extends State<SalesInfoCard> {
  bool _isLoading = true;
  String? _error;
  num? _value;

  final String _baseUrl = "http://127.0.0.1:5000";

  @override
  void initState() {
    super.initState();
    _fetchValue();
  }

  Future<void> _fetchValue() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      late Uri url;

      if (widget.type == "daily" || widget.type == "transactions_today") {
        url = Uri.parse("$_baseUrl/reports/daily");
      } else if (widget.type == "weekly") {
        url = Uri.parse("$_baseUrl/reports/weekly");
      } else if (widget.type == "monthly") {
        url = Uri.parse("$_baseUrl/reports/monthly");
      } else {
        throw Exception("Unknown card type: ${widget.type}");
      }

      final response = await http.get(url);
      if (response.statusCode != 200) throw Exception("Error HTTP ${response.statusCode}");

      final data = jsonDecode(response.body);
      num value = widget.type == "transactions_today"
          ? data["transactions"] ?? 0
          : (data["total_sales"] ?? 0) as num;

      setState(() {
        _value = value;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  // 🎨 Dynamic Color per card type
  Color _getTopColor() {
    switch (widget.type) {
      case "daily":
        return const Color(0xFF05B748); // green
      case "weekly":
        return const Color(0xFF1E88E5); // blue
      case "monthly":
        return const Color(0xFF8E24AA); // purple
      case "transactions_today":
        return const Color(0xFFFB8C00); // orange
      default:
        return const Color(0xFF05B748);
    }
  }

  IconData _getIcon() {
    switch (widget.type) {
      case "daily":
        return Icons.today;
      case "weekly":
        return Icons.calendar_view_week;
      case "monthly":
        return Icons.calendar_month;
      case "transactions_today":
        return Icons.receipt_long;
      default:
        return Icons.bar_chart;
    }
  }

  @override
  Widget build(BuildContext context) {
    String valueText;

    if (_isLoading) {
      valueText = "Loading...";
    } else if (_error != null) {
      valueText = "Error";
    } else {
      if (widget.type == "transactions_today") {
        valueText = "${_value?.toInt() ?? 0}";
      } else {
        valueText = "₱${(_value ?? 0).toDouble().toStringAsFixed(2)}";
      }
    }

    final Color topColor = _getTopColor();

    return SizedBox(
      width: 200,
      height: 180,
      child: Card(
        elevation: 4,
        margin: const EdgeInsets.all(8),
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
        ),
        child: Column(
          children: [
            Expanded(
              child: Container(
                width: double.infinity,
                color: topColor,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Align(
                      alignment: Alignment.topLeft,
                      child: Icon(
                        _getIcon(),
                        color: Colors.white,
                        size: 26,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      valueText,
                      style: GoogleFonts.outfit(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    if (_error != null)
                      Text(
                        "Failed",
                        style: GoogleFonts.outfit(fontSize: 10, color: Colors.white),
                      ),
                  ],
                ),
              ),
            ),
            Container(
              height: 40,
              color: Colors.white,
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                widget.title,
                style: GoogleFonts.outfit(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: topColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
