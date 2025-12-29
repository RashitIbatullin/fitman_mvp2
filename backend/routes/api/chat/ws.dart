import 'dart:async';
import 'dart:convert';
import 'package:dart_frog/dart_frog.dart';
import 'package:dart_frog_web_socket/dart_frog_web_socket.dart';
import 'package:postgres/postgres.dart';
import '../../../lib/controllers/auth_controller.dart';
import '../../../lib/config/database.dart';
import '../../../lib/services/redis_service.dart';

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
    final dbConnection = await db.connection;
    final redis = RedisService();
    final sub = await redis.subscriber;
    StreamSubscription? redisSubscription;

    try {
      // 1. Получить все чаты пользователя и подписаться на них в Redis
      final chatIdsResult = await dbConnection.execute(
        Sql.named('SELECT chat_id FROM chat_participants WHERE user_id = @userId'),
        parameters: {'userId': userId},
      );
      final chatIds = chatIdsResult.map((row) => row.first as int).toList();

      if (chatIds.isNotEmpty) {
        final channels = chatIds.map((id) => 'chat:$id').toList();
        print('👂 User $userId listening to channels: $channels');
        sub.subscribe(channels);
        
        redisSubscription = sub.stream.listen((msg) {
          if (msg.kind == 'message') {
            print('↳ Redis message received for user $userId on channel ${msg.channel}: ${msg.payload}');
            // Пересылаем сообщение клиенту
            channel.sink.add(msg.payload);
          }
        });
      }

      // 2. Слушать сообщения от клиента
      channel.stream.listen(
        (message) async {
          try {
            print('↳ WebSocket message received from user $userId: $message');
            final data = jsonDecode(message as String);
            final chatId = data['chat_id'] as int?;
            final content = data['content'] as String?;

            if (chatId == null || content == null || content.trim().isEmpty) {
              channel.sink.add(jsonEncode({'error': 'Invalid message format. Required: {"chat_id": 123, "content": "..."}'}));
              return;
            }

            // Проверяем, состоит ли пользователь в этом чате
            if (!chatIds.contains(chatId)) {
               channel.sink.add(jsonEncode({'error': 'You are not a member of chat $chatId.'}));
               return;
            }

            // 3. Сохранить сообщение в БД
            final result = await dbConnection.execute(
              Sql.named('''
                INSERT INTO messages (chat_id, sender_id, content)
                VALUES (@chatId, @senderId, @content)
                RETURNING id, created_at
              '''),
              parameters: {'chatId': chatId, 'senderId': userId, 'content': content},
            );

            final newMsgId = result.first.toColumnMap()['id'];
            final newMsgCreatedAt = result.first.toColumnMap()['created_at'] as DateTime;
            
            // 4. Опубликовать сообщение в Redis
            final outgoingMessage = {
              'id': newMsgId,
              'chat_id': chatId,
              'sender_id': userId,
              'content': content,
              'created_at': newMsgCreatedAt.toIso8601String(),
              'first_name': userFirstName,
              'last_name': userLastName,
            };
            
            await redis.publish('chat:$chatId', jsonEncode(outgoingMessage));
            print('↳ Message from user $userId published to redis channel chat:$chatId');

          } catch (e) {
            print('Error processing client message: $e');
            channel.sink.add(jsonEncode({'error': 'Failed to process message.'}));
          }
        },
        onDone: () async {
          print('🔌 WebSocket disconnected for user: $userId');
          await redisSubscription?.cancel();
          await dbConnection.close();
        },
        onError: (error) async {
          print(' WebSocket error for user $userId: $error');
          await redisSubscription?.cancel();
          await dbConnection.close();
        },
      );

    } catch (e) {
      print('Error during WebSocket setup: $e');
      channel.sink.close(5000, 'Internal Server Error');
      await redisSubscription?.cancel();
      await dbConnection.close();
    }
  });

  return handler(context);
}
