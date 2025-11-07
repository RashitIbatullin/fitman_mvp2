import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/gestures.dart';
import 'package:fitman_app/widgets/image_comparison_slider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:fitman_app/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitman_app/providers/auth_provider.dart';

class DashedCrosshairPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey
      ..strokeWidth = 1;

    const dashWidth = 5;
    const dashSpace = 5;

    // Horizontal line
    double startX = 0;
    while (startX < size.width) {
      canvas.drawLine(
        Offset(startX, size.height / 2),
        Offset(startX + dashWidth, size.height / 2),
        paint,
      );
      startX += dashWidth + dashSpace;
    }

    // Vertical line
    double startY = 0;
    while (startY < size.height) {
      canvas.drawLine(
        Offset(size.width / 2, startY),
        Offset(size.width / 2, startY + dashWidth),
        paint,
      );
      startY += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class PhotoComparisonScreen extends ConsumerStatefulWidget {
  final int? clientId;
  final String? initialStartPhotoUrl;
  final String? initialFinishPhotoUrl;
  final DateTime? initialStartPhotoDateTime;
  final DateTime? initialFinishPhotoDateTime;

  const PhotoComparisonScreen({
    super.key,
    this.clientId,
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

  final GlobalKey _startPhotoKey = GlobalKey();
  final GlobalKey _finishPhotoKey = GlobalKey();

  final TransformationController _startController = TransformationController();
  final TransformationController _finishController = TransformationController();

  @override
  void initState() {
    super.initState();
    _startPhotoUrl = widget.initialStartPhotoUrl;
    _finishPhotoUrl = widget.initialFinishPhotoUrl;
    _startPhotoDateTime = widget.initialStartPhotoDateTime;
    _finishPhotoDateTime = widget.initialFinishPhotoDateTime;
  }

  Future<void> _savePhoto(GlobalKey key, String type) async {
    try {
      RenderRepaintBoundary boundary = key.currentContext!.findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      Uint8List pngBytes = byteData!.buffer.asUint8List();

      final String fileName = 'photo_${DateTime.now().millisecondsSinceEpoch}.png';

      final responseData = await ApiService.uploadAnthropometryPhoto(
        pngBytes,
        fileName,
        type,
        clientId: widget.clientId,
        photoDateTime: DateTime.now(),
      );

      final newUrl = responseData['url'];
      final newDateTime = responseData['photo_date_time'] != null
          ? DateTime.parse(responseData['photo_date_time'])
          : DateTime.now();

      setState(() {
        if (type == 'start') {
          _startPhotoUrl = newUrl;
          _startPhotoDateTime = newDateTime;
          _startController.value = Matrix4.identity();
        } else {
          _finishPhotoUrl = newUrl;
          _finishPhotoDateTime = newDateTime;
          _finishController.value = Matrix4.identity();
        }
      });
    } catch (e) {
      // Handle error
      print('[_savePhoto] Image save failed: $e');
    }
  }

    Future<void> _pickAndUploadImage(String type) async {
      print('[_pickAndUploadImage] Starting photo pick for type: $type');
      FilePickerResult? result =
          await FilePicker.platform.pickFiles(type: FileType.image);
          //print('[_pickAndUploadImage] FilePicker result: $result');
          if (result != null) {
          print('[_pickAndUploadImage] Number of files picked: ${result.files.length}');
          final fileBytes = result.files.single.bytes;
                final fileName = result.files.single.name;
          
                if (fileBytes != null) {
                  try {
                    print('[_pickAndUploadImage] Calling ApiService.uploadAnthropometryPhoto...');
                    final responseData = await ApiService.uploadAnthropometryPhoto(
                      fileBytes,
                      fileName,
                      type,
                      clientId: widget.clientId,
                      photoDateTime: null, // Path is not available on web, so we can't get lastModified
                    );            print('[_pickAndUploadImage] ApiService response: $responseData');
  
            final newUrl = responseData['url'];
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
          } catch (e) {
            // Handle error
            print('[_pickAndUploadImage] Image upload failed: $e');
          }
        }
      }
    }

  Widget _buildPhotoSection(
      String? photoUrl,
      DateTime? photoDateTime,
      String title,
      String type,
      bool canUploadPhoto,
      GlobalKey key,
      TransformationController controller) {
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
          height: 300,
          width: double.infinity,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              RepaintBoundary(
                key: key,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: photoUrl != null
                      ? InteractiveViewer(
                          transformationController: controller,
                          boundaryMargin: EdgeInsets.all(double.infinity),
                          minScale: 1,
                          maxScale: 4,
                          child: Image.network(
                            Uri.parse(ApiService.baseUrl).replace(path: photoUrl).toString() + '?v=${DateTime.now().millisecondsSinceEpoch}',
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) =>
                                const Center(child: Icon(Icons.error, size: 50)),
                          ),
                        )
                      : const Center(child: Text('Фото не загружено')),
                ),
              ),
              IgnorePointer(
                child: CustomPaint(
                  size: Size.infinite,
                  painter: DashedCrosshairPainter(),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(formattedDate),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (canUploadPhoto)
              ElevatedButton(
                onPressed: () => _pickAndUploadImage(type),
                child: const Text('Загрузить фото'),
              ),
            const SizedBox(width: 8),
            if (canUploadPhoto)
              ElevatedButton(
                onPressed: photoUrl != null ? () => _savePhoto(key, type) : null,
                child: const Text('Сохранить'),
              ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final user = authState.value?.user;

    final canUploadPhoto = user != null && (!user.roles.any((role) => role.name == 'client') || user.roles.length > 1);

    return PopScope(
      canPop: false, // Prevent default back button behavior
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return; // If the system already popped, do nothing
        Navigator.pop(context, {
          'startPhotoUrl': _startPhotoUrl,
          'finishPhotoUrl': _finishPhotoUrl,
          'startPhotoDateTime': _startPhotoDateTime,
          'finishPhotoDateTime': _finishPhotoDateTime,
        });
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
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) {
                        return Scaffold(
                          appBar: AppBar(title: const Text('Сравнение')),
                          body: ImageComparisonSlider(
                            before: Image.network(
                              Uri.parse(ApiService.baseUrl).replace(path: _startPhotoUrl!).toString(),
                              fit: BoxFit.contain,
                            ),
                            after: Image.network(
                              Uri.parse(ApiService.baseUrl).replace(path: _finishPhotoUrl!).toString(),
                              fit: BoxFit.contain,
                            ),
                          ),
                        );
                      }));
                    },
                    child: const Text('Сравнить'),
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
                        _startPhotoUrl, _startPhotoDateTime, 'Начало', 'start', canUploadPhoto, _startPhotoKey, _startController),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildPhotoSection(_finishPhotoUrl,
                        _finishPhotoDateTime, 'Окончание', 'finish', canUploadPhoto, _finishPhotoKey, _finishController),
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

