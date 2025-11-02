import 'dart:convert';
import 'package:before_after/before_after.dart';
import 'package:file_picker/file_picker.dart';
import 'package:fitman_app/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class PhotoComparisonScreen extends ConsumerStatefulWidget {
  final String? initialStartPhotoUrl;
  final String? initialFinishPhotoUrl;
  final DateTime? initialStartPhotoDateTime;
  final DateTime? initialFinishPhotoDateTime;

  const PhotoComparisonScreen({
    super.key,
    this.initialStartPhotoUrl,
    this.initialFinishPhotoUrl,
    this.initialStartPhotoDateTime,
    this.initialFinishPhotoDateTime,
  });

  @override
  ConsumerState<PhotoComparisonScreen> createState() =>
      _PhotoComparisonScreenState();
}

class _PhotoComparisonScreenState extends ConsumerState<PhotoComparisonScreen> {
  late String? _startPhotoUrl;
  late String? _finishPhotoUrl;
  late DateTime? _startPhotoDateTime;
  late DateTime? _finishPhotoDateTime;

  @override
  void initState() {
    super.initState();
    _startPhotoUrl = widget.initialStartPhotoUrl;
    _finishPhotoUrl = widget.initialFinishPhotoUrl;
    _startPhotoDateTime = widget.initialStartPhotoDateTime;
    _finishPhotoDateTime = widget.initialFinishPhotoDateTime;
  }
  Future<void> _pickAndUploadImage(String type) async {
    FilePickerResult? result =
        await FilePicker.platform.pickFiles(type: FileType.image);

    if (result != null) {
      final fileBytes = result.files.single.bytes;
      final fileName = result.files.single.name;
      if (fileBytes != null) {
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('auth_token');

        final uri =
            Uri.parse('${ApiService.baseUrl}/api/client/anthropometry/photo');
        final request = http.MultipartRequest('POST', uri);
        request.headers['Authorization'] = 'Bearer $token';
        request.fields['type'] = type;
        request.files.add(http.MultipartFile.fromBytes(
          'photo',
          fileBytes,
          filename: fileName,
        ));
        final response = await request.send();

        if (response.statusCode == 200) {
          final responseBody = await response.stream.bytesToString();
          final responseData = jsonDecode(responseBody);
          final newUrl = responseData['url'];
          // Assuming backend might send photo_date_time, otherwise use now()
          final newDateTime = responseData['photo_date_time'] != null
              ? DateTime.parse(responseData['photo_date_time'])
              : DateTime.now();

          setState(() {
            if (type == 'start') {
              _startPhotoUrl = newUrl;
              _startPhotoDateTime = newDateTime;
            } else {
              _finishPhotoUrl = newUrl;
              _finishPhotoDateTime = newDateTime;
            }
          });
        } else {
          // Handle error
          final responseBody = await response.stream.bytesToString();
          print('Image upload failed with status: ${response.statusCode}');
          print('Response body: $responseBody');
        }
      }
    }
  }

  Widget _buildPhotoSection(
      String? photoUrl, DateTime? photoDateTime, String title, String type) {
    // Simple date formatting, for better formatting, use the intl package
    final formattedDate = photoDateTime != null
        ? '${photoDateTime.day.toString().padLeft(2, '0')}.${photoDateTime.month.toString().padLeft(2, '0')}.${photoDateTime.year} ${photoDateTime.hour.toString().padLeft(2, '0')}:${photoDateTime.minute.toString().padLeft(2, '0')}'
        : 'Нет даты';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        Container(
          height: 300, // Larger photo
          width: double.infinity,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(8),
          ),
          child: photoUrl != null
              ? Image.network(
                  Uri.parse(ApiService.baseUrl).replace(path: photoUrl).toString(),
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) =>
                      const Center(child: Icon(Icons.error, size: 50)),
                )
              : const Center(child: Text('Фото не загружено')),
        ),
        const SizedBox(height: 8),
        Text(formattedDate),
        const SizedBox(height: 8),
        ElevatedButton(
          onPressed: () => _pickAndUploadImage(type),
          child: const Text('Загрузить фото'),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, {
          'startPhotoUrl': _startPhotoUrl,
          'finishPhotoUrl': _finishPhotoUrl,
          'startPhotoDateTime': _startPhotoDateTime,
          'finishPhotoDateTime': _finishPhotoDateTime,
        });
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Сравнение по фото'),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              if (_startPhotoUrl != null && _finishPhotoUrl != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Column(
                    children: [
                      Text("Сравнение", style: Theme.of(context).textTheme.headlineSmall),
                      const SizedBox(height: 10),
                      const Text(
                        'Перетащите ползунок, чтобы сравнить фотографии:',
                        style: TextStyle(fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        height: 400, // Make comparison view larger
                        child: BeforeAfter(
                          before: Image.network(
                            Uri.parse(ApiService.baseUrl).replace(path: _startPhotoUrl!).toString(),
                            fit: BoxFit.contain,
                          ),
                          after: Image.network(
                            Uri.parse(ApiService.baseUrl).replace(path: _finishPhotoUrl!).toString(),
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              else
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20.0),
                  child: Text(
                    'Загрузите обе фотографии ("Начало" и "Окончание"), чтобы увидеть сравнение.',
                    textAlign: TextAlign.center,
                  ),
                ),
              const Divider(height: 32),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _buildPhotoSection(
                        _startPhotoUrl, _startPhotoDateTime, 'Начало', 'start'),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildPhotoSection(_finishPhotoUrl,
                        _finishPhotoDateTime, 'Окончание', 'finish'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
