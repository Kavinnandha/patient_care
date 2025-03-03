import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Main Dashboard Widget
class Dashboard extends StatelessWidget {
  const Dashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Sample data - in a real app, you would get this from your data source
    final double glucoseLevel = 105.0;
    final String glucoseUnit = 'mg/dL';
    final String patientName = "John Doe";

    return Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: AppBar(
        title: Text(
          "Dashboard",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 2,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: CircleAvatar(
              backgroundColor: Colors.blue[100],
              child: Text(
                patientName.split(' ').map((e) => e[0]).join(''),
                style: TextStyle(
                  color: Colors.blue[800],
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
      drawer: _buildDrawer(context, patientName),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 8.0, bottom: 16.0),
                child: Text(
                  "Hello, ${patientName.split(' ')[0]}!",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
              Card(
                color: Colors.white,
                margin: const EdgeInsets.only(bottom: 16),
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Text(
                        "Current Glucose Level",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[700],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            glucoseLevel.toString(),
                            style: TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              color: _getGlucoseColor(glucoseLevel),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            glucoseUnit,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _getGlucoseStatus(glucoseLevel),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: _getGlucoseColor(glucoseLevel),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Medication Adherence Card
              _buildDashboardCard(
                "Medication Adherence",
                Icons.medication,
                "Today: 2/3 taken",
                "Next: Metformin (500mg) at 2:00 PM",
                Colors.orange,
              ),

              // Water Intake Card
              _buildDashboardCard(
                "Water Intake",
                Icons.water_drop,
                "1.2L / 2.5L",
                "48% of daily goal",
                Colors.blue,
              ),

              // Exercise Card
              _buildDashboardCard(
                "Today's Activity",
                Icons.directions_walk,
                "3,245 steps",
                "32% of daily goal",
                Colors.green,
              ),

              // Diet Card
              _buildDashboardCard(
                "Diet Plan",
                Icons.restaurant_menu,
                "1,450 cal consumed",
                "2 meals, 1 snack logged today",
                Colors.purple,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper method to build a dashboard card
  Widget _buildDashboardCard(String title, IconData icon, String mainStat, String subStat, Color color) {
    return Card(
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: color,
                size: 28,
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[700],
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    mainStat,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    subStat,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Build the drawer menu
  Widget _buildDrawer(BuildContext context, String patientName) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.blue,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  child: Text(
                    patientName.split(' ').map((e) => e[0]).join(''),
                    style: TextStyle(
                      fontSize: 24,
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  patientName,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                  ),
                ),
                Text(
                  "Diabetes Management",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          _buildDrawerItem(context, Icons.dashboard, "Dashboard", DashboardView()),
          _buildDrawerItem(context, Icons.bloodtype, "Blood Glucose", BloodGlucoseView()),
          _buildDrawerItem(context, Icons.medication, "Medication", MedicationView()),
          _buildDrawerItem(context, Icons.restaurant_menu, "Diet Plan", DietPlanView()),
          _buildDrawerItem(context, Icons.directions_walk, "Exercise", ExerciseView()),
          _buildDrawerItem(context, Icons.water_drop, "Water Intake", WaterIntakeView()),
          _buildDrawerItem(context, Icons.calculate, "BMI Calculator", BMICalculator()),
          _buildDrawerItem(context, Icons.healing, "Foot Care", Placeholder()),
          _buildDrawerItem(context, Icons.school, "Education", Placeholder()),
          _buildDrawerItem(context, Icons.insert_chart, "Insights", Placeholder()),
          Divider(),
          _buildDrawerItem(context, Icons.settings, "Settings", Placeholder()),
          _buildDrawerItem(context, Icons.info, "Disclaimer", Placeholder()),
          _buildDrawerItem(context, Icons.help, "Help", Placeholder()),
        ],
      ),
    );
  }

  // Helper method to build drawer items
  Widget _buildDrawerItem(BuildContext context, IconData icon, String title, Widget destination) {
    return ListTile(
      leading: Icon(icon, color: Colors.blue[800]),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
        ),
      ),
      onTap: () {
        // Close the drawer
        Navigator.pop(context);

        // Navigate to the selected view
        if (title != "Dashboard") {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => destination),
          );
        }
      },
    );
  }

  // Helper function to determine text color based on glucose level
  Color _getGlucoseColor(double level) {
    if (level < 70) {
      return Colors.orange; // Low
    } else if (level > 180) {
      return Colors.red; // High
    } else {
      return Colors.green; // Normal
    }
  }

  // Helper function to get status text based on glucose level
  String _getGlucoseStatus(double level) {
    if (level < 70) {
      return "Low";
    } else if (level > 180) {
      return "High";
    } else {
      return "Normal";
    }
  }
}

// Dashboard View (Main Screen)
class DashboardView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Dashboard();
  }
}

// Blood Glucose View
class BloodGlucoseView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Blood Glucose"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 2,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
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
                margin: EdgeInsets.only(bottom: 16),
                child: Center(
                  child: Text(
                    "Blood Glucose Graph",
                    style: TextStyle(color: Colors.grey.shade700),
                  ),
                ),
              ),

              // Log Entry Button
              ElevatedButton.icon(
                icon: Icon(Icons.add),
                label: Text("Log Blood Glucose"),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
                onPressed: () {},
              ),

              SizedBox(height: 24),
              Text(
                "Recent Readings",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 12),

              // Recent Readings List
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: 5,
                itemBuilder: (context, index) {
                  return Card(
                    margin: EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      title: Text("${110 - index * 5} mg/dL"),
                      subtitle: Text("Today, ${5 - index} hours ago"),
                      trailing: Icon(
                        Icons.circle,
                        color: index == 0 || index == 4 ? Colors.orange : Colors.green,
                        size: 12,
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
  }
}

// Medication View
class MedicationView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Medication"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 2,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Today's Medications",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 12),

              // Medication List
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: 3,
                itemBuilder: (context, index) {
                  bool taken = index < 2;
                  return Card(
                    margin: EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      leading: Icon(
                        Icons.medication,
                        color: Colors.blue,
                        size: 28,
                      ),
                      title: Text(
                        index == 0 ? "Metformin 500mg" :
                        index == 1 ? "Glimepiride 2mg" : "Metformin 500mg",
                      ),
                      subtitle: Text(
                        index == 0 ? "8:00 AM" :
                        index == 1 ? "12:00 PM" : "6:00 PM",
                      ),
                      trailing: taken
                          ? Icon(Icons.check_circle, color: Colors.green)
                          : OutlinedButton(
                        child: Text("Take Now"),
                        onPressed: () {},
                      ),
                    ),
                  );
                },
              ),

              SizedBox(height: 24),
              Text(
                "Insulin Administration",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 12),

              // Insulin Card
              Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Next Insulin Dose",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.schedule, color: Colors.blue),
                          SizedBox(width: 8),
                          Text("Before dinner (6:30 PM)"),
                        ],
                      ),
                      SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.water_drop, color: Colors.blue),
                          SizedBox(width: 8),
                          Text("12 units"),
                        ],
                      ),
                      SizedBox(height: 16),
                      OutlinedButton.icon(
                        icon: Icon(Icons.info_outline),
                        label: Text("Insulin Guide"),
                        onPressed: () {},
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: Icon(Icons.add),
        backgroundColor: Colors.blue,
      ),
    );
  }
}

