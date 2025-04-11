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
import 'providers/blood_glucose_provider.dart';
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
        ChangeNotifierProxyProvider2<ApiService, SyncService, BloodGlucoseProvider>(
          create: (context) => BloodGlucoseProvider(
            context.read<ApiService>(),
            context.read<SyncService>(),
          ),
          update: (context, apiService, syncService, previous) => 
            previous ?? BloodGlucoseProvider(apiService, syncService),
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
      home: const AuthWrapper(),
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

        if (authProvider.isAuthenticated) {
          return const Dashboard();
        }

        return const LoginPage();
      },
    );
  }
}
