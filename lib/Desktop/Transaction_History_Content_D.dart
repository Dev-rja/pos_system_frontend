import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../List_Manager.dart';            // 👈 for TransHistory + TransHistoryBuilder
import '../services/transaction_service.dart';

class HistoryContentD extends StatefulWidget {
  const HistoryContentD({super.key});

  @override
  _HistoryContentDState createState() => _HistoryContentDState();
}

class _HistoryContentDState extends State<HistoryContentD> {
  final _transactionService = TransactionService();
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadTransactionsFromBackend();
  }

  Future<void> _loadTransactionsFromBackend() async {
    try {
      final data = await _transactionService.fetchTransactions();

      // 🧹 Clear old in-memory history
      TransHistory.clear();

      // 🧠 Map backend -> old TransHistory format
      for (final t in data) {
        final items = (t['items'] ?? []) as List<dynamic>;

        TransHistory.add({
          'id': t['transaction_id'],                 // old: orderIdCounter++
          'cashierName': 'John Doe',                 // later: real cashier from user_id
          'date': t['date_time'],                    // builder can format string
          'total': (t['total_amount'] as num)
              .toStringAsFixed(2),                  // string total
          'items': items.map((item) {
            final name =
                item['product_name'] ?? 'Product ${item['product_id']}';
            final qty = item['quantity'] ?? 0;
            final lineTotal =
                (item['subtotal'] as num).toStringAsFixed(2);

            return {
              'name': name,
              'price': lineTotal,                   // matches old TransHistory
              'quantity': qty,
            };
          }).toList(),
        });
      }

      setState(() {
        _isLoading = false;
        _error = null;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(child: Text("Error: $_error"));
    }

    // 👇 Your original design, unchanged
    return Container(
      padding: const EdgeInsets.all(50),
      child: Column(
        children: [
          Container(
            height: 800,
            width: 1700,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: const Color.fromARGB(255, 193, 225, 153),
            ),
            child: TransHistoryBuilder(),   // uses TransHistory we just filled
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}