// Diet Plan View
class DietPlanView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Diet Plan"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 2,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Nutrition Summary
              Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Today's Nutrition",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildNutrientCircle("Calories", "1450", "2000", Colors.orange),
                          _buildNutrientCircle("Carbs", "120g", "200g", Colors.blue),
                          _buildNutrientCircle("Protein", "75g", "100g", Colors.green),
                          _buildNutrientCircle("Fat", "45g", "65g", Colors.red),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 24),
              Text(
                "Today's Meals",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 12),

              // Meals List
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: 3,
                itemBuilder: (context, index) {
                  return Card(
                    margin: EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      leading: Icon(
                        index == 0 ? Icons.wb_sunny :
                        index == 1 ? Icons.wb_twilight : Icons.nightlight,
                        color: index == 0 ? Colors.orange :
                        index == 1 ? Colors.amber : Colors.indigo,
                      ),
                      title: Text(
                        index == 0 ? "Breakfast" :
                        index == 1 ? "Lunch" : "Dinner",
                      ),
                      subtitle: Text(
                        index == 0 ? "Oatmeal with berries" :
                        index == 1 ? "Grilled chicken salad" : "Not logged yet",
                      ),
                      trailing: index < 2
                          ? Text("✓")
                          : OutlinedButton(
                        child: Text("Log"),
                        onPressed: () {},
                      ),
                    ),
                  );
                },
              ),

              SizedBox(height: 24),
              Text(
                "Recommended Foods",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 12),

              // Recommended Foods
              Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Low Glycemic Index Foods:"),
                      SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          "Oats", "Barley", "Lentils", "Chickpeas",
                          "Yogurt", "Apples", "Berries"
                        ].map((food) => Chip(label: Text(food))).toList(),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: Icon(Icons.add),
        backgroundColor: Colors.blue,
      ),
    );
  }

  Widget _buildNutrientCircle(String label, String value, String total, Color color) {
    return Column(
      children: [
        Container(
          height: 64,
          width: 64,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: color, width: 3),
          ),
          child: Center(
            child: Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ),
        SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
          ),
        ),
        Text(
          "of $total",
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
}

