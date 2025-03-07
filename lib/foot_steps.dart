import 'package:flutter/material.dart';

class FootstepsTracker extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: FootstepsScreen(),
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Color(0xFF536DFE),
        scaffoldBackgroundColor: Color(0xFFF8F9FA),
        fontFamily: 'Poppins',
      ),
    );
  }
}

class FootstepsScreen extends StatefulWidget {
  @override
  _FootstepsScreenState createState() => _FootstepsScreenState();
}

class _FootstepsScreenState extends State<FootstepsScreen> {
  int steps = 3500;
  final int dailyGoal = 10000;

  @override
  Widget build(BuildContext context) {
    double progress = steps / dailyGoal;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Daily Steps",
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Color(0xFF3D4A73),
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 20),
  
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Today's Goal",
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFF8A94A6),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Color(0xFFEEF2FF),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      "$dailyGoal steps",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF536DFE),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            SizedBox(height: 30),
            
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 200,
                        height: 200,
                        child: CircularProgressIndicator(
                          value: progress,
                          strokeWidth: 15,
                          backgroundColor: Color(0xFFEEF2FF),
                          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF536DFE)),
                        ),
                      ),
                      Column(
                        children: [
                          Text(
                            "$steps",
                            style: TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF3D4A73),
                            ),
                          ),
                          Text(
                            "steps",
                            style: TextStyle(
                              fontSize: 18,
                              color: Color(0xFF8A94A6),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  
                  SizedBox(height: 20),
                  
                  Text(
                    "${(progress * 100).toInt()}% of daily goal",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF536DFE),
                    ),
                  ),
                  
                  SizedBox(height: 10),
  
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 8,
                      backgroundColor: Color(0xFFEEF2FF),
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF536DFE)),
                    ),
                  ),
                ],
              ),
            ),
            
            SizedBox(height: 30),

            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Color(0xFFEEF2FF),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Color(0xFFD0D9FF),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Color(0xFF536DFE),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.directions_walk,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Keep going!",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF3D4A73),
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          "You're on your way to reaching your daily goal.",
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF8A94A6),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            Spacer(),
            
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: Color(0xFF536DFE),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                "Update Steps",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}