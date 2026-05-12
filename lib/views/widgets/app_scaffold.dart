import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:get/get.dart';
import '../../core/routes/app_routes.dart';
import '../../core/theme/app_theme.dart';

// ─── Nav Item Model ───────────────────────────────────────────────────────────
class _NavItem {
  final String label;
  final IconData icon;
  final IconData activeIcon;
  final String route;

  const _NavItem({
    required this.label,
    required this.icon,
    required this.activeIcon,
    required this.route,
  });
}

const List<_NavItem> _navItems = [
  _NavItem(
    label: 'Dashboard',
    icon: Icons.dashboard_outlined,
    activeIcon: Icons.dashboard,
    route: AppRoutes.dashboard,
  ),
  _NavItem(
    label: 'Billing',
    icon: Icons.receipt_long_outlined,
    activeIcon: Icons.receipt_long,
    route: AppRoutes.billing,
  ),
  _NavItem(
    label: 'Transactions',
    icon: Icons.swap_horiz_outlined,
    activeIcon: Icons.swap_horiz,
    route: AppRoutes.transactions,
  ),
  _NavItem(
    label: 'Tabs',
    icon: Icons.tab_outlined,
    activeIcon: Icons.tab,
    route: AppRoutes.tabs,
  ),
  _NavItem(
    label: 'Settings',
    icon: Icons.settings_outlined,
    activeIcon: Icons.settings,
    route: AppRoutes.settings,
  ),
];

// ─── AppScaffold ──────────────────────────────────────────────────────────────
/// Reusable scaffold that:
///  • On **web** → shows a horizontal top navigation bar (SimpleBill logo +
///    nav links on left, notification/avatar actions on right).
///  • On **mobile (Android / iOS)** → shows a classic AppBar with the
///    SimpleBill title + a bottom navigation bar.
class AppScaffold extends StatelessWidget {
  final Widget child;
  final int currentIndex;

  /// Used as the AppBar title on mobile; not shown on web (nav bar has the
  /// page title as the selected link label).
  final String title;

  /// Extra action widgets placed in the AppBar (mobile) or in the top-right
  /// area (web). If null, defaults to a bell-icon notification button.
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
    Get.offNamed(_navItems[index].route);
  }

  // ─── Web top navigation bar ─────────────────────────────────────────────────
  PreferredSizeWidget _buildWebTopNavBar(BuildContext context) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(64),
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.card,
          border: Border(bottom: BorderSide(color: AppTheme.border)),
        ),
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // ── Logo ──────────────────────────────────────────────────────
                Text(
                  'SimpleBill',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.accent,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(width: 48),

                // ── Nav Links ─────────────────────────────────────────────────
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(_navItems.length, (i) {
                      final item = _navItems[i];
                      final bool selected = i == currentIndex;
                      return _WebNavLink(
                        label: item.label,
                        selected: selected,
                        onTap: () => _onItemTapped(i),
                      );
                    }),
                  ),
                ),

                // ── Right Actions ─────────────────────────────────────────────
                ...?actions,
                if (actions == null) ...[
                  IconButton(
                    icon: const Icon(Icons.notifications_outlined),
                    color: AppTheme.mutedForeground,
                    tooltip: 'Notifications',
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: const Icon(Icons.help_outline),
                    color: AppTheme.mutedForeground,
                    tooltip: 'Help',
                    onPressed: () {},
                  ),
                  const SizedBox(width: 8),
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: AppTheme.accent,
                    child: const Text(
                      'SB',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─── Mobile AppBar ──────────────────────────────────────────────────────────
  PreferredSizeWidget _buildMobileAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: AppTheme.background,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      // Left avatar / profile icon
      leading: Padding(
        padding: const EdgeInsets.all(10.0),
        child: CircleAvatar(
          radius: 16,
          backgroundColor: AppTheme.muted,
          backgroundImage: null,
          child: const Icon(
            Icons.person_outline,
            size: 18,
            color: AppTheme.mutedForeground,
          ),
        ),
      ),
      title: Text(
        'SimpleBill',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w800,
          color: AppTheme.accent,
          letterSpacing: -0.5,
        ),
      ),
      actions:
          actions ??
          [
            IconButton(
              icon: const Icon(Icons.notifications_outlined),
              color: AppTheme.foreground,
              onPressed: () {},
            ),
          ],
    );
  }

  // ─── Mobile Bottom Navigation Bar ──────────────────────────────────────────
  Widget _buildMobileBottomNav(BuildContext context) {
    final Color selectedColor = AppTheme.accent;
    const Color unselectedColor = AppTheme.mutedForeground;

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.card,
        border: Border(top: BorderSide(color: AppTheme.border)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(_navItems.length, (i) {
              final item = _navItems[i];
              final bool selected = i == currentIndex;
              return _MobileNavItem(
                label: item.label,
                icon: selected ? item.activeIcon : item.icon,
                selected: selected,
                selectedColor: selectedColor,
                unselectedColor: unselectedColor,
                onTap: () => _onItemTapped(i),
              );
            }),
          ),
        ),
      ),
    );
  }

  // ─── Build ──────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      // ── Web layout: top nav bar, no bottom nav ──────────────────────────────
      return Scaffold(
        backgroundColor: AppTheme.background,
        appBar: _buildWebTopNavBar(context),
        body: child,
      );
    }

    // ── Mobile layout: AppBar + bottom nav ─────────────────────────────────
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: _buildMobileAppBar(context),
      body: child,
      bottomNavigationBar: _buildMobileBottomNav(context),
    );
  }
}

// ─── Web Nav Link Widget ──────────────────────────────────────────────────────
class _WebNavLink extends StatefulWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _WebNavLink({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  State<_WebNavLink> createState() => _WebNavLinkState();
}

class _WebNavLinkState extends State<_WebNavLink> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: widget.selected ? AppTheme.accent : Colors.transparent,
                width: 2.5,
              ),
            ),
          ),
          child: Text(
            widget.label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: widget.selected ? FontWeight.w600 : FontWeight.w400,
              color: widget.selected
                  ? AppTheme.accent
                  : (_hovered ? AppTheme.foreground : AppTheme.mutedForeground),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Mobile Nav Item Widget ───────────────────────────────────────────────────
class _MobileNavItem extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final Color selectedColor;
  final Color unselectedColor;
  final VoidCallback onTap;

  const _MobileNavItem({
    required this.label,
    required this.icon,
    required this.selected,
    required this.selectedColor,
    required this.unselectedColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final Color color = selected ? selectedColor : unselectedColor;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 64,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: selected ? AppTheme.accentLight : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                color: color,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
