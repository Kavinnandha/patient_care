import 'package:flutter/material.dart';
class WaterIntakeView extends StatelessWidget {
  const WaterIntakeView({super.key});

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