// Exercise View
class ExerciseView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Exercise"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 2,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Steps Counter
              Card(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Text(
                        "Today's Steps",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[700],
                        ),
                      ),
                      SizedBox(height: 16),
                      Text(
                        "3,245",
                        style: TextStyle(
                          fontSize: 42,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[800],
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        "Goal: 10,000 steps",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                      SizedBox(height: 16),
                      LinearProgressIndicator(
                        value: 0.32,
                        minHeight: 10,
                        backgroundColor: Colors.grey[200],
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                      ),
                      SizedBox(height: 8),
                      Text(
                        "32% of daily goal",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 24),
              Text(
                "Recommended Exercises",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 12),

              // Exercise List
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: 3,
                itemBuilder: (context, index) {
                  return Card(
                    margin: EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      leading: Icon(
                        index == 0 ? Icons.directions_walk :
                        index == 1 ? Icons.pool : Icons.fitness_center,
                        color: Colors.blue,
                      ),
                      title: Text(
                        index == 0 ? "Walking" :
                        index == 1 ? "Swimming" : "Light Resistance Training",
                      ),
                      subtitle: Text(
                        index == 0 ? "30 min, 2-3 times/week" :
                        index == 1 ? "20 min, 2 times/week" : "15 min, 2 times/week",
                      ),
                      trailing: OutlinedButton(
                        child: Text("Details"),
                        onPressed: () {},
                      ),
                    ),
                  );
                },
              ),

              SizedBox(height: 24),
              Text(
                "Exercise Tips",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 12),

              Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Remember to check your blood glucose before and after exercise. Carry a fast-acting carbohydrate source with you during exercise in case of hypoglycemia.",
                        style: TextStyle(
                          fontSize: 14,
                        ),
                      ),
                      SizedBox(height: 12),
                      OutlinedButton.icon(
                        icon: Icon(Icons.lightbulb_outline),
                        label: Text("More Exercise Tips"),
                        onPressed: () {},
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: Icon(Icons.add),
        backgroundColor: Colors.blue,
      ),
    );
  }
}

