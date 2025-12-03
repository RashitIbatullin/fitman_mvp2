class AppConfig {
  // JWT настройки
  static const String jwtSecret = 'fitman-super-secret-key-2024-mvp1';
  static const int jwtExpiryHours = 24;
  
  // Настройки сервера бэкенда
  static const int serverPort = 8080;
  static const String serverHost = '0.0.0.0';
  
  // Настройки безопасности
  static const int bcryptRounds = 12;
  static const int minPasswordLength = 6;
  
  // Допустимые роли пользователей
  static const List<String> allowedRoles = ['client', 'trainer', 'instructor', 'manager', 'admin'];
  
  // Настройки CORS
  static const List<String> allowedOrigins = [
    'http://localhost:3000',
    'http://localhost:8080',
    'http://127.0.0.1:3000',
    'http://127.0.0.1:8080',
    'http://192.168.0.100',
    'http://192.168.0.100:8080',
    'http://192.168.0.100:3000'
  ];
  
  // Валидация email
  static bool isValidEmail(String email) {
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    return emailRegex.hasMatch(email);
  }
  
  // Валидация роли
  static bool isValidRole(String role) {
    return allowedRoles.contains(role);
  }
  
  // Валидация пароля
  static bool isValidPassword(String password) {
    return password.length >= minPasswordLength;
  }
}