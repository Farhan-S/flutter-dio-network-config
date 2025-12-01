class NetworkConfig {
  // Environment configuration
  static const String environment = String.fromEnvironment('ENV', defaultValue: 'dev');
  
  // Base URLs for different environments
  static const Map<String, String> _baseUrls = {
    'dev': 'https://api-dev.example.com',
    'staging': 'https://api-staging.example.com',
    'prod': 'https://api.example.com',
  };
  
  static String get baseUrl => _baseUrls[environment] ?? _baseUrls['dev']!;
  
  // Timeout configuration
  static const int connectTimeoutSeconds = 30;
  static const int receiveTimeoutSeconds = 30;
  static const int sendTimeoutSeconds = 30;
  
  // Retry configuration
  static const int maxRetries = 3;
  static const int retryDelayMilliseconds = 500;
  
  // Default headers
  static Map<String, String> get defaultHeaders => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
}
