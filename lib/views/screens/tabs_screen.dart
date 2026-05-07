import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/responsive_auth_container.dart';
import '../widgets/tab_details_dialog.dart';
import '../widgets/record_payment_dialog.dart';
import '../../models/tab.dart';
import '../../viewmodels/tab_viewmodel.dart';
import 'package:intl/intl.dart';

class TabsScreen extends ConsumerWidget {
  const TabsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tabs = ref.watch(tabProvider);

    return AppScaffold(
      title: 'Tabs',
      currentIndex: 3,
      actions: const [
        Padding(
          padding: EdgeInsets.only(right: 16.0),
          child: Center(
            child: Text(
              'SHOP-7X9K2M',
              style: TextStyle(fontFamily: 'monospace', color: Colors.grey),
            ),
          ),
        ),
      ],
      child: ResponsiveAuthContainer(
        maxWidth: 1000,
        child: tabs.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.receipt_long_outlined,
                      size: 64,
                      color: Colors.grey.shade300,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No outstanding tabs',
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: tabs.length,
                itemBuilder: (context, index) {
                  final tab = tabs[index];
                  return _buildTabCard(context, tab);
                },
              ),
      ),
    );
  }

  Widget _buildTabCard(BuildContext context, TabEntry tab) {
    final dateStr = DateFormat('dd MMM yyyy').format(tab.timestamp);
    final totalStr = '₹${tab.total.toStringAsFixed(0)}';
    final paidStr = '₹${tab.paidAmount.toStringAsFixed(0)}';
    final outstandingStr = '₹${tab.outstandingAmount.toStringAsFixed(0)}';

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
            Text(
              tab.customerName ?? 'Walk-in',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 4),
            Text(
              tab.customerPhone ?? 'No phone',
              style: TextStyle(color: Colors.blueGrey.shade600, fontSize: 13),
            ),
            Text(
              'Bill: $dateStr',
              style: TextStyle(color: Colors.blueGrey.shade600, fontSize: 13),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Text(
                  'Total: ',
                  style: TextStyle(
                    color: Colors.blueGrey.shade600,
                    fontSize: 13,
                  ),
                ),
                Text(
                  totalStr,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    fontFamily: 'monospace',
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  'Paid: ',
                  style: TextStyle(
                    color: Colors.blueGrey.shade600,
                    fontSize: 13,
                  ),
                ),
                Text(
                  paidStr,
                  style: TextStyle(
                    color:
                        Theme.of(context).extension<CustomColors>()?.success ??
                        Colors.green,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    fontFamily: 'monospace',
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  'Outstanding:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
                Text(
                  outstandingStr,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Theme.of(context).colorScheme.error,
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  children: [
                    TextButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => TabDetailsDialog(tab: tab),
                        );
                      },
                      child: Text(
                        'View Details',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.secondary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => RecordPaymentDialog(tab: tab),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(
                          context,
                        ).colorScheme.secondary,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Mark Payment',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
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
