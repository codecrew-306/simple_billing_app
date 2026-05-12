import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../widgets/app_scaffold.dart';
import '../../viewmodels/dashboard_viewmodel.dart';
import '../../core/theme/app_theme.dart';

// ─── Recent Transaction Data Model ───────────────────────────────────────────
class _Transaction {
  final String name;
  final String dateTime;
  final String amount;

  const _Transaction({
    required this.name,
    required this.dateTime,
    required this.amount,
  });

  /// First letters of each word in the name (max 2 chars)
  String get initials {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.substring(0, name.length >= 2 ? 2 : 1).toUpperCase();
  }
}

const List<_Transaction> _sampleTransactions = [
  _Transaction(
    name: 'Acme Corp',
    dateTime: 'Today, 10:45 AM',
    amount: '₹12,500.00',
  ),
  _Transaction(
    name: 'Global Logistics',
    dateTime: 'Today, 09:12 AM',
    amount: '₹34,000.00',
  ),
  _Transaction(
    name: 'Stark Technologies',
    dateTime: 'Yesterday, 4:30 PM',
    amount: '₹8,500.50',
  ),
  _Transaction(
    name: 'Wayne Media',
    dateTime: 'Yesterday, 1:15 PM',
    amount: '₹52,000.00',
  ),
  _Transaction(
    name: 'Initech Office',
    dateTime: 'Yesterday, 10:00 AM',
    amount: '₹1,200.00',
  ),
];

