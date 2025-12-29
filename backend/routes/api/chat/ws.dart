import 'dart:async';
import 'dart:convert';
import 'package:dart_frog/dart_frog.dart';
import 'package:dart_frog_web_socket/dart_frog_web_socket.dart';
import 'package:fitman_backend/controllers/auth_controller.dart';
import 'package:fitman_backend/config/database.dart';
import 'package:fitman_backend/services/redis_service.dart';
import 'package:fitman_backend/controllers/chat/chat_controller.dart';

Future<Response> onRequest(RequestContext context) async {
  final token = context.request.uri.queryParameters['token'];
  if (token == null) {
    return Response(statusCode: 401, body: 'Authentication token is missing.');
  }

  final payload = AuthController.verifyToken(token);
  if (payload == null) {
    return Response(statusCode: 401, body: 'Invalid or expired token.');
  }
  
  final userId = payload['userId'] as int?;
  final userEmail = payload['email'] as String?;
  final userFirstName = payload['firstName'] as String?;
  final userLastName = payload['lastName'] as String?;

  if (userId == null) {
    return Response(statusCode: 401, body: 'User ID not found in token.');
  }

  final handler = webSocketHandler((channel, protocol) async {
    print('✅ WebSocket connected for user: $userId ($userEmail)');
    
    final db = Database();
    final redis = RedisService();
    final chatController = ChatController(db, redis);
    
    StreamSubscription? redisSubscription;

    try {
      final chatIds = await chatController.getChatIdsForUser(userId);

      if (chatIds.isNotEmpty) {
        final channels = chatIds.map((id) => 'chat:$id').toList();
        print('👂 User $userId listening to channels: $channels');
        final sub = await redis.subscriber;
        sub.subscribe(channels);
        
        redisSubscription = sub.getStream().listen((msg) {
          if (msg.kind == 'message') {
            print('↳ Redis message received for user $userId on channel ${msg.channel}: ${msg.payload}');
            channel.sink.add(msg.payload);
          }
        });
      }

      channel.stream.listen(
        (message) async {
          try {
            print('↳ WebSocket message received from user $userId: $message');
            await chatController.handleWebSocketMessage(
              message: message as String,
              userId: userId,
              userChatIds: chatIds,
              userFirstName: userFirstName,
              userLastName: userLastName,
            );
          } catch (e) {
            print('Error processing client message: $e');
            channel.sink.add(jsonEncode({'error': 'Failed to process message: ${e.toString()}'}));
          }
        },
        onDone: () async {
          print('🔌 WebSocket disconnected for user: $userId');
          await redisSubscription?.cancel();
          await db.disconnect();
          redis.dispose();
        },
        onError: (error) async {
          print(' WebSocket error for user $userId: $error');
          await redisSubscription?.cancel();
          await db.disconnect();
          redis.dispose();
        },
      );

    } catch (e) {
      print('Error during WebSocket setup: $e');
      channel.sink.close(5000, 'Internal Server Error');
      await redisSubscription?.cancel();
      await db.disconnect();
      redis.dispose();
    }
  });

  return handler(context);
}

