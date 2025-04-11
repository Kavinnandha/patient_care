import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'providers/auth_provider.dart';
import 'login_page.dart';

class RegistrationPage extends StatefulWidget {
  const RegistrationPage({super.key});

  @override
  State<RegistrationPage> createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  DateTime? _dateOfBirth;
  String _gender = 'male';
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  String? _bloodType;
  final _medicalConditionsController = TextEditingController();
  final _allergiesController = TextEditingController();
  final _medicationsController = TextEditingController();
  final _emergencyNameController = TextEditingController();
  final _emergencyRelationController = TextEditingController();
  final _emergencyPhoneController = TextEditingController();
  String? _errorMessage;

  final List<String> _bloodTypes = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'];
  
  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _medicalConditionsController.dispose();
    _allergiesController.dispose();
    _medicationsController.dispose();
    _emergencyNameController.dispose();
    _emergencyRelationController.dispose();
    _emergencyPhoneController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365 * 18)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _dateOfBirth = picked;
      });
    }
  }

  List<String> _parseCommaSeparatedString(String value) {
    return value.split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
  }

  Future<void> _handleRegistration() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_dateOfBirth == null) {
      setState(() {
        _errorMessage = 'Please select your date of birth';
      });
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      setState(() {
        _errorMessage = 'Passwords do not match';
      });
      return;
    }

    try {
      setState(() {
        _errorMessage = null;
      });

      Map<String, String>? emergencyContact;
      if (_emergencyNameController.text.isNotEmpty ||
          _emergencyRelationController.text.isNotEmpty ||
          _emergencyPhoneController.text.isNotEmpty) {
        emergencyContact = {
          'name': _emergencyNameController.text,
          'relationship': _emergencyRelationController.text,
          'phone': _emergencyPhoneController.text,
        };
      }

      final success = await context.read<AuthProvider>().register(
        username: _usernameController.text,
        email: _emailController.text,
        password: _passwordController.text,
        firstName: _firstNameController.text,
        lastName: _lastNameController.text,
        dateOfBirth: _dateOfBirth!,
        gender: _gender,
        height: _heightController.text.isNotEmpty 
            ? double.parse(_heightController.text) 
            : null,
        weight: _weightController.text.isNotEmpty 
            ? double.parse(_weightController.text) 
            : null,
        bloodType: _bloodType,
        medicalConditions: _medicalConditionsController.text.isNotEmpty 
            ? _parseCommaSeparatedString(_medicalConditionsController.text)
            : null,
        allergies: _allergiesController.text.isNotEmpty 
            ? _parseCommaSeparatedString(_allergiesController.text)
            : null,
        currentMedications: _medicationsController.text.isNotEmpty 
            ? _parseCommaSeparatedString(_medicationsController.text)
            : null,
        emergencyContact: emergencyContact,
      );

      if (success && mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    }
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    bool obscureText = false,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 8.0),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        validator: validator ?? (value) {
          if (value == null || value.isEmpty) {
            return 'This field is required';
          }
          return null;
        },
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          filled: true,
          fillColor: Colors.grey[200],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.white),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.deepPurple),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<AuthProvider>().isLoading;

    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.app_registration, size: 100),
                  const SizedBox(height: 30),
                  Text(
                    'Create Account',
                    style: GoogleFonts.bebasNeue(fontSize: 50),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Please fill in your details',
                    style: TextStyle(fontSize: 20),
                  ),
                  const SizedBox(height: 25),

                  // Account Information
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 25.0),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Account Information',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  _buildTextField(
                    controller: _usernameController,
                    label: 'Username',
                    hint: 'Enter your username',
                  ),
                  _buildTextField(
                    controller: _emailController,
                    label: 'Email',
                    hint: 'Enter your email',
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Email is required';
                      }
                      if (!value.contains('@')) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                  ),
                  _buildTextField(
                    controller: _passwordController,
                    label: 'Password',
                    hint: 'Enter your password',
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Password is required';
                      }
                      if (value.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                  ),
                  _buildTextField(
                    controller: _confirmPasswordController,
                    label: 'Confirm Password',
                    hint: 'Confirm your password',
                    obscureText: true,
                  ),

                  const SizedBox(height: 20),

                  // Personal Information
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 25.0),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Personal Information',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  _buildTextField(
                    controller: _firstNameController,
                    label: 'First Name',
                    hint: 'Enter your first name',
                  ),
                  _buildTextField(
                    controller: _lastNameController,
                    label: 'Last Name',
                    hint: 'Enter your last name',
                  ),

                  // Date of Birth
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 8.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white),
                      ),
                      child: ListTile(
                        title: Text(
                          _dateOfBirth == null
                              ? 'Select Date of Birth'
                              : 'Birth Date: ${DateFormat('MMM d, yyyy').format(_dateOfBirth!)}',
                        ),
                        trailing: const Icon(Icons.calendar_today),
                        onTap: () => _selectDate(context),
                      ),
                    ),
                  ),

                  // Gender Selection
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 8.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12.0),
                        child: DropdownButtonFormField<String>(
                          value: _gender,
                          decoration: const InputDecoration(
                            labelText: 'Gender',
                            border: InputBorder.none,
                          ),
                          items: ['male', 'female', 'other'].map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value[0].toUpperCase() + value.substring(1)),
                            );
                          }).toList(),
                          onChanged: (newValue) {
                            setState(() {
                              _gender = newValue!;
                            });
                          },
                        ),
                      ),
                    ),
                  ),

                  // Health Information
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 25.0),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Health Information',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  _buildTextField(
                    controller: _heightController,
                    label: 'Height (cm)',
                    hint: 'Enter your height in centimeters',
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value != null && value.isNotEmpty) {
                        final height = double.tryParse(value);
                        if (height == null || height <= 0) {
                          return 'Please enter a valid height';
                        }
                      }
                      return null;
                    },
                  ),
                  _buildTextField(
                    controller: _weightController,
                    label: 'Weight (kg)',
                    hint: 'Enter your weight in kilograms',
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value != null && value.isNotEmpty) {
                        final weight = double.tryParse(value);
                        if (weight == null || weight <= 0) {
                          return 'Please enter a valid weight';
                        }
                      }
                      return null;
                    },
                  ),

                  // Blood Type Selection
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 8.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12.0),
                        child: DropdownButtonFormField<String>(
                          value: _bloodType,
                          decoration: const InputDecoration(
                            labelText: 'Blood Type',
                            border: InputBorder.none,
                          ),
                          items: [
                            const DropdownMenuItem<String>(
                              value: null,
                              child: Text('Select Blood Type'),
                            ),
                            ..._bloodTypes.map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                          ],
                          onChanged: (newValue) {
                            setState(() {
                              _bloodType = newValue;
                            });
                          },
                        ),
                      ),
                    ),
                  ),

                  _buildTextField(
                    controller: _medicalConditionsController,
                    label: 'Medical Conditions',
                    hint: 'Enter conditions separated by commas',
                    validator: null,
                  ),
                  _buildTextField(
                    controller: _allergiesController,
                    label: 'Allergies',
                    hint: 'Enter allergies separated by commas',
                    validator: null,
                  ),
                  _buildTextField(
                    controller: _medicationsController,
                    label: 'Current Medications',
                    hint: 'Enter medications separated by commas',
                    validator: null,
                  ),

                  // Emergency Contact
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 25.0),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Emergency Contact',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  _buildTextField(
                    controller: _emergencyNameController,
                    label: 'Emergency Contact Name',
                    hint: 'Enter emergency contact name',
                    validator: null,
                  ),
                  _buildTextField(
                    controller: _emergencyRelationController,
                    label: 'Relationship',
                    hint: 'Enter relationship to emergency contact',
                    validator: null,
                  ),
                  _buildTextField(
                    controller: _emergencyPhoneController,
                    label: 'Emergency Contact Phone',
                    hint: 'Enter emergency contact phone number',
                    keyboardType: TextInputType.phone,
                    validator: null,
                  ),

                  const SizedBox(height: 10),
                  if (_errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 25.0),
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(color: Colors.red, fontSize: 14),
                      ),
                    ),

                  const SizedBox(height: 20),
                  
                  // Register Button
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25.0),
                    child: GestureDetector(
                      onTap: isLoading ? null : _handleRegistration,
                      child: Container(
                        padding: const EdgeInsets.all(17),
                        decoration: BoxDecoration(
                          color: isLoading ? Colors.grey : Colors.deepPurple,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                              : const Text(
                                  'Register',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Already have an account? ',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(builder: (context) => const LoginPage()),
                          );
                        },
                        child: const Text(
                          'Login here',
                          style: TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
