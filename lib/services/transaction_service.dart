// lib/services/transaction_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class TransactionService {
  final String baseUrl = "http://127.0.0.1:5000"; // same as products

  Future<List<dynamic>> fetchTransactions() async {
    final url = Uri.parse("$baseUrl/transactions");

    try {
      final response = await http.get(url);

      // DEBUG
      print("GET $url -> status: ${response.statusCode}");
      print("Response body: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is List) {
          return data;
        } else {
          throw Exception("Unexpected JSON format (not a List)");
        }
      } else {
        throw Exception(
            "Failed to load transactions (status ${response.statusCode})");
      }
    } catch (e) {
      print("Error while calling $url: $e");
      rethrow;
    }
  }
}
