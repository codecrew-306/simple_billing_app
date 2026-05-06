import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/tab.dart';
import '../../viewmodels/tab_viewmodel.dart';
import '../../viewmodels/transaction_viewmodel.dart';

class RecordPaymentDialog extends ConsumerStatefulWidget {
  final TabEntry tab;

  const RecordPaymentDialog({super.key, required this.tab});

  @override
  ConsumerState<RecordPaymentDialog> createState() =>
      _RecordPaymentDialogState();
}

class _RecordPaymentDialogState extends ConsumerState<RecordPaymentDialog> {
  final _amountController = TextEditingController();
  double _amountReceived = 0;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _confirm() {
    if (_amountReceived <= 0) return;

    final tabNotifier = ref.read(tabProvider.notifier);
    final transactionNotifier = ref.read(transactionProvider.notifier);

    if (_amountReceived >= widget.tab.outstandingAmount) {
      // Fully paid or overpaid
      transactionNotifier.addTransaction(
        items: widget.tab.items,
        subtotal: widget.tab.total, // Using bill total
        total: widget.tab.total,
        customerName: widget.tab.customerName,
        customerPhone: widget.tab.customerPhone,
        paymentMethod: 'Cash (Tab Settle)',
      );
      tabNotifier.removeTab(widget.tab.id);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _amountReceived > widget.tab.outstandingAmount
                ? 'Bill Settled! Change returned: ₹${(_amountReceived - widget.tab.outstandingAmount).toStringAsFixed(0)}'
                : 'Bill Settled!',
          ),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      // Partially paid
      tabNotifier.updatePaidAmount(widget.tab.id, _amountReceived);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Payment recorded. Outstanding updated.'),
          backgroundColor: Colors.blue,
        ),
      );
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final outstanding = widget.tab.outstandingAmount;
    final newOutstanding = outstanding - _amountReceived;
    final balance = _amountReceived - outstanding;

    return AlertDialog(
      scrollable: true,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      title: const Text(
        'Mark Payment',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Current Outstanding',
                  style: TextStyle(color: Colors.grey),
                ),
                Text(
                  '₹${outstanding.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'AMOUNT RECEIVED',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _amountController,
            keyboardType: TextInputType.number,
            autofocus: true,
            onChanged: (v) {
              setState(() {
                _amountReceived = double.tryParse(v) ?? 0;
              });
            },
            decoration: InputDecoration(
              prefixText: '₹ ',
              hintText: '0',
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
            ),
          ),
          const SizedBox(height: 24),

          if (_amountReceived > 0) ...[
            if (newOutstanding > 0)
              _buildResultRow(
                'New Outstanding:',
                '₹${newOutstanding.toStringAsFixed(0)}',
                Colors.orange,
              )
            else if (balance >= 0) ...[
              _buildResultRow('Status:', 'Settled', Colors.green),
              if (balance > 0)
                _buildResultRow(
                  'Change to Return:',
                  '₹${balance.toStringAsFixed(0)}',
                  Colors.blue,
                ),
            ],
          ],
        ],
      ),
      actions: [
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Cancel'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                onPressed: _amountReceived > 0 ? _confirm : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.secondary,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Confirm Payment',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ],
      actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
    );
  }

  Widget _buildResultRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
