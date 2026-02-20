/// API configuration for the Studio Pair application.
class ApiConfig {
  ApiConfig._();

  /// Base URL for the API server.
  static const String baseUrl = 'https://api.studiopair.app/v1';

  /// Base URL for local development.
  static const String localBaseUrl = 'http://localhost:8080/v1';

  /// WebSocket URL for real-time communication.
  static const String wsUrl = 'wss://api.studiopair.app/ws';

  /// WebSocket URL for local development.
  static const String localWsUrl = 'ws://localhost:8080/ws';

  /// Request timeout in milliseconds.
  static const int connectTimeout = 15000;

  /// Receive timeout in milliseconds.
  static const int receiveTimeout = 30000;

  /// Send timeout in milliseconds.
  static const int sendTimeout = 15000;

  /// Maximum number of retries for failed requests.
  static const int maxRetries = 3;

  /// Delay between retries in milliseconds.
  static const int retryDelay = 1000;

  /// Whether to use local development server.
  static bool get isLocal => const bool.fromEnvironment('USE_LOCAL_API');

  /// Get the appropriate base URL.
  static String get effectiveBaseUrl => isLocal ? localBaseUrl : baseUrl;

  /// Get the appropriate WebSocket URL.
  static String get effectiveWsUrl => isLocal ? localWsUrl : wsUrl;

  /// Common headers for API requests.
  static Map<String, String> get defaultHeaders => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'X-Client-Platform': 'flutter',
    'X-Client-Version': '0.1.0',
  };

  /// Create authorization header with Bearer token.
  static Map<String, String> authHeader(String token) => {
    'Authorization': 'Bearer $token',
  };
}