// Water Intake View
class WaterIntakeView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Water Intake"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 2,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Water Progress
              Card(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Text(
                        "Today's Water Intake",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[700],
                        ),
                      ),
                      SizedBox(height: 20),
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            height: 150,
                            width: 150,
                            child: CircularProgressIndicator(
                              value: 0.48,
                              strokeWidth: 15,
                              backgroundColor: Colors.grey[200],
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                            ),
                          ),
                          Column(
                            children: [
                              Text(
                                "1.2L",
                                style: TextStyle(
                                  fontSize: 36,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue[800],
                                ),
                              ),
                              Text(
                                "of 2.5L",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      Text(
                        "48% of daily goal",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 24),

              // Add Water Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildWaterButton("Small", "150ml", Colors.blue[100]!),
                  _buildWaterButton("Medium", "250ml", Colors.blue[300]!),
                  _buildWaterButton("Large", "350ml", Colors.blue[500]!),
                ],
              ),

              SizedBox(height: 24),
              Text(
                "Today's Log",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 12),

              // Water Log
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: 5,
                itemBuilder: (context, index) {
                  return Card(
                    margin: EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: Icon(
                        Icons.water_drop,
                        color: Colors.blue,
                      ),
                      title: Text(
                          index % 2 == 0 ? "250ml" : "350ml"
                      ),
                      subtitle: Text(
                          "${5 - index} hours ago"
                      ),
                      trailing: IconButton(
                        icon: Icon(Icons.delete_outline, color: Colors.grey),
                        onPressed: () {},
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
  }

  Widget _buildWaterButton(String label, String amount, Color color) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        backgroundColor: color,
      ),
      onPressed: () {},
      child: Column(
        children: [
          Icon(Icons.water_drop, color: Colors.white),
          SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.white,
            ),
          ),
          Text(
            amount,
            style: TextStyle(
              fontSize: 12,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
class BMICalculator extends StatefulWidget {
  @override
  _BMICalculatorViewState createState() => _BMICalculatorViewState();
}

class _BMICalculatorViewState extends State<BMICalculator> {
  // Hardcoded values for now
  double height = 170; // in cm
  double weight = 70; // in kg
  double bmi = 0;
  String bmiCategory = '';
  Color categoryColor = Colors.grey;

  @override
  void initState() {
    super.initState();
    calculateBMI();
  }

  void calculateBMI() {
    // BMI formula: weight (kg) / (height (m))²
    double heightInMeters = height / 100;
    bmi = weight / (heightInMeters * heightInMeters);

    // Determine BMI category
    if (bmi < 18.5) {
      bmiCategory = 'Underweight';
      categoryColor = Colors.blue;
    } else if (bmi >= 18.5 && bmi < 25) {
      bmiCategory = 'Normal';
      categoryColor = Colors.green;
    } else if (bmi >= 25 && bmi < 30) {
      bmiCategory = 'Overweight';
      categoryColor = Colors.orange;
    } else {
      bmiCategory = 'Obese';
      categoryColor = Colors.red;
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('BMI Calculator'),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 4,
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Your BMI',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 20),
                    Center(
                      child: Container(
                        width: 150,
                        height: 150,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: categoryColor.withOpacity(0.2),
                          border: Border.all(
                            color: categoryColor,
                            width: 3,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              bmi.toStringAsFixed(1),
                              style: TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                                color: categoryColor,
                              ),
                            ),
                            Text(
                              bmiCategory,
                              style: TextStyle(
                                fontSize: 18,
                                color: categoryColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    Text(
                      'BMI Categories:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    _buildCategoryRow('Underweight', 'Less than 18.5', Colors.blue),
                    _buildCategoryRow('Normal weight', '18.5 - 24.9', Colors.green),
                    _buildCategoryRow('Overweight', '25 - 29.9', Colors.orange),
                    _buildCategoryRow('Obesity', '30 or greater', Colors.red),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            Card(
              elevation: 4,
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Calculate Your BMI',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 16),
                    Text('Height (cm)'),
                    Slider(
                      value: height,
                      min: 120,
                      max: 220,
                      divisions: 100,
                      label: height.round().toString(),
                      onChanged: (double value) {
                        setState(() {
                          height = value;
                          calculateBMI();
                        });
                      },
                    ),
                    Text('${height.round()} cm'),
                    SizedBox(height: 16),
                    Text('Weight (kg)'),
                    Slider(
                      value: weight,
                      min: 30,
                      max: 150,
                      divisions: 120,
                      label: weight.round().toString(),
                      onChanged: (double value) {
                        setState(() {
                          weight = value;
                          calculateBMI();
                        });
                      },
                    ),
                    Text('${weight.round()} kg'),
                    SizedBox(height: 16),
                    Center(
                      child: ElevatedButton(
                        onPressed: calculateBMI,
                        child: Text('Calculate'),
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            Card(
              elevation: 4,
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'What is BMI?',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Body Mass Index (BMI) is a person\'s weight in kilograms divided by the square of height in meters. BMI is an inexpensive and easy screening method for weight category—underweight, normal weight, overweight, and obesity.',
                      style: TextStyle(fontSize: 14),
                    ),
                    SizedBox(height: 12),
                    Text(
                      'BMI does not measure body fat directly, but research has shown that BMI is moderately correlated with more direct measures of body fat. Additionally, BMI appears to be as strongly correlated with various metabolic and disease outcomes as are these more direct measures of body fatness.',
                      style: TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryRow(String category, String range, Color color) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 8),
          Text(
            category,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(': $range'),
        ],
      ),
    );
  }
}

// This is the helper function for the drawer item
Widget _buildDrawerItem(BuildContext context, IconData icon, String title, Widget destination) {
  return ListTile(
    leading: Icon(icon),
    title: Text(title),
    onTap: () {
      Navigator.pop(context); // Close the drawer
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => destination),
      );
    },
  );
}