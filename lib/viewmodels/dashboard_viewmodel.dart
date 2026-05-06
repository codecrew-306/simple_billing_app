import 'package:flutter_riverpod/flutter_riverpod.dart';

enum ChartRange { oneWeek, oneMonth, threeMonths }

class DashboardData {
  final double todaySales;
  final int todayTransactions;
  final ChartRange selectedRange;
  final List<ChartPoint> chartData;

  DashboardData({
    required this.todaySales,
    required this.todayTransactions,
    required this.selectedRange,
    required this.chartData,
  });

  DashboardData copyWith({
    double? todaySales,
    int? todayTransactions,
    ChartRange? selectedRange,
    List<ChartPoint>? chartData,
  }) {
    return DashboardData(
      todaySales: todaySales ?? this.todaySales,
      todayTransactions: todayTransactions ?? this.todayTransactions,
      selectedRange: selectedRange ?? this.selectedRange,
      chartData: chartData ?? this.chartData,
    );
  }
}

class ChartPoint {
  final String label;
  final double value;

  ChartPoint(this.label, this.value);
}

class DashboardNotifier extends Notifier<DashboardData> {
  @override
  DashboardData build() {
    return DashboardData(
      todaySales: 2770.0,
      todayTransactions: 4,
      selectedRange: ChartRange.oneWeek,
      chartData: _generateWeekData(),
    );
  }

  void setRange(ChartRange range) {
    List<ChartPoint> data;
    switch (range) {
      case ChartRange.oneWeek:
        data = _generateWeekData();
        break;
      case ChartRange.oneMonth:
        data = _generateMonthData();
        break;
      case ChartRange.threeMonths:
        data = _generateThreeMonthData();
        break;
    }
    state = state.copyWith(selectedRange: range, chartData: data);
  }

  static List<ChartPoint> _generateWeekData() {
    return [
      ChartPoint('Mon', 1000),
      ChartPoint('Tue', 1200),
      ChartPoint('Wed', 1100),
      ChartPoint('Thu', 1400),
      ChartPoint('Fri', 1300),
      ChartPoint('Sat', 1500),
      ChartPoint('Sun', 1450),
    ];
  }

  static List<ChartPoint> _generateMonthData() {
    return List.generate(30, (i) => ChartPoint('${i + 1}', 1000 + (i % 5) * 100.0));
  }

  static List<ChartPoint> _generateThreeMonthData() {
    return [
      ChartPoint('Jan', 30000),
      ChartPoint('Feb', 45000),
      ChartPoint('Mar', 35000),
    ];
  }
}

final dashboardProvider = NotifierProvider<DashboardNotifier, DashboardData>(DashboardNotifier.new);
