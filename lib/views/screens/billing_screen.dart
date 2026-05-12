import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/responsive_auth_container.dart';
import '../widgets/add_item_modal.dart';
import 'barcode_scanner_screen.dart';
import '../../models/product.dart';
import '../../viewmodels/billing_viewmodel.dart';
import '../../viewmodels/product_viewmodel.dart';
import '../../viewmodels/transaction_viewmodel.dart';
import '../../viewmodels/tab_viewmodel.dart';

class BillingScreen extends ConsumerStatefulWidget {
  const BillingScreen({super.key});

  @override
  ConsumerState<BillingScreen> createState() => _BillingScreenState();
}

class _BillingScreenState extends ConsumerState<BillingScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final SearchController _searchController = SearchController();
  final TextEditingController _cashController = TextEditingController();
  double _cashReceived = 0;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _searchController.dispose();
    _cashController.dispose();
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

  void _finalizeTransaction(String method) {
    final billingState = ref.read(billingProvider);
    if (billingState.cart.isEmpty) return;

    if (method == 'Tab') {
      ref
          .read(tabProvider.notifier)
          .addTab(
            items: List.from(billingState.cart),
            total: billingState.total,
            customerName: _nameController.text.isEmpty
                ? null
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
                ? null
                : _nameController.text,
            customerPhone: _phoneController.text.isEmpty
                ? null
                : _phoneController.text,
            paymentMethod: method,
          );
    }

    ref.read(billingProvider.notifier).reset();
    _nameController.clear();
    _phoneController.clear();
    _cashController.clear();
    _searchController.clear();
    setState(() {
      _cashReceived = 0;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          method == 'Cash' ? 'Transaction Saved!' : 'Saved to Tab!',
        ),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final billingState = ref.watch(billingProvider);
    final billingNotifier = ref.read(billingProvider.notifier);
    final products = ref.watch(productProvider);

    final canMarkAsPaid =
        billingState.cart.isNotEmpty && _cashReceived >= billingState.total;
    final canSaveAsTab =
        billingState.cart.isNotEmpty &&
        _cashController.text.isNotEmpty &&
        _cashReceived < billingState.total;
    final balance = _cashReceived - billingState.total;

    return AppScaffold(
      title: 'Billing',
      currentIndex: 1,
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
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: ResponsiveAuthContainer(
          maxWidth: 1000,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'New Bill',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${billingState.cart.length} items in cart',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                  ElevatedButton.icon(
                    onPressed: () => _showAddItemModal(),
                    icon: const Icon(Icons.add_box_outlined, size: 18),
                    label: const Text('Add Item'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Scanner Section
              Card(
                elevation: 0,
                color: Colors.grey.shade50,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: Colors.grey.shade200),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.blueGrey.shade100.withValues(
                                alpha: 0.5,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.qr_code_scanner,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Scan Product',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                Text(
                                  'Choose your scanning method',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.phone_android),
                          label: const Text(
                            'Phone Camera',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          onPressed: _openCameraScanner,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Theme.of(context).primaryColor,
                            side: BorderSide(
                              color: Theme.of(context).primaryColor,
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Search Bar
              SearchAnchor(
                searchController: _searchController,
                builder: (context, controller) {
                  return SearchBar(
                    controller: controller,
                    padding: const WidgetStatePropertyAll<EdgeInsets>(
                      EdgeInsets.symmetric(horizontal: 16.0),
                    ),
                    onTap: () {
                      controller.openView();
                    },
                    onChanged: (_) {
                      controller.openView();
                    },
                    leading: const Icon(Icons.search),
                    hintText: 'Search product by name...',
                  );
                },
                suggestionsBuilder: (context, controller) {
                  final query = controller.text.toLowerCase();
                  final filteredProducts = products
                      .where((p) => p.name.toLowerCase().contains(query))
                      .toList();

                  return filteredProducts.map((product) {
                    return ListTile(
                      title: Text(product.name),
                      subtitle: Text('₹${product.price} - ${product.category}'),
                      onTap: () {
                        billingNotifier.addToCart(product);
                        controller.closeView(null);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Added ${product.name} to cart'),
                          ),
                        );
                      },
                    );
                  });
                },
              ),

              const SizedBox(height: 16),

              // Customer Details
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: Colors.grey.shade200),
                ),
                child: Theme(
                  data: Theme.of(
                    context,
                  ).copyWith(dividerColor: Colors.transparent),
                  child: ExpansionTile(
                    leading: const Icon(Icons.person_outline),
                    title: const Text(
                      'Customer Details',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        child: Column(
                          children: [
                            TextField(
                              controller: _nameController,
                              onChanged: (v) => billingNotifier
                                  .updateCustomerInfo(v, _phoneController.text),
                              decoration: InputDecoration(
                                labelText: 'Customer Name',
                                hintText: 'Optional',
                                filled: true,
                                fillColor: Colors.grey.shade50,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextField(
                              controller: _phoneController,
                              keyboardType: TextInputType.phone,
                              onChanged: (v) => billingNotifier
                                  .updateCustomerInfo(_nameController.text, v),
                              decoration: InputDecoration(
                                labelText: 'Phone Number',
                                hintText: 'Optional',
                                filled: true,
                                fillColor: Colors.grey.shade50,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Cart Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.shopping_bag_outlined,
                        color: Colors.blueGrey.shade400,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'CART',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.blueGrey.shade400,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    '${billingState.cart.length} item(s)',
                    style: TextStyle(
                      color: Colors.grey.shade500,
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Cart Items List
              if (billingState.cart.isEmpty)
                Container(
                  padding: const EdgeInsets.all(32),
                  height: 150,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.shopping_cart_outlined,
                        size: 40,
                        color: Colors.grey.shade300,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'No items yet',
                        style: TextStyle(color: Colors.grey.shade400),
                      ),
                    ],
                  ),
                )
              else
                ...billingState.cart.map(
                  (item) => _buildCartItem(context, item, billingNotifier),
                ),

              const SizedBox(height: 24),

              // Totals
              Card(
                elevation: 0,
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
                            'Subtotal',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            '₹${billingState.subtotal.toStringAsFixed(0)}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 32),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Total',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 22,
                            ),
                          ),
                          Text(
                            '₹${billingState.total.toStringAsFixed(0)}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 22,
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      Text(
                        'CASH RECEIVED (OPTIONAL)',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.blueGrey.shade400,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _cashController,
                        keyboardType: TextInputType.number,
                        onChanged: (v) {
                          setState(() {
                            _cashReceived = double.tryParse(v) ?? 0;
                          });
                        },
                        decoration: InputDecoration(
                          prefixText: '₹ ',
                          hintText: '0',
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                        ),
                      ),

                      if (_cashReceived > billingState.total) ...[
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Balance to Return',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                            Text(
                              '₹${balance.toStringAsFixed(0)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                      ],

                      const SizedBox(height: 24),

                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: canMarkAsPaid
                                  ? () => _finalizeTransaction('Cash')
                                  : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(
                                  context,
                                ).colorScheme.secondary,
                                foregroundColor: Colors.black,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text(
                                'Mark as Paid',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: OutlinedButton(
                              onPressed: canSaveAsTab
                                  ? () => _finalizeTransaction('Tab')
                                  : null,
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.secondary,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text(
                                'Save as Tab',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCartItem(
    BuildContext context,
    dynamic item,
    BillingNotifier notifier,
  ) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              alignment: Alignment.center,
              child: Text(
                item.product.name[0],
                style: TextStyle(
                  color: Colors.amber.shade700,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.product.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    '₹${item.product.price.toStringAsFixed(0)}',
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            ),
            // Quantity Control
            Row(
              children: [
                _buildQtyBtn(
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
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                _buildQtyBtn(
                  Icons.add,
                  () => notifier.updateQuantity(
                    item.product.id,
                    item.quantity + 1,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 16),
            Text(
              '₹${item.total.toStringAsFixed(0)}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: Icon(Icons.close, color: Colors.grey.shade400, size: 20),
              onPressed: () => notifier.removeFromCart(item.product.id),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQtyBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 16, color: Colors.black87),
      ),
    );
  }
}
