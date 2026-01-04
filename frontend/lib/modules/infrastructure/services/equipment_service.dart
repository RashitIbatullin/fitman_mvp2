import 'dart:convert';
import 'package:fitman_app/modules/infrastructure/models/equipment/equipment_item.model.dart';
import 'package:fitman_app/modules/infrastructure/models/equipment/equipment_type.model.dart';
import 'package:http/http.dart' as http;

class EquipmentService {
  final String _baseUrl = 'http://localhost:8080/api/equipment'; // Placeholder

  Future<List<EquipmentType>> getAllTypes() async {
    final response = await http.get(Uri.parse('$_baseUrl/types'));

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(response.body);
      return jsonList.map((json) => EquipmentType.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load equipment types');
    }
  }

  Future<List<EquipmentItem>> getAllItems() async {
    final response = await http.get(Uri.parse('$_baseUrl/items'));

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(response.body);
      return jsonList.map((json) => EquipmentItem.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load equipment items');
    }
  }

  // Other methods will be added here
}
