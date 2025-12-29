import 'package:redis/redis.dart';

class RedisService {
  static final RedisService _instance = RedisService._internal();
  factory RedisService() => _instance;

  RedisService._internal();

  final _redis = RedisConnection();
  Command? _pubConnection;
  PubSub? _subConnection;

  Future<Command> get publisher async {
    if (_pubConnection == null) {
      _pubConnection = await _redis.connect('localhost', 6379);
    }
    return _pubConnection!;
  }
  
  Future<PubSub> get subscriber async {
    if (_subConnection == null) {
       final conn = await _redis.connect('localhost', 6379);
      _subConnection = PubSub(conn);
    }
    return _subConnection!;
  }

  Future<void> publish(String channel, String message) async {
    final pub = await publisher;
    await pub.send_object(['PUBLISH', channel, message]);
  }

  void dispose() {
    _redis.close();
  }
}
