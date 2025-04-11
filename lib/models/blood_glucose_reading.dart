class BloodGlucoseReading {
  final int id;
  final double value;
  final DateTime timestamp;
  final String notes;
  final String readingType;
  
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
