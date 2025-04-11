import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'login_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        final profile = auth.userProfile;
        
        if (profile == null) {
          return const Center(child: CircularProgressIndicator());
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Profile'),
            actions: [
              IconButton(
                icon: const Icon(Icons.logout),
                onPressed: () async {
                  await auth.logout();
                  if (context.mounted) {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (context) => const LoginPage()),
                      (route) => false,
                    );
                  }
                },
              ),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CircleAvatar(
                    radius: 50,
                    child: Icon(Icons.person, size: 50),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    '${profile.firstName} ${profile.lastName}',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 20),
                  _buildInfoCard(
                    context: context,
                    title: 'Personal Information',
                    children: [
                      _buildInfoRow('Date of Birth', profile.dateOfBirth.toString().split(' ')[0]),
                      _buildInfoRow('Gender', profile.gender),
                      if (profile.height != null) _buildInfoRow('Height', '${profile.height} cm'),
                      if (profile.weight != null) _buildInfoRow('Weight', '${profile.weight} kg'),
                      if (profile.bloodType != null) _buildInfoRow('Blood Type', profile.bloodType!),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (profile.medicalConditions.isNotEmpty)
                    _buildInfoCard(
                      context: context,
                      title: 'Medical Conditions',
                      children: profile.medicalConditions
                          .map((condition) => _buildInfoRow('•', condition))
                          .toList(),
                    ),
                  const SizedBox(height: 16),
                  if (profile.allergies.isNotEmpty)
                    _buildInfoCard(
                      context: context,
                      title: 'Allergies',
                      children: profile.allergies
                          .map((allergy) => _buildInfoRow('•', allergy))
                          .toList(),
                    ),
                  const SizedBox(height: 16),
                  if (profile.currentMedications.isNotEmpty)
                    _buildInfoCard(
                      context: context,
                      title: 'Current Medications',
                      children: profile.currentMedications
                          .map((medication) => _buildInfoRow('•', medication))
                          .toList(),
                    ),
                  const SizedBox(height: 16),
                  if (profile.emergencyContact != null)
                    _buildInfoCard(
                      context: context,
                      title: 'Emergency Contact',
                      children: profile.emergencyContact!.entries
                          .map((e) => _buildInfoRow(e.key, e.value))
                          .toList(),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoCard({
    required BuildContext context,
    required String title,
    required List<Widget> children,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          Text(value),
        ],
      ),
    );
  }
}
