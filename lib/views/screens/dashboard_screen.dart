import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/responsive_auth_container.dart';
import '../../viewmodels/dashboard_viewmodel.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardData = ref.watch(dashboardProvider);
    final notifier = ref.read(dashboardProvider.notifier);

    return AppScaffold(
      title: 'Dashboard',
      currentIndex: 0,
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
              // Today's Overview
              Text(
                'TODAY\'S OVERVIEW',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueGrey.shade400,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 16),
              LayoutBuilder(
                builder: (context, constraints) {
                  final bool isWide = constraints.maxWidth > 600;
                  final double spacing = 12.0;
                  final int crossAxisCount = isWide
                      ? 2
                      : 2; // For now keeping 2, but could be more

                  return Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          context,
                          Icons.trending_up,
                          'Today\'s Sales',
                          '₹${dashboardData.todaySales.toStringAsFixed(0)}',
                        ),
                      ),
                      SizedBox(width: spacing),
                      Expanded(
                        child: _buildStatCard(
                          context,
                          Icons.shopping_cart_outlined,
                          'Transactions',
                          '${dashboardData.todayTransactions}',
                        ),
                      ),
                    ],
                  );
                },
              ),

              const SizedBox(height: 24),

              Text(
                'SALES CHART',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueGrey.shade400,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 16),
              Card(
                elevation: 0,
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
                          _buildRangeChip(
                            context,
                            notifier,
                            ChartRange.oneWeek,
                            '1W',
                            dashboardData.selectedRange,
                          ),
                          const SizedBox(width: 8),
                          _buildRangeChip(
                            context,
                            notifier,
                            ChartRange.oneMonth,
                            '1M',
                            dashboardData.selectedRange,
                          ),
                          const SizedBox(width: 8),
                          _buildRangeChip(
                            context,
                            notifier,
                            ChartRange.threeMonths,
                            '3M',
                            dashboardData.selectedRange,
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      SizedBox(
                        height: 200,
                        child: BarChart(
                          BarChartData(
                            alignment: BarChartAlignment.spaceAround,
                            maxY: dashboardData.chartData.isEmpty
                                ? 1000
                                : dashboardData.chartData
                                          .map((e) => e.value)
                                          .fold(
                                            0.0,
                                            (max, v) => v > max ? v : max,
                                          ) *
                                      1.2,
                            barTouchData: BarTouchData(enabled: false),
                            titlesData: FlTitlesData(
                              show: true,
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  getTitlesWidget: (value, meta) {
                                    final index = value.toInt();
                                    if (index < 0 ||
                                        index >= dashboardData.chartData.length)
                                      return const SizedBox();

                                    // Simplified labels for month view to avoid clutter
                                    if (dashboardData.selectedRange ==
                                            ChartRange.oneMonth &&
                                        index % 5 != 0) {
                                      return const SizedBox();
                                    }

                                    return Padding(
                                      padding: const EdgeInsets.only(top: 8.0),
                                      child: Text(
                                        dashboardData.chartData[index].label,
                                        style: const TextStyle(
                                          color: Colors.grey,
                                          fontSize: 10,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              leftTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              topTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              rightTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                            ),
                            gridData: const FlGridData(show: false),
                            borderData: FlBorderData(show: false),
                            barGroups: dashboardData.chartData
                                .asMap()
                                .entries
                                .map((e) {
                                  return BarChartGroupData(
                                    x: e.key,
                                    barRods: [
                                      BarChartRodData(
                                        toY: e.value.value,
                                        color: const Color(0xFFFDE0B2),
                                        width:
                                            dashboardData.selectedRange ==
                                                ChartRange.oneMonth
                                            ? 4
                                            : 16,
                                        borderRadius:
                                            const BorderRadius.vertical(
                                              top: Radius.circular(4),
                                            ),
                                      ),
                                    ],
                                  );
                                })
                                .toList(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Recent Transactions
              Text(
                'RECENT TRANSACTIONS',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueGrey.shade400,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 16),
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: Colors.grey.shade200),
                ),
                child: Column(
                  children: [
                    _buildTransactionTile(
                      'Rajesh',
                      '10:45 AM',
                      '₹850',
                      isLast: false,
                    ),
                    Divider(height: 1, color: Colors.grey.shade200),
                    _buildTransactionTile(
                      'Priya',
                      '10:15 AM',
                      '₹220',
                      isLast: false,
                    ),
                    Divider(height: 1, color: Colors.grey.shade200),
                    _buildTransactionTile(
                      'Walk-in',
                      '09:50 AM',
                      '₹1,250',
                      isLast: false,
                    ),
                    Divider(height: 1, color: Colors.grey.shade200),
                    _buildTransactionTile(
                      'Amit',
                      '09:20 AM',
                      '₹450',
                      isLast: true,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.grey.shade500, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildRangeChip(
    BuildContext context,
    DashboardNotifier notifier,
    ChartRange range,
    String label,
    ChartRange current,
  ) {
    final bool isSelected = range == current;
    return GestureDetector(
      onTap: () => notifier.setRange(range),
      child: Container(
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
            color: isSelected ? Colors.black : Colors.grey.shade500,
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionTile(
    String name,
    String time,
    String amount, {
    required bool isLast,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                time,
                style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
              ),
            ],
          ),
          Text(
            amount,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }
}
