import 'package:flutter/material.dart';

class EquipmentItemDetailScreen extends StatelessWidget {
  const EquipmentItemDetailScreen({super.key, required this.itemId});

  final String itemId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Карточка Оборудования'),
      ),
      body: Center(
        child: Text('Детали для оборудования с ID: $itemId'),
      ),
    );
  }
}
