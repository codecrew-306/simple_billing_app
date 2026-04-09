import 'package:flutter/material.dart';
import '../widgets/bottom_nav_bar.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard', style: TextStyle(fontWeight: FontWeight.bold)),
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Today's Overview
            const Text('Today\'s Overview', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.trending_up, color: Theme.of(context).primaryColor),
                              const SizedBox(width: 8),
                              const Text('Today\'s Sales'),
                            ],
                          ),
                          const SizedBox(height: 16),
                          const Text('₹4,500', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.shopping_cart, color: Theme.of(context).primaryColor),
                              const SizedBox(width: 8),
                              const Text('Transactions'),
                            ],
                          ),
                          const SizedBox(height: 16),
                          const Text('24', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 32),
            
            // Temporary Chart Placeholder
            const Text('Sales (fl_chart here)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Card(
              child: Container(
                height: 200,
                alignment: Alignment.center,
                child: const Text('[Bar Chart Placeholder]'),
              ),
            ),

            const SizedBox(height: 32),

            // Recent Transactions
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Recent Transactions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                TextButton(onPressed: () {}, child: const Text('View All \u2192')),
              ],
            ),
            const SizedBox(height: 8),
            Card(
              child: ListTile(
                leading: CircleAvatar(backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1), child: const Text('W')),
                title: const Text('Walk-in Customer'),
                subtitle: const Text('10:45 AM'),
                trailing: const Text('₹150', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
            Card(
              child: ListTile(
                leading: CircleAvatar(backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1), child: const Text('R')),
                title: const Text('Rahul K.'),
                subtitle: const Text('09:30 AM'),
                trailing: const Text('₹450', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 0),
    );
  }
}
