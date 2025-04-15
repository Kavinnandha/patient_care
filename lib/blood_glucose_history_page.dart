import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/blood_glucose_provider.dart';
import 'widgets/blood_glucose_graph.dart';

class BloodGlucoseHistoryPage extends StatefulWidget {
  const BloodGlucoseHistoryPage({super.key});

  @override
  State<BloodGlucoseHistoryPage> createState() =>
      _BloodGlucoseHistoryPageState();
}

class _BloodGlucoseHistoryPageState extends State<BloodGlucoseHistoryPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Helper method to determine color based on glucose value
  Color _getColorForReading(double glucoseLevel) {
    if (glucoseLevel < 70) return Colors.red; // Low
    if (glucoseLevel > 180) return Colors.red; // High
    if (glucoseLevel > 140) return Colors.orange; // Elevated
    return Colors.green; // Normal
  }

  // Format timestamp to readable format
  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year}, ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Blood Glucose History'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 2,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Graph'),
            Tab(text: 'List'),
          ],
          labelColor: Colors.blue,
          unselectedLabelColor: Colors.black54,
        ),
      ),
      body: Consumer<BloodGlucoseProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Failed to load readings: ${provider.error}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => provider.fetchReadings(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (provider.readings.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  "No readings recorded yet.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              ),
            );
          }

          return TabBarView(
            controller: _tabController,
            children: [
              SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(
                      height: 350,
                      child: BloodGlucoseGraph(
                        readings: provider.readings,
                        height: 350,
                      ),
                    ),
                  ],
                ),
              ),
              ListView.builder(
                padding: const EdgeInsets.all(8),
                itemCount: provider.readings.length,
                itemBuilder: (context, index) {
                  final reading = provider.readings[index];
                  return Card(
                    margin:
                        const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                    child: ListTile(
                      title: Text("${reading.glucoseLevel} mg/dL"),
                      subtitle: Text(
                          "${_formatDateTime(reading.timestamp)} • ${BloodGlucoseReading.convertReadingTypeToUI(reading.readingType)}"),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.circle,
                            color: _getColorForReading(reading.glucoseLevel),
                            size: 12,
                          ),
                          const SizedBox(width: 8),
                          PopupMenuButton<String>(
                            icon: const Icon(Icons.more_vert),
                            onSelected: (value) {
                              if (value == 'delete') {
                                provider.deleteReading(reading.id);
                              }
                            },
                            itemBuilder: (context) => [
                              const PopupMenuItem(
                                value: 'delete',
                                child: Text('Delete'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
