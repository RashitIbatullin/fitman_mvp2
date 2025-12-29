import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import 'package:uuid/uuid.dart';
import 'package:fitman_backend/controllers/auth_controller.dart';

Future<Response> onRequest(RequestContext context) async {
  if (context.request.method == HttpMethod.post) {
    return _uploadAttachment(context);
  }
  return Response(statusCode: 405); // Method Not Allowed
}

Future<Response> _uploadAttachment(RequestContext context) async {
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

  try {
    final formData = await context.request.formData();
    final filePart = formData.files['file'];

    if (filePart == null) {
      return Response(statusCode: 400, body: 'File part named "file" is missing.');
    }
    
    final uuid = Uuid();
    final fileName = '${uuid.v4()}_${filePart.name}';
    final filePath = 'uploads/chat_attachments/$fileName';
    final file = File(filePath);
    await file.writeAsBytes(await filePart.readAsBytes());
    
    final attachmentUrl = '/uploads/chat_attachments/$fileName'; // Relative URL
    String attachmentType = filePart.contentType.mimeType;
    
    // Basic type mapping
    if (attachmentType.startsWith('image/')) {
      attachmentType = 'image';
    } else if (attachmentType.startsWith('video/')) {
      attachmentType = 'video';
    } else if (attachmentType.startsWith('audio/')) {
      attachmentType = 'audio';
    } else if (attachmentType == 'application/pdf') {
      attachmentType = 'pdf';
    } else {
      attachmentType = 'file';
    }

    return Response.json(
      statusCode: 201,
      body: {
        'message': 'File uploaded successfully.',
        'attachment_url': attachmentUrl,
        'attachment_type': attachmentType,
      },
    );
  } catch (e) {
    return Response(statusCode: 500, body: 'Failed to upload file: ${e.toString()}');
  }
}
