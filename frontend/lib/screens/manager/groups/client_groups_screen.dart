import 'package:flutter/material.dart';

class ClientGroupsScreen extends StatelessWidget {
  const ClientGroupsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Client Groups (Manager)'),
      ),
      body: const Center(
        child: Text('Client Groups Screen'),
      ),
    );
  }
}
