import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class SalesRangeCard extends StatefulWidget {
  const SalesRangeCard({super.key});

  @override
  State<SalesRangeCard> createState() => _SalesRangeCardState();
}

class _SalesRangeCardState extends State<SalesRangeCard> {
  bool _isLoading = false;
  String? _error;

  double? _totalSales;
  int? _transactions;

  DateTimeRange? _selectedRange;

  final String _baseUrl = "http://127.0.0.1:5000";

  String _formatDate(DateTime d) => DateFormat("yyyy-MM-dd").format(d);

  Future<void> _pickRange() async {
    final now = DateTime.now();

    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2023),
      lastDate: DateTime(now.year, now.month, now.day),
      initialDateRange: _selectedRange ??
          DateTimeRange(
            start: now.subtract(const Duration(days: 6)),
            end: now,
          ),
    );

    if (picked != null) {
      setState(() {
        _selectedRange = picked;
      });
      await _fetchRangeData(picked);
    }
  }

  Future<void> _fetchRangeData(DateTimeRange range) async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final url = Uri.parse("$_baseUrl/reports/range");

      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "start_date": _formatDate(range.start),
          "end_date": _formatDate(range.end),
        }),
      );

      if (response.statusCode != 200) {
        throw Exception("HTTP ${response.statusCode}: ${response.body}");
      }

      final data = jsonDecode(response.body);
      final totalSales = (data["total_sales"] ?? 0).toDouble();
      final txCount = (data["transactions"] ?? 0) as int;

      setState(() {
        _totalSales = totalSales;
        _transactions = txCount;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasRange = _selectedRange != null;

    final String valueText;
    if (_isLoading) {
      valueText = "Loading...";
    } else if (_error != null) {
      valueText = "Error";
    } else if (_totalSales != null) {
      valueText = "₱${_totalSales!.toStringAsFixed(2)}";
    } else {
      valueText = "--";
    }

    final String rangeLabel = hasRange
        ? "${_formatDate(_selectedRange!.start)} → ${_formatDate(_selectedRange!.end)}"
        : "Choose date range";

    return SizedBox(
      width: 230,
      height: 230,
      child: Card(
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            // TOP COLORED AREA
            Expanded(
              child: Container(
                width: double.infinity,
                color: const Color(0xFF00C853), // green
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.date_range, color: Colors.white),
                    const SizedBox(height: 12),
                    Text(
                      valueText,
                      style: GoogleFonts.outfit(
                        fontSize: 22,
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (_transactions != null && _error == null)
                      Text(
                        "${_transactions!} transaction(s)",
                        style: GoogleFonts.outfit(
                          fontSize: 12,
                          color: Colors.white70,
                        ),
                      ),
                    const Spacer(),
                    // date range label
                    Text(
                      rangeLabel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.outfit(
                        fontSize: 11,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // BOTTOM WHITE AREA
            Container(
              width: double.infinity,
              color: Colors.white,
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Sales (Custom)",
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF008C3A),
                    ),
                  ),
                  TextButton(
                    onPressed: _pickRange,
                    child: const Text(
                      "Pick",
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),

            if (_error != null)
              Padding(
                padding:
                    const EdgeInsets.only(left: 10, right: 10, bottom: 6),
                child: Text(
                  _error!,
                  style: const TextStyle(
                    color: Colors.red,
                    fontSize: 10,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
