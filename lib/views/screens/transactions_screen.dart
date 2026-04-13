import 'package:flutter/material.dart';
import '../widgets/bottom_nav_bar.dart';

class TransactionsScreen extends StatelessWidget {
  const TransactionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transactions', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: Center(
              child: Text(
                'SHOP-7X9K2M',
                style: TextStyle(fontFamily: 'monospace', color: Colors.grey),
              ),
            ),
          )
        ],
      ),
      body: Column(
        children: [
          // Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              children: [
                _buildFilterChip(context, 'Today', isSelected: true),
                const SizedBox(width: 8),
                _buildFilterChip(context, 'This Week', isSelected: false),
                const SizedBox(width: 8),
                _buildFilterChip(context, 'This Month', isSelected: false),
                const SizedBox(width: 8),
                _buildFilterChip(context, 'Custom', isSelected: false),
              ],
            ),
          ),
          
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                _buildTransactionCard(context, 'Rajesh', '15 Mar 2024, 10:45 AM', '₹850', 'Items: 2 \u00B7 Payment: Cash'),
                _buildTransactionCard(context, 'Priya', '15 Mar 2024, 10:15 AM', '₹220', 'Items: 3 \u00B7 Payment: Cash'),
                _buildTransactionCard(context, 'Walk-in', '15 Mar 2024, 09:50 AM', '₹1,250', 'Items: 4 \u00B7 Payment: Cash'),
                _buildTransactionCard(context, 'Amit', '15 Mar 2024, 09:20 AM', '₹450', 'Items: 3 \u00B7 Payment: Cash'),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 2),
    );
  }

  Widget _buildFilterChip(BuildContext context, String label, {required bool isSelected}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? Theme.of(context).colorScheme.secondary : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: isSelected ? Colors.black : Colors.blueGrey.shade600,
        ),
      ),
    );
  }

  Widget _buildTransactionCard(BuildContext context, String name, String date, String amount, String summary) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Text(amount, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, fontFamily: 'monospace')),
              ],
            ),
            const SizedBox(height: 4),
            Text(date, style: TextStyle(color: Colors.grey.shade500, fontSize: 13)),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(summary, style: TextStyle(color: Colors.blueGrey.shade400, fontSize: 13)),
                Row(
                  children: [
                    TextButton(
                      onPressed: () {},
                      style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: const Size(0, 0), tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                      child: Text('View Details', style: TextStyle(color: Theme.of(context).colorScheme.secondary, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(width: 12),
                    TextButton(
                      onPressed: () {},
                      style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: const Size(0, 0), tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                      child: Text('Share', style: TextStyle(color: Colors.blueGrey.shade600, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
