import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/blood_glucose_provider.dart';
import 'blood_glucose_history_page.dart';

class BloodGlucoseView extends StatefulWidget {
  const BloodGlucoseView({super.key});

  @override
  BloodGlucoseViewState createState() => BloodGlucoseViewState();
}

class BloodGlucoseViewState extends State<BloodGlucoseView> {
  @override
  void initState() {
    super.initState();
    // Fetch data when the screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<BloodGlucoseProvider>(context, listen: false).fetchReadings();
    });
  }

  void _showAddReadingDialog(BuildContext context, {BloodGlucoseReading? reading}) {
    double glucoseLevel = reading?.glucoseLevel ?? 100.0;
    String readingType = reading?.readingType ?? 'pre_meal';
    final formKey = GlobalKey<FormState>();
    final isEditing = reading != null;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('${isEditing ? 'Edit' : 'Add'} Blood Glucose Reading'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Glucose Value (mg/dL)'),
                keyboardType: TextInputType.number,
                initialValue: glucoseLevel.toString(),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a value';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
                onSaved: (value) {
                  glucoseLevel = double.parse(value!);
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Reading Type'),
                value: BloodGlucoseReading.convertReadingTypeToUI(readingType),
                items: ['Before meal', 'After meal', 'Fasting', 'Bedtime', 'Random']
                    .map((type) => DropdownMenuItem(
                          value: type,
                          child: Text(type),
                        ))
                    .toList(),
                onChanged: (value) {
                  readingType = BloodGlucoseReading.convertReadingType(value!);
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                formKey.currentState!.save();
                
                if (isEditing) {
                  // Update existing reading
                  final updatedReading = BloodGlucoseReading(
                    id: reading.id,
                    patientId: reading.patientId,
                    glucoseLevel: glucoseLevel,
                    timestamp: reading.timestamp,
                    readingType: readingType,
                    notes: reading.notes,
                  );
                  Provider.of<BloodGlucoseProvider>(context, listen: false)
                      .updateReading(updatedReading);
                } else {
                  // Create new reading
                  final newReading = BloodGlucoseReading(
                    id: '', // ID will be assigned by the server
                    patientId: Provider.of<BloodGlucoseProvider>(context, listen: false).currentUserId ?? '',
                    glucoseLevel: glucoseLevel,
                    timestamp: DateTime.now(),
                    readingType: readingType,
                  );
                  Provider.of<BloodGlucoseProvider>(context, listen: false)
                      .addReading(newReading);
                }
                
                Navigator.of(ctx).pop();
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  // Helper method to determine color based on glucose value
  Color _getColorForReading(double glucoseLevel) {
    if (glucoseLevel < 70) return Colors.red; // Low
    if (glucoseLevel > 180) return Colors.red; // High
    if (glucoseLevel > 140) return Colors.orange; // Elevated
    return Colors.green; // Normal
  }

  // Format timestamp to readable format
  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    
    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return 'Just now';
      }
      return 'Today, ${difference.inHours} ${difference.inHours == 1 ? 'hour' : 'hours'} ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday, ${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}, ${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Blood Glucose"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 2,
      ),
      body: SafeArea(
        child: Consumer<BloodGlucoseProvider>(
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
            
            // Use ListView as the main scrollable container to fix overflow
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Graph Placeholder
                Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  margin: const EdgeInsets.only(bottom: 16),
                  child: provider.readings.isEmpty
                      ? Center(
                          child: Text(
                            "No data to display",
                            style: TextStyle(color: Colors.grey.shade700),
                          ),
                        )
                      : Center(
                          child: Text(
                            "Blood Glucose Graph",
                            style: TextStyle(color: Colors.grey.shade700),
                          ),
                        ),
                ),
                
                // Log Entry Button
                ElevatedButton.icon(
                  icon: const Icon(Icons.add),
                  label: const Text("Log Blood Glucose"),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () => _showAddReadingDialog(context),
                ),
                
                const SizedBox(height: 24),
                
                const Text(
                  "Recent Readings",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                
                const SizedBox(height: 12),
                
                // Recent Readings List - Use Column instead of nested ListView
                if (provider.readings.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        "No readings recorded yet. Tap 'Log Blood Glucose' to add your first reading.",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    ),
                  )
                else
                  ...provider.readings.take(5).map((reading) => Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      title: Text("${reading.glucoseLevel} mg/dL"),
                      subtitle: Text(
                        "${_formatTimestamp(reading.timestamp)} • ${BloodGlucoseReading.convertReadingTypeToUI(reading.readingType)}"
                      ),
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
                              if (value == 'edit') {
                                _showAddReadingDialog(context, reading: reading);
                              } else if (value == 'delete') {
                                provider.deleteReading(reading.id);
                              }
                            },
                            itemBuilder: (context) => [
                              const PopupMenuItem(
                                value: 'edit',
                                child: Text('Edit'),
                              ),
                              const PopupMenuItem(
                                value: 'delete',
                                child: Text('Delete'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  )).toList(),
                  
                if (provider.readings.length > 5)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const BloodGlucoseHistoryPage(),
                          ),
                        );
                      },
                      child: const Text('View Full History'),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
