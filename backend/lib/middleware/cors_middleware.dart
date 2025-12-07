import 'package:fitman_backend/config/app_config.dart';
import 'package:shelf/shelf.dart';

Middleware corsMiddleware() {
  return (Handler innerHandler) {
    return (Request request) async {
      final origin = request.headers['Origin'];
      // Log the origin for debugging purposes
      print('ℹ️  Request Origin: $origin');
      
      final corsHeaders = _getcorsHeaders(origin);

      if (request.method == 'OPTIONS') {
        return Response.ok('', headers: corsHeaders);
      }

      final response = await innerHandler(request);
      return response.change(headers: corsHeaders);
    };
  };
}

Map<String, String> _getcorsHeaders(String? origin) {
  final headers = {
    'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
    'Access-Control-Allow-Headers': 'Origin, Content-Type, Authorization, Accept',
    'Access-Control-Allow-Credentials': 'true',
    // Set a default value for the origin
    'Access-Control-Allow-Origin': '', 
  };

  if (origin != null) {
    // Check for localhost with any port for development
    if (origin.startsWith('http://localhost:') || origin.startsWith('http://127.0.0.1:')) {
      headers['Access-Control-Allow-Origin'] = origin;
    } 
    // Check if the origin is in the allowed list for production/mobile
    else if (AppConfig.instance.allowedOrigins.contains(origin)) {
      headers['Access-Control-Allow-Origin'] = origin;
    }
  }

  // If origin is null or not allowed, 'Access-Control-Allow-Origin' will be an empty string,
  // effectively denying the request from a browser.
  return headers;
}