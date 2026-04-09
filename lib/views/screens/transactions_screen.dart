import 'package:flutter/material.dart';
import '../widgets/bottom_nav_bar.dart';

class TransactionsScreen extends StatelessWidget {
  const TransactionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transactions', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Column(
        children: [
          // Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              children: [
                ChoiceChip(label: const Text('Today'), selected: true, onSelected: (_) {}),
                const SizedBox(width: 8),
                ChoiceChip(label: const Text('This Week'), selected: false, onSelected: (_) {}),
                const SizedBox(width: 8),
                ChoiceChip(label: const Text('This Month'), selected: false, onSelected: (_) {}),
                const SizedBox(width: 8),
                ChoiceChip(label: const Text('Custom'), selected: false, onSelected: (_) {}),
              ],
            ),
          ),
          
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: 4,
              itemBuilder: (context, index) {
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Walk-in Customer', style: TextStyle(fontWeight: FontWeight.bold)),
                            const Text('₹250.00', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Today, 11:${30 + index} AM', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                            const Text('Cash', style: TextStyle(color: Colors.grey, fontSize: 12)),
                          ],
                        ),
                        const Divider(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('${index + 1} items', style: const TextStyle(color: Colors.grey)),
                            Row(
                              children: [
                                TextButton(onPressed: () {}, child: const Text('Share')),
                                TextButton(onPressed: () {}, child: const Text('View Details')),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 2),
    );
  }
}
