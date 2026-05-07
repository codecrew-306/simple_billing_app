import 'package:flutter/material.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/responsive_auth_container.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Settings',
      currentIndex: 4,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: ResponsiveAuthContainer(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Store Information',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      TextFormField(
                        initialValue: 'City Grocery',
                        decoration: const InputDecoration(
                          labelText: 'Store Name',
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        initialValue: 'John Doe',
                        decoration: const InputDecoration(
                          labelText: 'Owner Name',
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        initialValue: '9876543210',
                        decoration: const InputDecoration(labelText: 'Phone'),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        initialValue: '123 Main Street',
                        decoration: const InputDecoration(labelText: 'Address'),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        enabled: false,
                        initialValue: 'SHOP-7X9K2M',
                        decoration: const InputDecoration(
                          labelText: 'Store ID',
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 32),

              const Text(
                'Preferences',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Card(
                child: ListTile(
                  title: const Text('Currency'),
                  trailing: DropdownButton<String>(
                    value: 'INR (₹)',
                    items: ['INR (₹)', 'USD (\$)', 'EUR (€)'].map((
                      String value,
                    ) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (_) {},
                  ),
                ),
              ),

              const SizedBox(height: 32),

              const Text(
                'Data Management',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.download),
                      title: const Text('Export Data'),
                      onTap: () {},
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.upload),
                      title: const Text('Import Data'),
                      onTap: () {},
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: Icon(
                        Icons.delete_forever,
                        color: Theme.of(context).colorScheme.error,
                      ),
                      title: Text(
                        'Reset All Data',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                      onTap: () {},
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 48),
              const Center(
                child: Text(
                  'Version 1.0.0\nMade with ❤️ for small shops',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
