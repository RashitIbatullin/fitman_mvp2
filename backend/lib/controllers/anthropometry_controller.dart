import 'dart:convert';
import 'dart:io';
import 'package:shelf/shelf.dart';
import 'package:shelf_multipart/shelf_multipart.dart';
import '../config/database.dart';

class AnthropometryController {
  static Future<Response> getAnthropometryDataForClient(Request request) async {
    try {
      final user = request.context['user'] as Map<String, dynamic>?;
      if (user == null) {
        return Response.unauthorized(jsonEncode({'error': 'Not authenticated'}));
      }

      final clientId = user['userId'] as int;
      final data = await Database().getAnthropometryData(clientId);

      return Response.ok(jsonEncode(data));
    } catch (e) {
      print('Get anthropometry data error: $e');
      return Response.internalServerError(body: jsonEncode({'error': 'Internal server error'}));
    }
  }

  static Future<Response> uploadPhoto(Request request) async {
    try {
      final user = request.context['user'] as Map<String, dynamic>?;
      if (user == null) {
        return Response.unauthorized(jsonEncode({'error': 'Not authenticated'}));
      }

      final clientId = user['userId'] as int;
      String? type;
      String? fileName;
      List<int>? fileBytes;

      if (request.formData() case final form?) {
        await for (final formData in form.formData) {
          print('formData.name: ${formData.name}');
          print('formData.filename: ${formData.filename}');
          if (formData.name == 'type') {
            type = await formData.part.readString();
          } else if (formData.name == 'photo') {
            fileName = formData.filename;
            fileBytes = await formData.part.readBytes();
          }
        }
      } else {
        return Response.badRequest(body: jsonEncode({'error': 'Not a multipart/form-data request'}));
      }

      if (type == null || fileName == null || fileBytes == null) {
        return Response.badRequest(body: jsonEncode({'error': 'Missing required fields'}));
      }

      final uploadDir = Directory('../uploads');
      if (!await uploadDir.exists()) {
        await uploadDir.create(recursive: true);
      }

      final filePath = '${uploadDir.path}/$fileName';
      final file = File(filePath);
      await file.writeAsBytes(fileBytes);

      final photoUrl = '/uploads/$fileName';

      final now = DateTime.now();
      await Database().updateAnthropometryPhoto(clientId, photoUrl, type, now);

      return Response.ok(jsonEncode({
        'url': photoUrl,
        'photo_date_time': now.toIso8601String(),
      }));
    } catch (e, s) {
      print('Upload photo error: $e');
      print(s);
      return Response.internalServerError(body: jsonEncode({'error': 'Internal server error'}));
    }
  }

  static Future<Response> updateFixedAnthropometry(Request request) async {
    try {
      final user = request.context['user'] as Map<String, dynamic>?;
      if (user == null) {
        return Response.unauthorized(jsonEncode({'error': 'Not authenticated'}));
      }
      final clientId = user['userId'] as int;

      final body = await request.readAsString();
      final data = jsonDecode(body) as Map<String, dynamic>;

      final height = data['height'] as int?;
      final wristCirc = data['wristCirc'] as int?;
      final ankleCirc = data['ankleCirc'] as int?;

      await Database().updateAnthropometryFixed(clientId, height, wristCirc, ankleCirc);

      return Response.ok(jsonEncode({'message': 'Fixed anthropometry updated successfully'}));
    } catch (e, s) {
      print('Update fixed anthropometry error: $e');
      print(s);
      return Response.internalServerError(body: jsonEncode({'error': 'Internal server error'}));
    }
  }

  static Future<Response> updateMeasurementsAnthropometry(Request request) async {
    try {
      final user = request.context['user'] as Map<String, dynamic>?;
      if (user == null) {
        return Response.unauthorized(jsonEncode({'error': 'Not authenticated'}));
      }
      final clientId = user['userId'] as int;

      final body = await request.readAsString();
      final data = jsonDecode(body) as Map<String, dynamic>;

      final type = data['type'] as String; // 'start' or 'finish'
      final weight = (data['weight'] as num?)?.toDouble();
      final shouldersCirc = data['shouldersCirc'] as int?;
      final breastCirc = data['breastCirc'] as int?;
      final waistCirc = data['waistCirc'] as int?;
      final hipsCirc = data['hipsCirc'] as int?;
      final bmr = data['bmr'] as int?;

      if (type != 'start' && type != 'finish') {
        return Response.badRequest(body: jsonEncode({'error': 'Invalid anthropometry type. Must be \'start\' or \'finish\''}));
      }

      await Database().updateAnthropometryMeasurements(
        clientId,
        type,
        weight,
        shouldersCirc,
        breastCirc,
        waistCirc,
        hipsCirc,
        bmr,
      );

      return Response.ok(jsonEncode({'message': 'Measurements anthropometry updated successfully'}));
    } catch (e, s) {
      print('Update measurements anthropometry error: $e');
      print(s);
      return Response.internalServerError(body: jsonEncode({'error': e.toString()}));
    }
  }
}