import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/blood_glucose_provider.dart';

class BloodGlucoseGraph extends StatelessWidget {
  final List<BloodGlucoseReading> readings;
  final double height;
  final bool showFullDate;

  const BloodGlucoseGraph({
    super.key,
    required this.readings,
    this.height = 300,
    this.showFullDate = true,
  });

  String _formatDateTime(DateTime dateTime, bool showFull) {
    if (showFull) {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}, ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
    }
    return '${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    if (readings.isEmpty) return Container();

    // Sort readings by timestamp for the graph
    final sortedReadings = List<BloodGlucoseReading>.from(readings)
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

    final spots = sortedReadings.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value.glucoseLevel);
    }).toList();

    return Container(
      padding: const EdgeInsets.all(16.0),
      width: double.infinity,
      height: height,
      child: LineChart(
        LineChartData(
          gridData: FlGridData(show: true),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  if (value.toInt() >= 0 &&
                      value.toInt() < sortedReadings.length) {
                    return RotatedBox(
                      quarterTurns: 1,
                      child: Text(
                        _formatDateTime(sortedReadings[value.toInt()].timestamp,
                            showFullDate),
                        style: const TextStyle(fontSize: 10),
                      ),
                    );
                  }
                  return const Text('');
                },
                reservedSize: 40,
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                interval: 50,
              ),
            ),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: true),
          minX: 0,
          maxX: (sortedReadings.length - 1).toDouble(),
          minY: readings.fold<double>(
              double.infinity,
              (min, reading) =>
                  reading.glucoseLevel < min ? reading.glucoseLevel : min),
          maxY: readings.fold<double>(
              0,
              (max, reading) =>
                  reading.glucoseLevel > max ? reading.glucoseLevel : max),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: Colors.blue,
              dotData: FlDotData(show: true),
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
