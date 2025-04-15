
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'registration_page.dart';
import 'api_service.dart';

class LoginPage extends StatefulWidget {
    const LoginPage({super.key});

    @override
    State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _errorMessage;

  Future<void> _handleLogin() async {
    // Hide keyboard to prevent IME issues
    FocusScope.of(context).unfocus();
    
    if (_usernameController.text.isEmpty || _passwordController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter both username and password';
      });
      return;
    }

    try {
      setState(() {
        _errorMessage = null;
      });

      // Trim input to prevent whitespace issues
      final username = _usernameController.text.trim();
      final password = _passwordController.text;

      final response = await context.read<AuthProvider>().login(
        username,
        password,
      );

      if (!mounted) return;

      if (!response.success) {
        setState(() {
          _errorMessage = response.error ?? response.message;
        });
      } else {
        // Clear password field after successful login
        _passwordController.clear();
        
        // Let AuthWrapper handle navigation automatically
        // No explicit navigation needed as AuthWrapper will detect auth state change
      }
    } on ApiException catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.message;
        });
      }
    } on UnauthorizedException catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.message;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'An unexpected error occurred. Please try again.';
          print('Login error: $e'); // Add debug logging
        });
      }
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

    @override
    Widget build(BuildContext context){
        return Scaffold(
            resizeToAvoidBottomInset: false,
            backgroundColor: Colors.grey[300],
            body: SafeArea(
                child: Center(
                child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                        const Icon(Icons.badge,size:100),
                        const SizedBox(height: 50),
                        Text(
                        'Welcome Back',
                        style: GoogleFonts.bebasNeue(
                            fontSize: 50,
                            ),
                        ), //text
                        const SizedBox(height: 10),
                        const Text(
                            'please enter your email and password',
                            style: TextStyle(
                                fontSize: 20,
                            ),
                        ), // text

                        const SizedBox(height: 25),
                        Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 25.0),
                            child: Container(
                            decoration: BoxDecoration(
                                color: Colors.grey[200],
                                border: Border.all(color: Colors.white),
                                borderRadius: BorderRadius.circular(12),
                            ), // Boxdecoration
                        child: Padding(
                            padding: const EdgeInsets.only(left: 20.0),
                            child: TextField(
                            controller: _usernameController,
                            decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Username',
                            ),
                        ), // textfield
                        ), // Padding
                        ), // Container
                    ), //Padding
                        const SizedBox(height: 20),
                        Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 25.0),
                            child: Container(
                            decoration: BoxDecoration(
                                color: Colors.grey[200],
                                border: Border.all(color: Colors.white),
                                borderRadius: BorderRadius.circular(12),
                            ), // Boxdecoration
                        child: Padding(
                            padding: const EdgeInsets.only(left: 20.0),
                            child: TextField(
                            controller: _passwordController,
                            obscureText: true,
                            decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Password',
                            ),
                        ), // Textfield
                        ), // Padding
                        ), // Container
                    ), //Padding
                    const SizedBox(height: 10),
                    Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 25.0),
                        child: Column(
                          children: [
                            if (_errorMessage != null)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 10.0),
                                child: Text(
                                  _errorMessage!,
                                  style: const TextStyle(
                                    color: Colors.red,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            Consumer<AuthProvider>(
                              builder: (context, auth, _) => GestureDetector(
                                onTap: auth.isLoading ? null : () async {
                                  await _handleLogin();
                                  if (mounted) {
                                    _passwordController.clear();
                                  }
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(17),
                                  decoration: BoxDecoration(
                                    color: auth.isLoading ? Colors.grey : Colors.deepPurple,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Center(
                                    child: auth.isLoading
                                        ? const SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                            ),
                                          )
                                        : const Text(
                                            'Sign In',
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
                                  'Don\'t have an account? ',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => const RegistrationPage(),
                                      ),
                                    );
                                  },
                                  child: const Text(
                                    'Register here',
                                    style: TextStyle(
                                      color: Colors.blue,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        ), // Padding
                    ],
                ), // column
                ), // center
            ), // SafeArea
            ); // scaffold
    }
}
