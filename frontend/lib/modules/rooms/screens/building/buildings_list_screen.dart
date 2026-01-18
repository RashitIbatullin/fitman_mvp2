import 'package:flutter/material.dart';

class BuildingsListScreen extends StatelessWidget {
  const BuildingsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Список зданий'),
      ),
      body: const Center(
        child: Text('Список зданий будет здесь.'),
      ),
    );
  }
}