// ─── Dashboard Screen ─────────────────────────────────────────────────────────
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardData = ref.watch(dashboardProvider);
    final notifier = ref.read(dashboardProvider.notifier);

    return AppScaffold(
      title: 'Dashboard',
      currentIndex: 0,
      child: SingleChildScrollView(
        child: Center(
          child: ConstrainedBox(
            // On web, cap max width; on mobile allow full width
            constraints: BoxConstraints(
              maxWidth: kIsWeb ? 960 : double.infinity,
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: kIsWeb ? 32.0 : 16.0,
                vertical: 24.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ── Page Header ────────────────────────────────────────────
                  _buildHeader(context),
                  const SizedBox(height: 24),

                  // ── Stats Row (same for web & mobile, BoxConstraints-driven)
                  _buildStatsRow(context, dashboardData),
                  const SizedBox(height: 24),

                  // ── Sales Analytics Chart ──────────────────────────────────
                  _buildSalesAnalyticsCard(context, dashboardData, notifier),
                  const SizedBox(height: 24),

                  // ── Recent Transactions ────────────────────────────────────
                  _buildRecentTransactionsCard(context),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ─── Header ─────────────────────────────────────────────────────────────────
  Widget _buildHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Today's Overview",
          style: TextStyle(
            fontSize: kIsWeb ? 28 : 22,
            fontWeight: FontWeight.w800,
            color: AppTheme.foreground,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'A snapshot of your daily performance.',
          style: TextStyle(fontSize: 14, color: AppTheme.mutedForeground),
        ),
      ],
    );
  }

  // ─── Stats Cards Row ─────────────────────────────────────────────────────────
  Widget _buildStatsRow(BuildContext context, DashboardData data) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double spacing = kIsWeb ? 16.0 : 12.0;
        return Row(
          children: [
            Expanded(
              child: _StatCard(
                label: "Today's Sales",
                value: '₹${_formatAmount(data.todaySales)}',
                icon: Icons.account_balance_wallet_outlined,
                badge: '+15%',
                badgePositive: true,
                subtitle: 'vs yesterday',
              ),
            ),
            SizedBox(width: spacing),
            Expanded(
              child: _StatCard(
                label: 'Transactions',
                value: '${data.todayTransactions}',
                icon: Icons.receipt_outlined,
                subtitle: 'Last transaction 5m ago',
                badge: null,
                badgePositive: false,
              ),
            ),
          ],
        );
      },
    );
  }

  // ─── Sales Analytics Card ────────────────────────────────────────────────────
  Widget _buildSalesAnalyticsCard(
    BuildContext context,
    DashboardData data,
    DashboardNotifier notifier,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title + Range Chips
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  'Sales Analytics',
                  style: TextStyle(
                    fontSize: kIsWeb ? 18 : 16,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.foreground,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              _buildRangeChips(context, data, notifier),
            ],
          ),
          const SizedBox(height: 24),

          // Bar Chart
          SizedBox(height: kIsWeb ? 220 : 200, child: _buildBarChart(data)),
        ],
      ),
    );
  }

  Widget _buildRangeChips(
    BuildContext context,
    DashboardData data,
    DashboardNotifier notifier,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.muted,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _RangeChip(
            label: '1 Week',
            selected: data.selectedRange == ChartRange.oneWeek,
            onTap: () => notifier.setRange(ChartRange.oneWeek),
          ),
          _RangeChip(
            label: '1 Month',
            selected: data.selectedRange == ChartRange.oneMonth,
            onTap: () => notifier.setRange(ChartRange.oneMonth),
          ),
          _RangeChip(
            label: '3 Month',
            selected: data.selectedRange == ChartRange.threeMonths,
            onTap: () => notifier.setRange(ChartRange.threeMonths),
          ),
        ],
      ),
    );
  }

  Widget _buildBarChart(DashboardData data) {
    final double maxVal = data.chartData.isEmpty
        ? 1000
        : data.chartData
                  .map((e) => e.value)
                  .fold(0.0, (prev, v) => v > prev ? v : prev) *
              1.25;

    // Find the index of the highest bar
    int highlightIndex = 0;
    double maxFound = 0;
    for (int i = 0; i < data.chartData.length; i++) {
      if (data.chartData[i].value > maxFound) {
        maxFound = data.chartData[i].value;
        highlightIndex = i;
      }
    }

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: maxVal,
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            getTooltipColor: (_) => AppTheme.foreground,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              return BarTooltipItem(
                '₹${_formatAmount(rod.toY)}',
                const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 32,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index < 0 || index >= data.chartData.length) {
                  return const SizedBox();
                }
                if (data.selectedRange == ChartRange.oneMonth &&
                    index % 5 != 0) {
                  return const SizedBox();
                }
                final bool isHighlight = index == highlightIndex;
                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    data.chartData[index].label,
                    style: TextStyle(
                      color: isHighlight
                          ? AppTheme.accent
                          : AppTheme.mutedForeground,
                      fontSize: 11,
                      fontWeight: isHighlight
                          ? FontWeight.w700
                          : FontWeight.w400,
                    ),
                  ),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 48,
              getTitlesWidget: (value, meta) {
                if (value == 0) {
                  return const Padding(
                    padding: EdgeInsets.only(right: 8),
                    child: Text(
                      '₹0',
                      style: TextStyle(
                        color: AppTheme.mutedForeground,
                        fontSize: 10,
                      ),
                    ),
                  );
                }
                if (value == meta.max) return const SizedBox();
                final label = value >= 1000
                    ? '₹${(value / 1000).toStringAsFixed(0)}k'
                    : '₹${value.toInt()}';
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Text(
                    label,
                    style: const TextStyle(
                      color: AppTheme.mutedForeground,
                      fontSize: 10,
                    ),
                  ),
                );
              },
            ),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (_) =>
              FlLine(color: AppTheme.border, strokeWidth: 1, dashArray: [4, 4]),
        ),
        borderData: FlBorderData(show: false),
        barGroups: data.chartData.asMap().entries.map((e) {
          final bool isHighlight = e.key == highlightIndex;
          final double barWidth = data.selectedRange == ChartRange.oneMonth
              ? 6
              : 22;
          return BarChartGroupData(
            x: e.key,
            barRods: [
              BarChartRodData(
                toY: e.value.value,
                color: isHighlight ? AppTheme.accent : const Color(0xFFE0D8CC),
                width: barWidth,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(6),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  // ─── Recent Transactions Card ─────────────────────────────────────────────
  Widget _buildRecentTransactionsCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header row
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
            child: Row(
              children: [
                Text(
                  'Recent Transactions',
                  style: TextStyle(
                    fontSize: kIsWeb ? 18 : 16,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.foreground,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () {},
                  child: Text(
                    'View All',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.accent,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Table header — only on web (wider screens)
          if (kIsWeb)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                children: [
                  const Expanded(
                    flex: 3,
                    child: Text(
                      'Client',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.mutedForeground,
                      ),
                    ),
                  ),
                  // const Expanded(
                  //   flex: 3,
                  //   child: Text(
                  //     'Date & Time',
                  //     style: TextStyle(
                  //       fontSize: 12,
                  //       fontWeight: FontWeight.w600,
                  //       color: AppTheme.mutedForeground,
                  //     ),
                  //   ),
                  // ),
                  Text(
                    'Amount',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.mutedForeground,
                    ),
                  ),
                ],
              ),
            ),

          Divider(height: 1, color: AppTheme.border),

          // Transaction rows
          ...List.generate(_sampleTransactions.length, (i) {
            final tx = _sampleTransactions[i];
            final bool isLast = i == _sampleTransactions.length - 1;
            return Column(
              children: [
                _TransactionTile(transaction: tx),
                if (!isLast) Divider(height: 1, color: AppTheme.border),
              ],
            );
          }),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  // ─── Helpers ─────────────────────────────────────────────────────────────────
  static String _formatAmount(double value) {
    if (value >= 100000) {
      return '${(value / 100000).toStringAsFixed(1)}L';
    } else if (value >= 1000) {
      // format with comma e.g. 12,450
      final int intVal = value.toInt();
      final String s = intVal.toString();
      if (s.length > 3) {
        return '${s.substring(0, s.length - 3)},${s.substring(s.length - 3)}';
      }
      return s;
    }
    return value.toStringAsFixed(0);
  }
}

// ─── Stat Card ────────────────────────────────────────────────────────────────
class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final String? badge;
  final bool badgePositive;
  final String subtitle;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.badge,
    required this.badgePositive,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label + Icon
          Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppTheme.mutedForeground,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.accentLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 18, color: AppTheme.accent),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Value
          Text(
            value,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: AppTheme.foreground,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 8),

          // Badge / subtitle
          Row(
            children: [
              if (badge != null) ...[
                Icon(
                  badgePositive
                      ? Icons.trending_up_rounded
                      : Icons.trending_down_rounded,
                  size: 14,
                  color: badgePositive
                      ? AppTheme.success
                      : AppTheme.destructive,
                ),
                const SizedBox(width: 4),
                Text(
                  badge!,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: badgePositive
                        ? AppTheme.success
                        : AppTheme.destructive,
                  ),
                ),
                const SizedBox(width: 4),
              ] else
                Icon(
                  Icons.access_time_outlined,
                  size: 13,
                  color: AppTheme.mutedForeground,
                ),
              const SizedBox(width: 2),
              Expanded(
                child: Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.mutedForeground,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Range Chip ───────────────────────────────────────────────────────────────
class _RangeChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _RangeChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? AppTheme.accent : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: selected ? Colors.white : AppTheme.mutedForeground,
          ),
        ),
      ),
    );
  }
}

// ─── Transaction Tile ─────────────────────────────────────────────────────────
class _TransactionTile extends StatelessWidget {
  final _Transaction transaction;

  const _TransactionTile({required this.transaction});

  /// Deterministic color from name
  Color _avatarColor() {
    const colors = [
      Color(0xFFD4A843),
      Color(0xFF6B9E78),
      Color(0xFF7B8EC8),
      Color(0xFFD47B6B),
      Color(0xFF8E6BBE),
    ];
    final int index = transaction.name.codeUnitAt(0) % colors.length;
    return colors[index];
  }

  @override
  Widget build(BuildContext context) {
    final Color avatarColor = _avatarColor();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        children: [
          // Circular avatar with initials
          CircleAvatar(
            radius: 20,
            backgroundColor: avatarColor.withValues(alpha: 0.15),
            child: Text(
              transaction.initials,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: avatarColor,
              ),
            ),
          ),
          const SizedBox(width: 14),

          // Name + DateTime
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.foreground,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  transaction.dateTime,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.mutedForeground,
                  ),
                ),
              ],
            ),
          ),

          // Amount
          Text(
            transaction.amount,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppTheme.foreground,
            ),
          ),
        ],
      ),
    );
  }
}
