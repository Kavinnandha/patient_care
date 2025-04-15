import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'dart:io' show Platform;
import 'api_service.dart';
import 'services/sync_service.dart';
import 'providers/auth_provider.dart';
import 'providers/dashboard_provider.dart';
import 'providers/health_data_provider.dart';
import 'providers/blood_glucose_provider.dart'; // Import the moved provider
import 'utils/database_helper.dart';
import 'dashboard.dart';
import 'login_page.dart';

void main() async {
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize database only for desktop platforms
  if (!kIsWeb) {  // Check if not running on web
    try {
      if (Platform.isWindows || Platform.isLinux) {
        sqfliteFfiInit();
        databaseFactory = databaseFactoryFfi;
      }
      await DatabaseHelper.instance.database;
    } catch (e) {
      print('Error initializing database: $e');
    }
  }

  runApp(
    MultiProvider(
      providers: [
        Provider<ApiService>.value(
          value: ApiService(),
        ),
        ProxyProvider<ApiService, SyncService>(
          update: (_, apiService, __) => SyncService(apiService),
          dispose: (_, service) => service.dispose(),
        ),
        ChangeNotifierProxyProvider<ApiService, AuthProvider>(
          create: (context) => AuthProvider(context.read<ApiService>()),
          update: (context, apiService, previous) => 
            previous ?? AuthProvider(apiService),
        ),
        ChangeNotifierProxyProvider2<ApiService, SyncService, DashboardProvider>(
          create: (context) => DashboardProvider(
            context.read<ApiService>(),
            context.read<SyncService>(),
          ),
          update: (context, apiService, syncService, previous) => 
            previous ?? DashboardProvider(apiService, syncService),
        ),
        ChangeNotifierProxyProvider<SyncService, HealthDataProvider>(
          create: (context) => HealthDataProvider(context.read<SyncService>()),
          update: (context, syncService, previous) => 
            previous ?? HealthDataProvider(syncService),
        ),
        ChangeNotifierProxyProvider3<ApiService, SyncService, AuthProvider, BloodGlucoseProvider>(
          create: (context) => BloodGlucoseProvider(
            context.read<ApiService>(),
            context.read<SyncService>(),
            context.read<AuthProvider>(),
          ),
          update: (context, apiService, syncService, authProvider, previous) => 
            previous ?? BloodGlucoseProvider(apiService, syncService, authProvider),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize error handling for database operations
    ErrorWidget.builder = (FlutterErrorDetails details) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 48),
              const SizedBox(height: 16),
              Text('An error occurred: ${details.exception}'),
            ],
          ),
        ),
      );
    };

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        scaffoldBackgroundColor: Colors.grey[300],
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const AuthWrapper(key: ValueKey('auth_wrapper')),
        '/login': (context) => const LoginPage(),
        '/dashboard': (context) => const Dashboard(),
      },
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        if (authProvider.isLoading) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        return Scaffold(
          body: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (child, animation) => FadeTransition(
              opacity: animation,
              child: child,
            ),
            child: authProvider.isAuthenticated
                ? const Dashboard(key: Key('dashboard'))
                : const LoginPage(key: Key('login')),
          ),
        );
      },
    );
  }
}
