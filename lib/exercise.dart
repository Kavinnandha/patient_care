import 'package:flutter/material.dart';

class ExerciseView extends StatelessWidget {
  const ExerciseView({super.key});

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
        backgroundColor: Colors.blue,
        child: Icon(Icons.add),
      ),
    );
  }
}