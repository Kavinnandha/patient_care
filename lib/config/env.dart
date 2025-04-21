class EnvConfig {
  static String get apiBaseUrl => 'http://localhost:3000/api';

  static Map<String, String> get headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'Access-Control-Allow-Origin': '*',
  };
}
