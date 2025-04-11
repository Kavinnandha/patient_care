import 'package:flutter/material.dart';

class BMICalculator extends StatefulWidget {
  const BMICalculator({super.key});

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
        title: const Text('BMI Calculator'),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Your BMI',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
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
                    const SizedBox(height: 20),
                    const Text(
                      'BMI Categories:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildCategoryRow('Underweight', 'Less than 18.5', Colors.blue),
                    _buildCategoryRow('Normal weight', '18.5 - 24.9', Colors.green),
                    _buildCategoryRow('Overweight', '25 - 29.9', Colors.orange),
                    _buildCategoryRow('Obesity', '30 or greater', Colors.red),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Calculate Your BMI',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text('Height (cm)'),
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
                    const SizedBox(height: 16),
                    const Text('Weight (kg)'),
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
                    const SizedBox(height: 16),
                    Center(
                      child: ElevatedButton(
                        onPressed: calculateBMI,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                        ),
                        child: const Text('Calculate'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Card(
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
      padding: const EdgeInsets.symmetric(vertical: 4),
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
          const SizedBox(width: 8),
          Text(
            category,
            style: const TextStyle(fontWeight: FontWeight.bold),
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