import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'providers/dashboard_provider.dart';
import 'providers/auth_provider.dart';
import 'package:patient_care/setting.dart';
import 'diet.dart';
import 'exercise.dart';
import 'water_intake.dart';
import 'bmi_calculator.dart';
import 'blood_glucose_level.dart';
import 'medication.dart';
import 'appointment.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  final RefreshController _refreshController = RefreshController();

  @override
  void initState() {
    super.initState();
    // Fetch dashboard data when the screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<DashboardProvider>(context, listen: false).refreshDashboard();
    });
  }

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  Future<void> _onRefresh() async {
    try {
      await Provider.of<DashboardProvider>(context, listen: false)
          .refreshDashboard();
      _refreshController.refreshCompleted();
    } catch (e) {
      _refreshController.refreshFailed();
    }
  }

  @override
  Widget build(BuildContext context) {
    final dashboardProvider = Provider.of<DashboardProvider>(context);
    final double? glucoseLevel = dashboardProvider.currentGlucoseLevel;
    final String glucoseUnit = 'mg/dL';
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final String patientName = authProvider.username ?? "Patient";

    return Scaffold(
      backgroundColor: Color(0xFFF4F7FA),
      appBar: AppBar(
        title: Text(
          "Dashboard",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w700,
            color: Colors.black87,
            letterSpacing: 0.5,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        shadowColor: Colors.black26,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [Colors.blue[200]!, Colors.blue[400]!],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.3),
                    spreadRadius: 1,
                    blurRadius: 6,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: CircleAvatar(
                backgroundColor: Colors.transparent,
                child: Text(
                  patientName.split(' ').map((e) => e[0]).join(''),
                  style: GoogleFonts.roboto(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      drawer: _buildDrawer(context, patientName),
      body: SmartRefresher(
        controller: _refreshController,
        onRefresh: _onRefresh,
        child: SafeArea(
          child: SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 8.0, bottom: 16.0),
                  child: Text(
                    "Hello, ${patientName.split(' ')[0]}!",
                    style: GoogleFonts.poppins(
                      fontSize: 28,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                
                _buildGlucoseLevelCard(glucoseLevel, glucoseUnit, context),

                _buildDashboardCard(
                  "Medication Adherence",
                  Icons.medication,
                  "Today: ${dashboardProvider.medicationsTaken}/${dashboardProvider.totalMedications} taken",
                  "Tap to view medications",
                  Colors.orange,
                  context,
                  MedicationView(),
                ),
                _buildDashboardCard(
                  "Blood Glucose",
                  Icons.bloodtype,
                  "${dashboardProvider.averageGlucoseToday?.toStringAsFixed(1) ?? 'No data'} $glucoseUnit avg",
                  "Today's average",
                  Colors.blue,
                  context,
                  WaterIntakeView(),
                ),
                _buildDashboardCard(
                  "Vital Signs",
                  Icons.favorite,
                  _formatVitalSigns(dashboardProvider.latestVitals),
                  "Latest readings",
                  Colors.green,
                  context,
                  ExerciseView(),
                ),
                _buildDashboardCard(
                  "Diet Plan",
                  Icons.restaurant_menu,
                  "${dashboardProvider.totalCaloriesToday} cal consumed",
                  "Today's intake",
                  Colors.purple,
                  context,
                  DietPlanView(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Glucose Level Card
  String _formatVitalSigns(Map<String, dynamic>? vitals) {
    if (vitals == null) return 'No data available';
    
    final List<String> readings = [];
    
    if (vitals['blood_pressure_systolic'] != null && vitals['blood_pressure_diastolic'] != null) {
      readings.add('${vitals['blood_pressure_systolic']}/${vitals['blood_pressure_diastolic']} mmHg');
    }
    
    if (vitals['heart_rate'] != null) {
      readings.add('${vitals['heart_rate']} bpm');
    }
    
    return readings.isEmpty ? 'No data available' : readings.join(' • ');
  }

  Widget _buildGlucoseLevelCard(
    double? glucoseLevel, 
    String glucoseUnit, 
    BuildContext context
  ) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => BloodGlucoseView()),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: [
              Colors.white.withOpacity(0.7),
              Colors.white.withOpacity(0.5),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
          border: Border.all(
            color: Colors.white.withOpacity(0.4),
            width: 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Text(
                "Current Glucose Level",
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    glucoseLevel?.toString() ?? 'N/A',
                    style: GoogleFonts.roboto(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: glucoseLevel != null ? _getGlucoseColor(glucoseLevel) : Colors.grey,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    glucoseUnit,
                    style: GoogleFonts.roboto(
                      fontSize: 16,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (glucoseLevel != null)
                Text(
                  _getGlucoseStatus(glucoseLevel),
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: _getGlucoseColor(glucoseLevel),
                    letterSpacing: 0.5,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // Dashboard Card
  Widget _buildDashboardCard(
    String title, 
    IconData icon, 
    String mainStat, 
    String subStat, 
    Color color,
    BuildContext context,
    Widget destination
  ) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => destination),
        );
      },
      child: Card(
        color: Colors.white,
        margin: const EdgeInsets.only(bottom: 16),
        elevation: 6,
        shadowColor: color.withOpacity(0.2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [color.withOpacity(0.1), color.withOpacity(0.2)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(15),
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
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      mainStat,
                      style: GoogleFonts.roboto(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      subStat,
                      style: GoogleFonts.roboto(
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Drawer Method
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
          _buildDrawerItem(context, Icons.dashboard, "Dashboard", Dashboard()),
          _buildDrawerItem(context, Icons.bloodtype, "Blood Glucose", BloodGlucoseView()),
          _buildDrawerItem(context, Icons.medication, "Medication", MedicationView()),
          _buildDrawerItem(context, Icons.restaurant_menu, "Diet Plan", DietPlanView()),
          _buildDrawerItem(context, Icons.directions_walk, "Exercise", ExerciseView()),
          _buildDrawerItem(context, Icons.water_drop, "Water Intake", WaterIntakeView()),
          _buildDrawerItem(context, Icons.calculate, "BMI Calculator", BMICalculator()),
          _buildDrawerItem(context, Icons.healing, "Foot Care", Placeholder()),
          _buildDrawerItem(context, Icons.school, "Appointment", DoctorAppointmentPage()),
          _buildDrawerItem(context, Icons.insert_chart, "Insights", Placeholder()),
          Divider(),
          _buildDrawerItem(context, Icons.settings, "Settings", SettingsPage()),
          _buildDrawerItem(context, Icons.info, "Disclaimer", Placeholder()),
          _buildDrawerItem(context, Icons.help, "Help", Placeholder()),
        ],
      ),
    );
  }

  // Drawer Item Method
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

  // Glucose Level Helpers
  Color _getGlucoseColor(double level) {
    if (level < 70) {
      return Colors.orange; // Low
    } else if (level > 180) {
      return Colors.red; // High
    } else {
      return Colors.green; // Normal
    }
  }

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

// Placeholder for unimplemented screens
class Placeholder extends StatelessWidget {
  const Placeholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Coming Soon'),
      ),
      body: Center(
        child: Text('This feature is not yet implemented'),
      ),
    );
  }
}
