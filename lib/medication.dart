import 'package:flutter/material.dart';

class MedicationView extends StatelessWidget {
  const MedicationView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Medications", 
          style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Today's Medications Section
          const Text("Today's Medications",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          
          // Medication 1
          _buildMedicationCard(
            "Metformin 500mg",
            "8:00 AM",
            true,
          ),
          
          // Medication 2
          _buildMedicationCard(
            "Glimepiride 2mg",
            "12:00 PM",
            true,
          ),
          
          // Medication 3
          _buildMedicationCard(
            "Metformin 500mg",
            "6:00 PM",
            false,
          ),
          
          const SizedBox(height: 24),
          
          // Insulin Section
          const Text("Insulin Administration",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          _buildInsulinCard(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add),
      ),
    );
  }

  // Simple medication card
  Widget _buildMedicationCard(String name, String time, bool taken) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Medication icon
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: taken ? Colors.green.shade100 : Colors.blue.shade100,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.medication, 
                color: taken ? Colors.green : Colors.blue,
              ),
            ),
            const SizedBox(width: 16),
            
            // Medication details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  )),
                  Text(time, style: TextStyle(color: Colors.grey.shade700)),
                ],
              ),
            ),
            
            // Action button or status
            taken
                ? const Icon(Icons.check_circle, color: Colors.green)
                : ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    onPressed: () {},
                    child: const Text("Take Now"),
                  ),
          ],
        ),
      ),
    );
  }

  // Insulin card
  Widget _buildInsulinCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Insulin header
            const Row(
              children: [
                Icon(Icons.medical_services, color: Colors.blue),
                SizedBox(width: 10),
                Text("Before dinner (6:30 PM)",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 12),
            
            // Dosage
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                children: [
                  Icon(Icons.water_drop, color: Colors.blue),
                  SizedBox(width: 8),
                  Text("12 units", 
                    style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            const SizedBox(height: 16),
            
            // Action buttons
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onPressed: () {},
                child: const Text("Record Dose", 
                  style: TextStyle(fontSize: 16)),
              ),
            ),
            TextButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.info_outline, size: 16, color: Colors.blue),
              label: const Text("Insulin Guide", style: TextStyle(color: Colors.blue)),
            ),
          ],
        ),
      ),
    );
  }
}