import 'package:flutter/material.dart';

class DietPlanView extends StatelessWidget {
  const DietPlanView({super.key});

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
        backgroundColor: Colors.blue,
        child: Icon(Icons.add),
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