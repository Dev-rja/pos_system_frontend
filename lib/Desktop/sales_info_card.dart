import 'package:flutter/material.dart';

class SalesInfoCard extends StatefulWidget {
  const SalesInfoCard({super.key});

  @override
  State<SalesInfoCard> createState() => _SalesInfoCardState();
}

class _SalesInfoCardState extends State<SalesInfoCard> {
  String _selectedPeriod = 'Daily';

  // TEMPORARY HARDCODED DATA – later we will get this from backend
  final Map<String, double> _salesData = {
    'Daily': 2350.0,
    'Weekly': 15230.0,
    'Monthly': 60210.0,
  };

  @override
  Widget build(BuildContext context) {
    final value = _salesData[_selectedPeriod] ?? 0.0;

    return Container(
      width: 220, // adjust to match your UI card size
      height: 220,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFF61D77A), // your green color
          width: 6,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // ICON
            const Icon(
              Icons.check_circle_outline,
              size: 40,
            ),

            // TITLE + DROPDOWN
            Column(
              children: [
                const Text(
                  'Sales',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),

                DropdownButton<String>(
                  value: _selectedPeriod,
                  underline: const SizedBox(),
                  items: const [
                    DropdownMenuItem(value: 'Daily', child: Text('Daily')),
                    DropdownMenuItem(value: 'Weekly', child: Text('Weekly')),
                    DropdownMenuItem(value: 'Monthly', child: Text('Monthly')),
                  ],
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() {
                      _selectedPeriod = value;
                    });
                  },
                ),
              ],
            ),

            // VALUE TEXT AT THE BOTTOM
            Text(
              '₱${value.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
