import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:simplebill/models/cart_item.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/add_item_modal.dart';
import 'barcode_scanner_screen.dart';
import '../../models/product.dart';
import '../../viewmodels/billing_viewmodel.dart';
import '../../viewmodels/product_viewmodel.dart';
import '../../viewmodels/transaction_viewmodel.dart';
import '../../viewmodels/tab_viewmodel.dart';
import '../../core/theme/app_theme.dart';

class BillingScreen extends ConsumerStatefulWidget {
  const BillingScreen({super.key});

  @override
  ConsumerState<BillingScreen> createState() => _BillingScreenState();
}

class _BillingScreenState extends ConsumerState<BillingScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _cashController = TextEditingController();
  final TextEditingController _searchFieldController = TextEditingController();
  double _cashReceived = 0;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _cashController.dispose();
    _searchFieldController.dispose();
    super.dispose();
  }

  void _showAddItemModal({String? barcode}) async {
    final newProduct = await showDialog<dynamic>(
      context: context,
      builder: (context) => AddItemModal(initialBarcode: barcode),
    );

    if (newProduct != null && newProduct is Product) {
      ref.read(billingProvider.notifier).addToCart(newProduct);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Added ${newProduct.name} to cart')),
        );
      }
    }
  }

  void _openCameraScanner() async {
    final scannedBarcode = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (context) => const BarcodeScannerScreen()),
    );

    if (scannedBarcode != null) {
      if (!mounted) return;
      final product = ref
          .read(productProvider.notifier)
          .getProductByBarcode(scannedBarcode);

      if (product != null) {
        ref.read(billingProvider.notifier).addToCart(product);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Added ${product.name} to cart')),
        );
      } else {
        _showAddItemModal(barcode: scannedBarcode);
      }
    }
  }

  void _finalizeTransaction(String type, double paidAmount) {
    final billingState = ref.read(billingProvider);
    if (billingState.cart.isEmpty) return;

    if (type == 'Tab') {
      ref
          .read(tabProvider.notifier)
          .addTab(
            items: List.from(billingState.cart),
            paidAmount: paidAmount,
            total: billingState.total,
            customerName: _nameController.text.isEmpty
                ? 'Walk-in Customer'
                : _nameController.text,
            customerPhone: _phoneController.text.isEmpty
                ? null
                : _phoneController.text,
          );
    } else {
      ref
          .read(transactionProvider.notifier)
          .addTransaction(
            items: billingState.cart,
            subtotal: billingState.subtotal,
            total: billingState.total,
            customerName: _nameController.text.isEmpty
                ? 'Walk-in Customer'
                : _nameController.text,
            customerPhone: _phoneController.text.isEmpty
                ? null
                : _phoneController.text,
            paymentMethod: 'Cash',
          );
    }

    ref.read(billingProvider.notifier).reset();
    _nameController.clear();
    _phoneController.clear();
    _cashController.clear();
    setState(() {
      _cashReceived = 0;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(type == 'Cash' ? 'Transaction Saved!' : 'Saved to Tab!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showSearchPopup() {
    showDialog(
      context: context,
      builder: (context) => Consumer(
        builder: (context, ref, child) {
          final products = ref.watch(productProvider);
          return Dialog(
            backgroundColor: AppTheme.background,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Container(
              width: 500,
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    autofocus: true,
                    onChanged: (value) => setState(() {}),
                    controller: _searchFieldController,
                    decoration: InputDecoration(
                      hintText: 'Search by name, SKU, or category...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: AppTheme.border),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 400),
                    child: ListenableBuilder(
                      listenable: _searchFieldController,
                      builder: (context, _) {
                        final query = _searchFieldController.text.toLowerCase();
                        final filtered = products
                            .where(
                              (p) =>
                                  p.name.toLowerCase().contains(query) ||
                                  p.category.toLowerCase().contains(query),
                            )
                            .toList();

                        if (filtered.isEmpty) {
                          return const Padding(
                            padding: EdgeInsets.all(32.0),
                            child: Text('No products found'),
                          );
                        }

                        return ListView.builder(
                          shrinkWrap: true,
                          itemCount: filtered.length,
                          itemBuilder: (context, index) {
                            final product = filtered[index];
                            return ListTile(
                              title: Text(
                                product.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text(
                                '${product.category} • ₹${product.price}',
                              ),
                              onTap: () {
                                ref
                                    .read(billingProvider.notifier)
                                    .addToCart(product);
                                _searchFieldController.clear();
                                Navigator.pop(context);
                              },
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final billingState = ref.watch(billingProvider);
    final billingNotifier = ref.read(billingProvider.notifier);

    final bool isWide = MediaQuery.of(context).size.width > 900;

    return AppScaffold(
      title: 'Billing',
      currentIndex: 1,
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (isWide) {
            return _buildWebLayout(billingState, billingNotifier);
          } else {
            return _buildMobileLayout(billingState, billingNotifier);
          }
        },
      ),
    );
  }

  Widget _buildWebLayout(BillingState state, BillingNotifier notifier) {
    return Stack(
      children: [
        // Main Scrollable Content (Left side)
        Positioned.fill(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSearchSection(),
                      const SizedBox(height: 24),
                      _buildScanSection(),
                      const SizedBox(height: 24),
                      _buildCustomerAccordion(notifier),
                      const SizedBox(height: 24),
                      _buildCurrentOrder(state, notifier, isWide: true),
                      // Extra padding at bottom to ensure last items aren't hidden by screen edges
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
                // Fixed spacer to prevent content from going under the sticky summary
                const SizedBox(width: 432),
              ],
            ),
          ),
        ),
        // Sticky Summary Panel (Right side)
        Positioned(
          top: 32,
          right: 32,
          bottom: 32,
          width: 400,
          child: Container(
            decoration: BoxDecoration(
              color: AppTheme.card,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(32),
              child: _buildOrderSummary(state, notifier),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(BillingState state, BillingNotifier notifier) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildSearchSection(isMobile: true),
                const SizedBox(height: 16),
                _buildCustomerAccordion(notifier),
                const SizedBox(height: 16),
                _buildCurrentOrder(state, notifier, isWide: false),
              ],
            ),
          ),
        ),
        _buildMobileSummaryFooter(state, notifier),
      ],
    );
  }

  Widget _buildSearchSection({bool isMobile = false}) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Product Search',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: _showSearchPopup,
            child: AbsorbPointer(
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search by name, SKU, or category...',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: AppTheme.background,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppTheme.border),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScanSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Scan Barcode',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Scan or type barcode here...',
                    prefixIcon: const Icon(Icons.qr_code_scanner),
                    filled: true,
                    fillColor: AppTheme.background,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppTheme.border),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              ElevatedButton.icon(
                onPressed: _openCameraScanner,
                icon: const Icon(Icons.add),
                label: const Text('Add Item'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.accent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 20,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerAccordion(BillingNotifier notifier) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.muted,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.person_outline, size: 20),
          ),
          title: Text(
            _nameController.text.isEmpty
                ? 'Walk-in Customer'
                : _nameController.text,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: Column(
                children: [
                  TextField(
                    controller: _nameController,
                    onChanged: (v) =>
                        notifier.updateCustomerInfo(v, _phoneController.text),
                    decoration: InputDecoration(
                      labelText: 'Customer Name',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _phoneController,
                    onChanged: (v) =>
                        notifier.updateCustomerInfo(_nameController.text, v),
                    decoration: InputDecoration(
                      labelText: 'Phone Number',
                      hintText: 'Optional',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentOrder(
    BillingState state,
    BillingNotifier notifier, {
    required bool isWide,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Current Order',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.muted,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${state.cart.length} Items',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (isWide) _buildCartHeader(),
          if (state.cart.isEmpty)
            const Padding(
              padding: EdgeInsets.all(48.0),
              child: Center(child: Text('No items in cart')),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: state.cart.length,
              separatorBuilder: (context, index) =>
                  Divider(height: 1, color: AppTheme.border),
              itemBuilder: (context, index) =>
                  _buildCartItemRow(state.cart[index], notifier, isWide),
            ),
        ],
      ),
    );
  }

  Widget _buildCartHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.background,
        border: Border(bottom: BorderSide(color: AppTheme.border)),
      ),
      child: const Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              'Item',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              'Qty',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              'Price',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              'Total',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildCartItemRow(
    CartItem item,
    BillingNotifier notifier,
    bool isWide,
  ) {
    if (!isWide) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.product.name,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'SKU: ${item.product.id.length > 5 ? item.product.id.substring(0, 5) : item.product.id}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '₹${item.product.price.toStringAsFixed(2)}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: AppTheme.border),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => notifier.updateQuantity(
                          item.product.id,
                          item.quantity - 1,
                        ),
                        icon: const Icon(Icons.remove, size: 16),
                      ),
                      Text(
                        '${item.quantity}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        onPressed: () => notifier.updateQuantity(
                          item.product.id,
                          item.quantity + 1,
                        ),
                        icon: const Icon(Icons.add, size: 16),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => notifier.removeFromCart(item.product.id),
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                ),
              ],
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.product.name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  'SKU: ${item.product.id.length > 5 ? item.product.id.substring(0, 5) : item.product.id}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
          Expanded(
            child: Row(
              children: [
                _buildQtyIcon(
                  Icons.remove,
                  () => notifier.updateQuantity(
                    item.product.id,
                    item.quantity - 1,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: Text(
                    '${item.quantity}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                _buildQtyIcon(
                  Icons.add,
                  () => notifier.updateQuantity(
                    item.product.id,
                    item.quantity + 1,
                  ),
                ),
              ],
            ),
          ),
          Expanded(child: Text('₹${item.product.price.toStringAsFixed(2)}')),
          Expanded(
            child: Text(
              '₹${item.total.toStringAsFixed(2)}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          IconButton(
            onPressed: () => notifier.removeFromCart(item.product.id),
            icon: const Icon(Icons.delete_outline, color: Colors.red),
          ),
        ],
      ),
    );
  }

  Widget _buildQtyIcon(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: AppTheme.border),
        ),
        child: Icon(icon, size: 14),
      ),
    );
  }

  Widget _buildOrderSummary(BillingState state, BillingNotifier notifier) {
    final balance = _cashReceived - state.total;
    final canMarkAsPaid =
        state.cart.isNotEmpty &&
        _cashReceived >= state.total &&
        _cashController.text.isNotEmpty;
    final canSaveAsTab =
        state.cart.isNotEmpty &&
        (_cashController.text.isEmpty || _cashReceived < state.total);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Order Summary',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 32),
        _buildSummaryRow('Subtotal', '₹${state.subtotal.toStringAsFixed(2)}'),
        const SizedBox(height: 16),
        _buildSummaryRow(
          'Tax (8%)',
          '₹${(state.total - state.subtotal).toStringAsFixed(2)}',
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Add Discount',
              style: TextStyle(
                color: AppTheme.accent,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Text('-₹0.00', style: TextStyle(color: Colors.grey)),
          ],
        ),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 24),
          child: Divider(),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Total',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(
              '₹${state.total.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 32),
        const Text(
          'Amount Paid',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _cashController,
          keyboardType: TextInputType.number,
          onChanged: (v) =>
              setState(() => _cashReceived = double.tryParse(v) ?? 0),
          decoration: InputDecoration(
            prefixText: '₹ ',
            hintText: '0.00',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        if (_cashReceived > state.total) ...[
          const SizedBox(height: 16),
          _buildSummaryRow(
            'Balance to Return',
            '₹${balance.toStringAsFixed(2)}',
            valueColor: Colors.green,
          ),
        ],
        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: canMarkAsPaid
                ? () => _finalizeTransaction('Cash', _cashReceived)
                : null,
            icon: const Icon(Icons.payments_outlined),
            label: const Text('Mark as Paid'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accent,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: canSaveAsTab
                    ? () => _finalizeTransaction('Tab', _cashReceived)
                    : null,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Save as Tab'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  notifier.reset();
                  _cashController.clear();
                  setState(() => _cashReceived = 0);
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  foregroundColor: Colors.red,
                ),
                child: const Text('Clear'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSummaryRow(String label, String value, {Color? valueColor}) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(color: Colors.grey),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Text(
          value,
          style: TextStyle(fontWeight: FontWeight.bold, color: valueColor),
        ),
      ],
    );
  }

  Widget _buildMobileSummaryFooter(
    BillingState state,
    BillingNotifier notifier,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.card,
        border: Border(top: BorderSide(color: AppTheme.border)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Subtotal',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    Text(
                      '₹${state.subtotal.toStringAsFixed(2)}',
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text(
                      'Tax (8%)',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    Text(
                      '₹${(state.total - state.subtotal).toStringAsFixed(2)}',
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  '₹${state.total.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Show summary/payment bottom sheet for mobile
                  _showMobilePaymentSheet(state, notifier);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.accent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Process Payment',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showMobilePaymentSheet(BillingState state, BillingNotifier notifier) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: EdgeInsets.only(
            top: 32,
            left: 32,
            right: 32,
            bottom: 32 + MediaQuery.of(context).viewInsets.bottom,
          ),
          child: _buildOrderSummary(state, notifier),
        ),
      ),
    );
  }
}
