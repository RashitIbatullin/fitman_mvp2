import 'package:dart_frog/dart_frog.dart';
import 'package:fitman_backend/config/database.dart';
import 'package:fitman_backend/controllers/auth_controller.dart';
import 'package:fitman_backend/controllers/chat/chat_controller.dart';
import 'package:fitman_backend/services/redis_service.dart';

Future<Response> onRequest(RequestContext context, String chatIdStr) async {
  if (context.request.method == HttpMethod.get) {
    return _getMessages(context, chatIdStr);
  }
  return Response(statusCode: 405);
}

Future<Response> _getMessages(RequestContext context, String chatIdStr) async {
  final token = context.request.headers['Authorization']?.replaceFirst('Bearer ', '');
  if (token == null) {
    return Response(statusCode: 401, body: 'Authentication token is missing.');
  }

  final payload = AuthController.verifyToken(token);
  if (payload == null) {
    return Response(statusCode: 401, body: 'Invalid or expired token.');
  }
  
  final userId = payload['userId'] as int?;
  if (userId == null) {
    return Response(statusCode: 401, body: 'User ID not found in token.');
  }

  final chatId = int.tryParse(chatIdStr);
  if (chatId == null) {
    return Response(statusCode: 400, body: 'Invalid chat ID.');
  }

  try {
    final params = context.request.uri.queryParameters;
    final limit = int.tryParse(params['limit'] ?? '50') ?? 50;
    final offset = int.tryParse(params['offset'] ?? '0') ?? 0;

    final db = Database();
    final redis = RedisService();
    final chatController = ChatController(db, redis);

    final messages = await chatController.getMessages(chatId, userId, limit: limit, offset: offset);

    return Response.json(body: messages);

  } catch (e) {
    return Response(statusCode: 500, body: 'Failed to get messages: ${e.toString()}');
  }
}
