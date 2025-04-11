import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'blood_glucose_level.dart';

class BloodGlucoseHistoryPage extends StatefulWidget {
  const BloodGlucoseHistoryPage({super.key});

  @override
  State<BloodGlucoseHistoryPage> createState() => _BloodGlucoseHistoryPageState();
}

class _BloodGlucoseHistoryPageState extends State<BloodGlucoseHistoryPage> {
  String _selectedFilter = 'All';
  String _sortOrder = 'Newest';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Blood Glucose History'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 2,
      ),
      body: Column(
        children: [
          // Filters
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Filter by Type',
                      border: OutlineInputBorder(),
                    ),
                    value: _selectedFilter,
                    items: [
                      'All',
                      'Before meal',
                      'After meal',
                      'Fasting',
                      'Random',
                    ].map((type) {
                      return DropdownMenuItem(
                        value: type,
                        child: Text(type),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedFilter = value!;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Sort by',
                      border: OutlineInputBorder(),
                    ),
                    value: _sortOrder,
                    items: [
                      'Newest',
                      'Oldest',
                      'Highest',
                      'Lowest',
                    ].map((order) {
                      return DropdownMenuItem(
                        value: order,
                        child: Text(order),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _sortOrder = value!;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
          // List of readings
          Expanded(
            child: Consumer<BloodGlucoseProvider>(
              builder: (context, provider, _) {
                var readings = provider.readings;
                
                // Apply filters
                if (_selectedFilter != 'All') {
                  readings = readings.where((r) => r.readingType == _selectedFilter).toList();
                }
                
                // Apply sorting
                switch (_sortOrder) {
                  case 'Newest':
                    readings.sort((a, b) => b.timestamp.compareTo(a.timestamp));
                    break;
                  case 'Oldest':
                    readings.sort((a, b) => a.timestamp.compareTo(b.timestamp));
                    break;
                  case 'Highest':
                    readings.sort((a, b) => b.value.compareTo(a.value));
                    break;
                  case 'Lowest':
                    readings.sort((a, b) => a.value.compareTo(b.value));
                    break;
                }
                
                if (readings.isEmpty) {
                  return Center(
                    child: Text(
                      _selectedFilter == 'All'
                          ? 'No readings recorded yet'
                          : 'No $_selectedFilter readings found',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: readings.length,
                  itemBuilder: (context, index) {
                    final reading = readings[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        title: Text(
                          "${reading.value} mg/dL",
                          style: TextStyle(
                            color: _getColorForReading(reading.value),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(
                          "${_formatTimestamp(reading.timestamp)}\n${reading.readingType}",
                        ),
                        trailing: PopupMenuButton<String>(
                          icon: const Icon(Icons.more_vert),
                          onSelected: (value) {
                            if (value == 'edit') {
                              _showEditDialog(context, reading);
                            } else if (value == 'delete') {
                              _showDeleteConfirmation(context, reading);
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
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(BuildContext context, BloodGlucoseReading reading) {
    showDialog(
      context: context,
      builder: (context) {
        double glucoseValue = reading.value;
        String readingType = reading.readingType;
        final formKey = GlobalKey<FormState>();

        return AlertDialog(
          title: const Text('Edit Reading'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Glucose Value (mg/dL)'),
                  keyboardType: TextInputType.number,
                  initialValue: glucoseValue.toString(),
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
                    glucoseValue = double.parse(value!);
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'Reading Type'),
                  value: readingType,
                  items: ['Before meal', 'After meal', 'Fasting', 'Random']
                      .map((type) => DropdownMenuItem(
                            value: type,
                            child: Text(type),
                          ))
                      .toList(),
                  onChanged: (value) {
                    readingType = value!;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  formKey.currentState!.save();
                  
                  final updatedReading = BloodGlucoseReading(
                    id: reading.id,
                    value: glucoseValue,
                    timestamp: reading.timestamp,
                    readingType: readingType,
                    notes: reading.notes,
                  );
                  
                  Provider.of<BloodGlucoseProvider>(context, listen: false)
                      .updateReading(updatedReading);
                  
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteConfirmation(BuildContext context, BloodGlucoseReading reading) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Reading'),
        content: const Text('Are you sure you want to delete this reading?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Provider.of<BloodGlucoseProvider>(context, listen: false)
                  .deleteReading(reading.id);
              Navigator.of(context).pop();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Color _getColorForReading(double value) {
    if (value < 70) return Colors.red;
    if (value > 180) return Colors.red;
    if (value > 140) return Colors.orange;
    return Colors.green;
  }

  String _formatTimestamp(DateTime timestamp) {
    return '${timestamp.day}/${timestamp.month}/${timestamp.year}, ${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}';
  }
}
