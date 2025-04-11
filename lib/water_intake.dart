import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/water_intake_provider.dart';

class WaterIntakeView extends StatelessWidget {
  const WaterIntakeView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => WaterIntakeProvider()..fetchWaterIntakeRecords('userId'),
      child: Consumer<WaterIntakeProvider>(
        builder: (context, provider, child) {
          return Scaffold(
            appBar: AppBar(
              title: const Text("Water Intake"),
              backgroundColor: Colors.white,
              foregroundColor: Colors.black87,
              elevation: 2,
            ),
            body: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Water Progress
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            Text(
                              "Today's Water Intake",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[700],
                              ),
                            ),
                            const SizedBox(height: 20),
                            Stack(
                              alignment: Alignment.center,
                              children: [
                                SizedBox(
                                  height: 150,
                                  width: 150,
                                  child: CircularProgressIndicator(
                                    value: provider.totalWaterIntake / 2500,
                                    strokeWidth: 15,
                                    backgroundColor: Colors.grey[200],
                                    valueColor:
                                        const AlwaysStoppedAnimation<Color>(
                                            Colors.blue),
                                  ),
                                ),
                                Column(
                                  children: [
                                    Text(
                                      "${provider.totalWaterIntake}ml",
                                      style: TextStyle(
                                        fontSize: 36,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue[800],
                                      ),
                                    ),
                                    const Text(
                                      "of 2500ml",
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Text(
                              "${((provider.totalWaterIntake / 2500) * 100).toStringAsFixed(0)}% of daily goal",
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.blue,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Add Water Buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildWaterButton(
                            "Small", "150ml", Colors.blue[100]!, provider),
                        _buildWaterButton(
                            "Medium", "250ml", Colors.blue[300]!, provider),
                        _buildWaterButton(
                            "Large", "350ml", Colors.blue[500]!, provider),
                      ],
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      "Today's Log",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Water Log
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: provider.waterIntakeRecords.length,
                      itemBuilder: (context, index) {
                        final record = provider.waterIntakeRecords[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: const Icon(
                              Icons.water_drop,
                              color: Colors.blue,
                            ),
                            title: Text("${record['amount']}ml"),
                            subtitle: Text("${record['date']}"),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete_outline,
                                  color: Colors.grey),
                              onPressed: () {
                                provider.deleteWaterIntakeRecord(record['id']);
                              },
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
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
      onPressed: () {
        final amountInMl = int.parse(amount.replaceAll('ml', ''));
        provider.addWaterIntakeRecord('userId', amountInMl.toDouble());
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
