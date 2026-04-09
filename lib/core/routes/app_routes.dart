import 'package:get/get.dart';
import '../../views/screens/login_screen.dart';
import '../../views/screens/register_screen.dart';
import '../../views/screens/dashboard_screen.dart';
import '../../views/screens/billing_screen.dart';
import '../../views/screens/transactions_screen.dart';
import '../../views/screens/tabs_screen.dart';
import '../../views/screens/settings_screen.dart';

class AppRoutes {
  static const login = '/login';
  static const register = '/register';
  static const dashboard = '/dashboard';
  static const billing = '/billing';
  static const transactions = '/transactions';
  static const tabs = '/tabs';
  static const settings = '/settings';

  static final pages = [
    GetPage(name: login, page: () => const LoginScreen()),
    GetPage(name: register, page: () => const RegisterScreen()),
    GetPage(name: dashboard, page: () => const DashboardScreen()),
    GetPage(name: billing, page: () => const BillingScreen()),
    GetPage(name: transactions, page: () => const TransactionsScreen()),
    GetPage(name: tabs, page: () => const TabsScreen()),
    GetPage(name: settings, page: () => const SettingsScreen()),
  ];
}
