import 'package:dart_frog/dart_frog.dart';
import 'package:fitman_backend/config/database.dart';
import 'package:fitman_backend/controllers/auth_controller.dart';
import 'package:fitman_backend/controllers/chat/chat_controller.dart';
import 'package:fitman_backend/services/redis_service.dart';

Future<Response> onRequest(RequestContext context) async {
  if (context.request.method == HttpMethod.post) {
    return _createChat(context);
  }
  return Response(statusCode: 405); // Method Not Allowed
}

Future<Response> _createChat(RequestContext context) async {
  final token = context.request.headers['Authorization']?.replaceFirst('Bearer ', '');
  if (token == null) {
    return Response(statusCode: 401, body: 'Authentication token is missing.');
  }

  final payload = AuthController.verifyToken(token);
  if (payload == null) {
    return Response(statusCode: 401, body: 'Invalid or expired token.');
  }
  
  final creatorId = payload['userId'] as int?;
  if (creatorId == null) {
    return Response(statusCode: 401, body: 'User ID not found in token.');
  }
  
  try {
    final body = await context.request.json();
    final userIds = (body['userIds'] as List).cast<int>();
    final name = body['name'] as String?;

    final db = Database();
    final redis = RedisService();
    final chatController = ChatController(db, redis);

    final result = await chatController.createChat(userIds, name, creatorId);

    final statusCode = result['existed'] == true ? 200 : 201;

    return Response.json(
      statusCode: statusCode,
      body: {
        'message': result['existed'] == true ? 'Chat already existed.' : 'Chat created successfully.',
        'chat_id': result['id'],
      },
    );
  } catch (e) {
    return Response(statusCode: 500, body: 'Failed to create chat: ${e.toString()}');
  }
}
