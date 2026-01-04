import 'dart:convert';
import 'package:fitman_app/modules/infrastructure/models/room/room.model.dart';
import 'package:http/http.dart' as http;

class RoomService {
  final String _baseUrl = 'http://localhost:8080/api/rooms'; // Placeholder

  Future<List<Room>> getAllRooms() async {
    final response = await http.get(Uri.parse(_baseUrl));

    if (response.statusCode == 200) {
      final List<dynamic> roomJson = json.decode(response.body);
      return roomJson.map((json) => Room.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load rooms');
    }
  }

  Future<Room> getRoomById(String id) async {
    final response = await http.get(Uri.parse('$_baseUrl/$id'));

    if (response.statusCode == 200) {
      return Room.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load room');
    }
  }

  // Other methods for create, update, delete will be added here
}
