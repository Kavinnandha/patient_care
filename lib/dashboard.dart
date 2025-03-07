import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'diet.dart';
import 'exercise.dart';
import 'water_intake.dart';
import 'bmi_calculator.dart';
import 'blood_glucose_level.dart';
import 'medication.dart';
import 'foot_steps.dart';

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
          _buildDrawerItem(context, Icons.healing, "Foot Care", FootstepsTracker()),
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

