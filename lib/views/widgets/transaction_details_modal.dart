import 'package:flutter/material.dart';
import '../../models/transaction.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

class TransactionDetailsModal extends StatelessWidget {
  final Transaction transaction;

  const TransactionDetailsModal({super.key, required this.transaction});

  void _shareReceipt() {
    final dateStr = DateFormat('dd MMM yyyy, hh:mm a').format(transaction.timestamp);
    final buffer = StringBuffer();
    buffer.writeln('--- RECEIPT ---');
    buffer.writeln('Store: City Grocery');
    buffer.writeln('Date: $dateStr');
    if (transaction.customerName != null) buffer.writeln('Customer: ${transaction.customerName}');
    buffer.writeln('----------------');
    for (final item in transaction.items) {
      buffer.writeln('${item.product.name} x${item.quantity} - ₹${item.total}');
    }
    buffer.writeln('----------------');
    buffer.writeln('Total: ₹${transaction.total}');
    buffer.writeln('Payment: ${transaction.paymentMethod}');
    buffer.writeln('----------------');
    buffer.writeln('Thank you for shopping!');

    Share.share(buffer.toString());
  }

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('dd MMM yyyy, hh:mm a').format(transaction.timestamp);

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: Colors.white,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('Transaction Details', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            _buildInfoRow('Store:', 'City Grocery'),
            _buildInfoRow('Date:', dateStr),
            _buildInfoRow('Customer:', '${transaction.customerName ?? "Walk-in"} (${transaction.customerPhone ?? "****"})'),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16.0),
              child: Divider(),
            ),
            const Text('ITEMS', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.2)),
            const SizedBox(height: 12),
            ...transaction.items.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('${item.product.name} x${item.quantity}', style: const TextStyle(fontWeight: FontWeight.w500)),
                  Text('₹${item.total.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            )),
            const Divider(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Subtotal', style: TextStyle(color: Colors.grey)),
                Text('₹${transaction.subtotal.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                Text('₹${transaction.total.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              ],
            ),
            const SizedBox(height: 8),
            Text('Payment: ${transaction.paymentMethod}', style: const TextStyle(color: Colors.grey, fontSize: 13)),
          ],
        ),
      ),
      actions: [
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Close'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                onPressed: _shareReceipt,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.secondary,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: const Text('Share Receipt', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ],
      actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          SizedBox(width: 80, child: Text(label, style: const TextStyle(color: Colors.grey))),
          Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.w500))),
        ],
      ),
    );
  }
}
