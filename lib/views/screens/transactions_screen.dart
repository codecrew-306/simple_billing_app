import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/responsive_auth_container.dart';
import '../widgets/transaction_details_modal.dart';
import '../../viewmodels/transaction_viewmodel.dart';

class TransactionsScreen extends ConsumerWidget {
  const TransactionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactions = ref.watch(transactionProvider);

    return AppScaffold(
      title: 'Transactions',
      currentIndex: 2,
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
        child: Column(
          children: [
            // Filter Chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
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
              child: transactions.isEmpty
                  ? const Center(child: Text('No transactions yet'))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16.0),
                      itemCount: transactions.length,
                      itemBuilder: (context, index) {
                        final transaction = transactions[index];
                        return _buildTransactionCard(context, transaction);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(
    BuildContext context,
    String label, {
    required bool isSelected,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected
            ? Theme.of(context).colorScheme.secondary
            : Colors.grey.shade100,
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

  Widget _buildTransactionCard(BuildContext context, dynamic transaction) {
    final dateStr = DateFormat(
      'dd Mar yyyy, hh:mm a',
    ).format(transaction.timestamp);

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
                Text(
                  transaction.customerName ?? 'Walk-in',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  '₹${transaction.total.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              dateStr,
              style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Items: ${transaction.items.length} \u00B7 Payment: ${transaction.paymentMethod}',
                  style: TextStyle(
                    color: Colors.blueGrey.shade400,
                    fontSize: 13,
                  ),
                ),
                Row(
                  children: [
                    TextButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) =>
                              TransactionDetailsModal(transaction: transaction),
                        );
                      },
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(0, 0),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        'View Details',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.secondary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    TextButton(
                      onPressed: () {
                        // Directly trigger share
                        final buffer = StringBuffer();
                        buffer.writeln(
                          'Receipt for ${transaction.customerName ?? "Walk-in"}',
                        );
                        buffer.writeln('Total: ₹${transaction.total}');
                        // Normally we'd use the same logic as the modal
                      },
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(0, 0),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        'Share',
                        style: TextStyle(
                          color: Colors.blueGrey.shade600,
                          fontWeight: FontWeight.bold,
                        ),
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
