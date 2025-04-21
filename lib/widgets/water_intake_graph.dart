import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class WaterIntakeGraph extends StatelessWidget {
  final List<Map<String, dynamic>> records;
  final double height;

  const WaterIntakeGraph({
    super.key,
    required this.records,
    this.height = 300,
  });

  String _formatDate(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}';
  }

  Map<String, double> _getDailyTotals() {
    final dailyTotals = <String, double>{};

    for (var record in records) {
      try {
        final date = DateTime.parse(record['timestamp'] as String);
        final dateKey = '${date.year}-${date.month}-${date.day}';
        final amount = (record['amount'] as num).toDouble();
        dailyTotals[dateKey] = (dailyTotals[dateKey] ?? 0.0) + amount;
      } catch (e) {
        print('Error parsing date: ${record['timestamp']}');
        // Skip invalid records
        continue;
      }
    }

    return dailyTotals;
  }

  @override
  Widget build(BuildContext context) {
    if (records.isEmpty) return Container();

    final dailyTotals = _getDailyTotals();
    final sortedDates = dailyTotals.keys.toList()..sort();

    final spots = sortedDates.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), dailyTotals[entry.value]!);
    }).toList();

    return Container(
      padding: const EdgeInsets.all(16.0),
      width: double.infinity,
      height: height,
      child: LineChart(
        LineChartData(
          gridData: const FlGridData(show: true),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  if (value.toInt() >= 0 &&
                      value.toInt() < sortedDates.length) {
                    try {
                      final date = DateTime.parse(sortedDates[value.toInt()]);
                      return RotatedBox(
                        quarterTurns: 1,
                        child: Text(
                          _formatDate(date),
                          style: const TextStyle(fontSize: 10),
                        ),
                      );
                    } catch (e) {
                      return const Text('');
                    }
                  }
                  return const Text('');
                },
                reservedSize: 40,
              ),
            ),
            leftTitles: const AxisTitles(
              axisNameWidget: Text('ML'),
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                interval: 500,
              ),
            ),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: true),
          minX: 0,
          maxX: (sortedDates.length - 1).toDouble(),
          minY: 0,
          maxY: dailyTotals.values
              .fold<double>(0, (max, value) => value > max ? value : max),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: Colors.blue,
              dotData: const FlDotData(show: true),
              belowBarData: BarAreaData(
                show: true,
                color: Colors.blue.withOpacity(0.2),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
