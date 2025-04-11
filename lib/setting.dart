import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _darkMode = false;
  bool _notificationsEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Settings", style: GoogleFonts.poppins(fontSize: 20)),
        backgroundColor: Colors.blueAccent,
      ),
      body: ListView(
        children: [
          _buildSwitchTile(
            title: "Dark Mode",
            value: _darkMode,
            onChanged: (bool value) {
              setState(() {
                _darkMode = value;
              });
            },
          ),
          _buildSwitchTile(
            title: "Enable Notifications",
            value: _notificationsEnabled,
            onChanged: (bool value) {
              setState(() {
                _notificationsEnabled = value;
              });
            },
          ),
          _buildListTile(
            title: "Account Settings",
            icon: Icons.person,
            onTap: () {},
          ),
          _buildListTile(
            title: "Privacy Policy",
            icon: Icons.lock,
            onTap: () {},
          ),
          _buildListTile(
            title: "About App",
            icon: Icons.info,
            onTap: () {},
          ),
          _buildListTile(
            title: "Logout",
            icon: Icons.exit_to_app,
            onTap: () {},
            color: Colors.red,
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return SwitchListTile(
      title: Text(title, style: GoogleFonts.roboto(fontSize: 18)),
      value: value,
      onChanged: onChanged,
    );
  }

  Widget _buildListTile({
    required String title,
    required IconData icon,
    required Function() onTap,
    Color color = Colors.black,
  }) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(title, style: GoogleFonts.roboto(fontSize: 18, color: color)),
      trailing: Icon(Icons.arrow_forward_ios, size: 18, color: color),
      onTap: onTap,
    );
  }
}
