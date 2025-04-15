import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'providers/water_intake_provider.dart';
import 'providers/auth_provider.dart';
import 'api_service.dart';

class WaterIntakeView extends StatefulWidget {
  const WaterIntakeView({super.key});

  @override
  State<WaterIntakeView> createState() => _WaterIntakeViewState();
}

class _WaterIntakeViewState extends State<WaterIntakeView>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late TextEditingController _customAmountController;
  final _formKey = GlobalKey<FormState>();
  bool _showStats = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _customAmountController = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    _customAmountController.dispose();
    super.dispose();
  }

  void _showCustomAmountDialog(
      BuildContext context, WaterIntakeProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Custom Amount'),
        content: Form(
          key: _formKey,
          child: TextFormField(
            controller: _customAmountController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Amount (ml)',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter an amount';
              }
              final amount = double.tryParse(value);
              if (amount == null || amount <= 0) {
                return 'Please enter a valid amount';
              }
              if (amount > 3000) {
                return 'Amount cannot exceed 3000ml';
              }
              return null;
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                final amount = double.parse(_customAmountController.text);
                await provider.addWaterIntakeRecord(
                  await provider.getUserId(),
                  amount,
                  source: 'custom',
                );
                Navigator.pop(context);
                _customAmountController.clear();
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsView(List statistics) {
    if (statistics.isEmpty) {
      return const Center(
        child: Text('No statistics available'),
      );
    }

    final sortedStats = List<Map<String, dynamic>>.from(statistics)
      ..sort((a, b) =>
          DateTime.parse(a['_id']).compareTo(DateTime.parse(b['_id'])));

    final List<FlSpot> spots = [];
    for (var i = 0; i < sortedStats.length; i++) {
      spots.add(FlSpot(
        i.toDouble(),
        (sortedStats[i]['totalAmount'] as num).toDouble(),
      ));
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const Text(
            'Last 7 Days',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(show: false),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        if (value >= 0 && value < sortedStats.length) {
                          final date =
                              DateTime.parse(sortedStats[value.toInt()]['_id']);
                          return Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: Text(
                              DateFormat('dd/MM').format(date),
                              style: const TextStyle(fontSize: 12),
                            ),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  rightTitles:
                      AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles:
                      AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: Colors.blue,
                    barWidth: 3,
                    dotData: FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: Colors.blue.withOpacity(0.2),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) {
        final provider = WaterIntakeProvider(
          context.read<ApiService>(),
          context.read<AuthProvider>(),
        );
        Future.microtask(() async {
          final userId = await provider.getUserId();
          if (userId.isNotEmpty) {
            await provider.fetchWaterIntakeRecords(userId);
            await provider.fetchStatistics(userId);
          }
        });
        return provider;
      },
      child: Consumer<WaterIntakeProvider>(
        builder: (context, provider, child) {
          return Scaffold(
            appBar: AppBar(
              title: const Text("Water Intake"),
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              elevation: 0,
              actions: [
                IconButton(
                  icon: Icon(
                      _showStats ? Icons.show_chart : Icons.calendar_today),
                  onPressed: () => setState(() => _showStats = !_showStats),
                ),
              ],
            ),
            body: provider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : SafeArea(
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: const BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(30),
                              bottomRight: Radius.circular(30),
                            ),
                          ),
                          child: Column(
                            children: [
                              GestureDetector(
                                onTap: () async {
                                  final date = await showDatePicker(
                                    context: context,
                                    initialDate: provider.selectedDate,
                                    firstDate: DateTime(2020),
                                    lastDate: DateTime.now(),
                                  );
                                  if (date != null) {
                                    provider.setSelectedDate(date);
                                    await provider.fetchWaterIntakeRecords(
                                      await provider.getUserId(),
                                    );
                                  }
                                },
                                child: Text(
                                  DateFormat('EEEE, d MMMM y')
                                      .format(provider.selectedDate),
                                  style: const TextStyle(
                                    fontSize: 18,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              Stack(
                                alignment: Alignment.center,
                                children: [
                                  SizedBox(
                                    height: 180,
                                    width: 180,
                                    child: TweenAnimationBuilder(
                                      tween: Tween(
                                        begin: 0.0,
                                        end: provider.progressPercentage,
                                      ),
                                      duration:
                                          const Duration(milliseconds: 1000),
                                      builder: (context, value, child) {
                                        return CircularProgressIndicator(
                                          value: value,
                                          strokeWidth: 15,
                                          backgroundColor:
                                              Colors.white.withOpacity(0.3),
                                          valueColor:
                                              const AlwaysStoppedAnimation<
                                                  Color>(Colors.white),
                                        );
                                      },
                                    ),
                                  ),
                                  Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        "${provider.totalWaterIntake.toStringAsFixed(0)}ml",
                                        style: const TextStyle(
                                          fontSize: 36,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                      Text(
                                        "of ${provider.dailyGoal.toStringAsFixed(0)}ml",
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.white.withOpacity(0.8),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        "${(provider.progressPercentage * 100).toStringAsFixed(1)}%",
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        if (_showStats)
                          Expanded(
                            child: _buildStatisticsView(provider.statistics),
                          )
                        else
                          Expanded(
                            child: Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      _buildWaterButton("Small", "150ml",
                                          Colors.blue[100]!, provider),
                                      _buildWaterButton("Medium", "250ml",
                                          Colors.blue[300]!, provider),
                                      _buildWaterButton("Large", "350ml",
                                          Colors.blue[500]!, provider),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  child: provider.waterIntakeRecords.isEmpty
                                      ? Center(
                                          child: Text(
                                            'No records for ${DateFormat('dd MMM').format(provider.selectedDate)}',
                                            style: TextStyle(
                                              color: Colors.grey[600],
                                              fontSize: 16,
                                            ),
                                          ),
                                        )
                                      : ListView.builder(
                                          padding: const EdgeInsets.all(16),
                                          itemCount: provider
                                              .waterIntakeRecords.length,
                                          itemBuilder: (context, index) {
                                            final record = provider
                                                .waterIntakeRecords[index];
                                            return Dismissible(
                                              key: Key(record['_id']),
                                              direction:
                                                  DismissDirection.endToStart,
                                              background: Container(
                                                alignment:
                                                    Alignment.centerRight,
                                                padding: const EdgeInsets.only(
                                                    right: 20),
                                                color: Colors.red,
                                                child: const Icon(
                                                  Icons.delete,
                                                  color: Colors.white,
                                                ),
                                              ),
                                              onDismissed: (direction) {
                                                provider
                                                    .deleteWaterIntakeRecord(
                                                        record['_id']);
                                              },
                                              child: Card(
                                                elevation: 2,
                                                margin: const EdgeInsets.only(
                                                    bottom: 8),
                                                child: ListTile(
                                                  leading: const Icon(
                                                    Icons.water_drop,
                                                    color: Colors.blue,
                                                  ),
                                                  title: Text(
                                                    "${record['amount']}ml",
                                                    style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                  subtitle: Text(
                                                    DateFormat('HH:mm').format(
                                                        DateTime.parse(
                                                            record['date'])),
                                                  ),
                                                  trailing: record['note'] !=
                                                          null
                                                      ? Tooltip(
                                                          message:
                                                              record['note'],
                                                          child: const Icon(
                                                              Icons.info),
                                                        )
                                                      : null,
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
            floatingActionButton: FloatingActionButton(
              onPressed: () => _showCustomAmountDialog(context, provider),
              child: const Icon(Icons.add),
            ),
          );
        },
      ),
    );
  }

  Widget _buildWaterButton(
      String label, String amount, Color color, WaterIntakeProvider provider) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        backgroundColor: color,
      ),
      onPressed: () async {
        final amountInMl = int.parse(amount.replaceAll('ml', ''));
        final userId = await provider.getUserId();
        await provider.addWaterIntakeRecord(userId, amountInMl.toDouble());
      },
      child: Column(
        children: [
          const Icon(Icons.water_drop, color: Colors.white),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.white,
            ),
          ),
          Text(
            amount,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
