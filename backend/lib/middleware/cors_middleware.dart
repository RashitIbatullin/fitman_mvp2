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
    'Access-Control-Allow-Origin': '*', // Allow all origins for development
    'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
    'Access-Control-Allow-Headers': 'Origin, Content-Type, Authorization, Accept',
    'Access-Control-Allow-Credentials': 'true',
  };
  return headers;
}