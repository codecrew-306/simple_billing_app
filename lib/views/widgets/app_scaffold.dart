import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../../core/routes/app_routes.dart';

class AppScaffold extends StatelessWidget {
  final Widget child;
  final int currentIndex;
  final String title;
  final List<Widget>? actions;

  const AppScaffold({
    super.key,
    required this.child,
    required this.currentIndex,
    required this.title,
    this.actions,
  });

  void _onItemTapped(int index) {
    if (index == currentIndex) return;

    switch (index) {
      case 0:
        Get.offNamed(AppRoutes.dashboard);
        break;
      case 1:
        Get.offNamed(AppRoutes.billing);
        break;
      case 2:
        Get.offNamed(AppRoutes.transactions);
        break;
      case 3:
        Get.offNamed(AppRoutes.tabs);
        break;
      case 4:
        Get.offNamed(AppRoutes.settings);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isWideScreen = MediaQuery.of(context).size.width >= 900;
    final bool useSidebar = isWideScreen || kIsWeb;

    if (useSidebar) {
      return Scaffold(
        body: Row(
          children: [
            NavigationRail(
              selectedIndex: currentIndex,
              onDestinationSelected: _onItemTapped,
              labelType: NavigationRailLabelType.all,
              backgroundColor: Theme.of(context).cardColor,
              selectedIconTheme: IconThemeData(color: Theme.of(context).colorScheme.secondary),
              unselectedIconTheme: const IconThemeData(color: Colors.grey),
              selectedLabelTextStyle: TextStyle(
                color: Theme.of(context).colorScheme.secondary,
                fontWeight: FontWeight.bold,
              ),
              destinations: const [
                NavigationRailDestination(
                  icon: Icon(Icons.home_outlined),
                  selectedIcon: Icon(Icons.home),
                  label: Text('Home'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.request_quote_outlined),
                  selectedIcon: Icon(Icons.request_quote),
                  label: Text('Billing'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.swap_horiz_outlined),
                  selectedIcon: Icon(Icons.swap_horiz),
                  label: Text('Transactions'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.description_outlined),
                  selectedIcon: Icon(Icons.description),
                  label: Text('Tabs'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.settings_outlined),
                  selectedIcon: Icon(Icons.settings),
                  label: Text('Settings'),
                ),
              ],
            ),
            const VerticalDivider(thickness: 1, width: 1),
            Expanded(
              child: Scaffold(
                appBar: AppBar(
                  title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                  actions: actions,
                  elevation: 0,
                  backgroundColor: Colors.transparent,
                ),
                body: child,
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        actions: actions,
      ),
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: currentIndex,
        onTap: _onItemTapped,
        selectedItemColor: Theme.of(context).colorScheme.secondary,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.request_quote_outlined),
            activeIcon: Icon(Icons.request_quote),
            label: 'Billing',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.swap_horiz_outlined),
            activeIcon: Icon(Icons.swap_horiz),
            label: 'Transactions',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.description_outlined),
            activeIcon: Icon(Icons.description),
            label: 'Tabs',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined),
            activeIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
