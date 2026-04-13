import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../widgets/bottom_nav_bar.dart';

class TabsScreen extends StatelessWidget {
  const TabsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tabs', style: TextStyle(fontWeight: FontWeight.bold)),
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
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildTabCard(context, 'Rajesh Sharma', '98765 43210', '15 Mar 2024', '₹850', '₹500', '₹350'),
          _buildTabCard(context, 'Amit Patel', '98765 12345', '14 Mar 2024', '₹1,250', '₹0', '₹1,250'),
        ],
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 3),
    );
  }

  Widget _buildTabCard(BuildContext context, String name, String phone, String date, String total, String paid, String outstanding) {
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
            Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 4),
            Text(phone, style: TextStyle(color: Colors.blueGrey.shade600, fontSize: 13)),
            Text('Bill: $date', style: TextStyle(color: Colors.blueGrey.shade600, fontSize: 13)),
            const SizedBox(height: 12),
            Row(
              children: [
                Text('Total: ', style: TextStyle(color: Colors.blueGrey.shade600, fontSize: 13)),
                Text(total, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, fontFamily: 'monospace')),
                const SizedBox(width: 16),
                Text('Paid: ', style: TextStyle(color: Colors.blueGrey.shade600, fontSize: 13)),
                Text(paid, style: TextStyle(color: Theme.of(context).extension<CustomColors>()?.success ?? Colors.green, fontWeight: FontWeight.bold, fontSize: 13, fontFamily: 'monospace')),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Outstanding:', style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.error)),
                    Text(outstanding, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Theme.of(context).colorScheme.error, fontFamily: 'monospace')),
                  ],
                ),
                Row(
                  children: [
                    TextButton(
                      onPressed: () {},
                      child: Text('View Details', style: TextStyle(color: Theme.of(context).colorScheme.secondary, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.secondary,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        elevation: 0,
                      ),
                      child: const Text('Mark as Paid', style: TextStyle(fontWeight: FontWeight.bold)),
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
