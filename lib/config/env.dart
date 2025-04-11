enum Environment {
  dev,
  prod
}

class EnvConfig {
  static const Environment _environment = Environment.dev;

  static String get apiBaseUrl {
    switch (_environment) {
      case Environment.dev:
        return 'http://localhost:3000/api';  // Works for Windows and web
      case Environment.prod:
        return 'http://localhost:3000/api';  // Replace with production URL
    }
  }

  static bool get isDevelopment => _environment == Environment.dev;

  static Map<String, String> get headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    // Add CORS headers for web
    if (isDevelopment) 'Access-Control-Allow-Origin': '*',
  };
}
