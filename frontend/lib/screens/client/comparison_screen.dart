import 'package:before_after/before_after.dart';
import 'package:flutter/material.dart';

class ComparisonScreen extends StatelessWidget {
  final String beforeImageUrl;
  final String afterImageUrl;

  const ComparisonScreen({
    super.key,
    required this.beforeImageUrl,
    required this.afterImageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Сравнение фотографий'),
      ),
      body: BeforeAfter(
        before: Image.network(beforeImageUrl),
        after: Image.network(afterImageUrl),
      ),
    );
  }
}
