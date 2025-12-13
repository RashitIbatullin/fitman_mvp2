import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:fitman_app/widgets/dashed_crosshair_painter.dart';
import 'package:flutter/rendering.dart';

class FullScreenPhotoEditor extends StatefulWidget {
  final String imageUrl;
  final Matrix4 initialTransform;

  const FullScreenPhotoEditor({
    super.key,
    required this.imageUrl,
    required this.initialTransform,
  });

  @override
  State<FullScreenPhotoEditor> createState() => _FullScreenPhotoEditorState();
}

class _FullScreenPhotoEditorState extends State<FullScreenPhotoEditor> {
  late final TransformationController _transformationController;
  final GlobalKey _repaintBoundaryKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _transformationController =
        TransformationController(widget.initialTransform);
  }

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }

  Future<void> _captureAndPop() async {
    try {
      RenderRepaintBoundary boundary = _repaintBoundaryKey.currentContext!
          .findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      
      // Create a record to return both the image and the transform
      final result = (image, _transformationController.value);

      if (mounted) {
        Navigator.pop(context, result);
      }
    } catch (e) {
      print('Error capturing image: $e');
      if (mounted) {
        Navigator.pop(context); // Pop without a value on error
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Редактировать фото',
            style: TextStyle(color: Colors.white)),
        actions: [
          TextButton(
            onPressed: _captureAndPop,
            child: const Text('ОК', style: TextStyle(color: Colors.white, fontSize: 16)),
          ),
        ],
      ),
      body: RepaintBoundary(
        key: _repaintBoundaryKey,
        child: Stack(
          children: [
            InteractiveViewer(
              transformationController: _transformationController,
              minScale: 0.5,
              maxScale: 5.0,
              constrained: true,
              child: Center(
                child: Image.network(
                  widget.imageUrl,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            // The static crosshair overlay
            IgnorePointer(
              child: CustomPaint(
                size: Size.infinite,
                painter: DashedCrosshairPainter(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
