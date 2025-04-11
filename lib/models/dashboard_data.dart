class DashboardData {
  final List<Map<String, dynamic>> recentGlucoseReadings;
  final List<Map<String, dynamic>> todaysMedications;
  final List<Map<String, dynamic>> recentFoodIntake;
  final List<Map<String, dynamic>> vitalSigns;
  final Map<String, dynamic> stats;
  final DateTime lastUpdated;

  double get currentGlucoseLevel {
    if (recentGlucoseReadings.isEmpty) return 0.0;
    return (recentGlucoseReadings.first['glucoseLevel'] as num).toDouble();
  }

  double get averageGlucoseToday {
    if (recentGlucoseReadings.isEmpty) return 0.0;
    final todaysReadings = recentGlucoseReadings.where((reading) {
      final readingDate = DateTime.parse(reading['createdAt'] as String);
      final today = DateTime.now();
      return readingDate.year == today.year &&
             readingDate.month == today.month &&
             readingDate.day == today.day;
    }).toList();

    if (todaysReadings.isEmpty) return 0.0;
    
    final sum = todaysReadings.fold<double>(
      0.0,
      (sum, reading) => sum + (reading['glucoseLevel'] as num).toDouble(),
    );
    return sum / todaysReadings.length;
  }

  Map<String, dynamic>? get latestVitals {
    if (vitalSigns.isEmpty) return null;
    return vitalSigns.last;
  }

  int get medicationsTaken {
    return todaysMedications.where((med) => med['taken'] == true).length;
  }

  int get totalMedications {
    return todaysMedications.length;
  }

  double get totalCaloriesToday {
    if (recentFoodIntake.isEmpty) return 0.0;
    return recentFoodIntake.fold<double>(
      0.0,
      (sum, intake) => sum + (intake['calories'] as num).toDouble(),
    );
  }

  DashboardData({
    required this.recentGlucoseReadings,
    required this.todaysMedications,
    required this.recentFoodIntake,
    required this.vitalSigns,
    required this.stats,
    DateTime? lastUpdated,
  }) : this.lastUpdated = lastUpdated ?? DateTime.now();

  DashboardData.empty()
      : recentGlucoseReadings = [],
        todaysMedications = [],
        recentFoodIntake = [],
        vitalSigns = [],
        stats = {
          'averageGlucose': 0.0,
          'medicationAdherence': 0.0,
          'lastVitalCheck': null,
        },
        lastUpdated = DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'recentGlucoseReadings': recentGlucoseReadings,
      'todaysMedications': todaysMedications,
      'recentFoodIntake': recentFoodIntake,
      'vitalSigns': vitalSigns,
      'stats': stats,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  factory DashboardData.fromJson(Map<String, dynamic> json) {
    return DashboardData(
      recentGlucoseReadings: List<Map<String, dynamic>>.from(json['recentGlucoseReadings'] ?? []),
      todaysMedications: List<Map<String, dynamic>>.from(json['todaysMedications'] ?? []),
      recentFoodIntake: List<Map<String, dynamic>>.from(json['recentFoodIntake'] ?? []),
      vitalSigns: List<Map<String, dynamic>>.from(json['vitalSigns'] ?? []),
      stats: Map<String, dynamic>.from(json['stats'] ?? {}),
      lastUpdated: json['lastUpdated'] != null 
          ? DateTime.parse(json['lastUpdated'])
          : null,
    );
  }
}
