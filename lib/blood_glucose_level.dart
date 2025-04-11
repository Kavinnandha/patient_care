import 'package:flutter/material.dart';
import 'api_service.dart';
import 'package:provider/provider.dart';
import 'blood_glucose_history_page.dart';

class BloodGlucoseView extends StatefulWidget {
  const BloodGlucoseView({super.key});

  @override
  _BloodGlucoseViewState createState() => _BloodGlucoseViewState();
}

class _BloodGlucoseViewState extends State<BloodGlucoseView> {
  @override
  void initState() {
    super.initState();
    // Fetch data when the screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<BloodGlucoseProvider>(context, listen: false).fetchReadings();
    });
  }

  void _showAddReadingDialog(BuildContext context, {BloodGlucoseReading? reading}) {
    double glucoseValue = reading?.value ?? 100.0;
    String readingType = reading?.readingType ?? 'Before meal';
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
                    value: glucoseValue,
                    timestamp: reading.timestamp,
                    readingType: readingType,
                    notes: reading.notes,
                  );
                  Provider.of<BloodGlucoseProvider>(context, listen: false)
                      .updateReading(updatedReading);
                } else {
                  // Create new reading
                  final newReading = BloodGlucoseReading(
                    id: -1, // ID will be assigned by the server
                    value: glucoseValue,
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
  Color _getColorForReading(double value) {
    if (value < 70) return Colors.red; // Low
    if (value > 180) return Colors.red; // High
    if (value > 140) return Colors.orange; // Elevated
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
            
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Graph Placeholder (would be replaced with actual chart)
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
                  // Recent Readings List
                  provider.readings.isEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(
                              "No readings recorded yet. Tap 'Log Blood Glucose' to add your first reading.",
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.grey.shade600),
                            ),
                          ),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: provider.readings.length > 5 
                              ? 5 
                              : provider.readings.length,
                          itemBuilder: (context, index) {
                            final reading = provider.readings[index];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              child: ListTile(
                                title: Text("${reading.value} mg/dL"),
                                subtitle: Text(
                                  "${_formatTimestamp(reading.timestamp)} • ${reading.readingType}"
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.circle,
                                      color: _getColorForReading(reading.value),
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
                            );
                          },
                        ),
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
              ),
            );
          },
        ),
      ),
    );
  }
}

class BloodGlucoseReading {
  final int id;
  final double value;
  final DateTime timestamp;
  final String notes;
  final String readingType; // before meal, after meal, etc.
  
  BloodGlucoseReading({
    required this.id,
    required this.value,
    required this.timestamp,
    this.notes = '',
    required this.readingType,
  });
  
  factory BloodGlucoseReading.fromJson(Map<String, dynamic> json) {
    return BloodGlucoseReading(
      id: json['id'],
      value: json['value'].toDouble(),
      timestamp: DateTime.parse(json['timestamp']),
      notes: json['notes'] ?? '',
      readingType: json['reading_type'],
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'value': value,
      'timestamp': timestamp.toIso8601String(),
      'notes': notes,
      'reading_type': readingType,
    };
  }
}

class BloodGlucoseRepository {
  final ApiService _apiService;
  
  BloodGlucoseRepository(this._apiService);
  
  Future<List<BloodGlucoseReading>> getReadings() async {
    final response = await _apiService.get('blood-glucose');
    
    return (response as List)
        .map((item) => BloodGlucoseReading.fromJson(item))
        .toList();
  }
  
  Future<BloodGlucoseReading> addReading(BloodGlucoseReading reading) async {
    final response = await _apiService.post(
      'blood-glucose',
      reading.toJson(),
    );
    
    return BloodGlucoseReading.fromJson(response);
  }
  
  Future<BloodGlucoseReading> updateReading(BloodGlucoseReading reading) async {
    final response = await _apiService.put(
      'blood-glucose/${reading.id}',
      reading.toJson(),
    );
    
    return BloodGlucoseReading.fromJson(response);
  }
  
  Future<void> deleteReading(int id) async {
    await _apiService.delete('blood-glucose/$id');
  }
}

class BloodGlucoseProvider with ChangeNotifier {
  final BloodGlucoseRepository _repository;
  List<BloodGlucoseReading> _readings = [];
  bool _isLoading = false;
  String? _error;
  
  BloodGlucoseProvider(this._repository);
  
  List<BloodGlucoseReading> get readings => _readings;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  Future<void> fetchReadings() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      _readings = await _repository.getReadings();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<void> updateReading(BloodGlucoseReading reading) async {
    try {
      final updatedReading = await _repository.updateReading(reading);
      final index = _readings.indexWhere((r) => r.id == reading.id);
      if (index != -1) {
        _readings[index] = updatedReading;
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> addReading(BloodGlucoseReading reading) async {
    try {
      final newReading = await _repository.addReading(reading);
      _readings.add(newReading);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }
  
  Future<void> deleteReading(int id) async {
    try {
      await _repository.deleteReading(id);
      _readings.removeWhere((reading) => reading.id == id);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }
}
