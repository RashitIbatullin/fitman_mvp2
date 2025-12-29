import 'package:flutter/material.dart';

class GroupEditScreen extends StatelessWidget {
  const GroupEditScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Group'),
      ),
      body: const Center(
        child: Text('Group Edit Screen'),
      ),
    );
  }
}
