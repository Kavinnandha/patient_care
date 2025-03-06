import 'package:flutter/material.dart';

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
