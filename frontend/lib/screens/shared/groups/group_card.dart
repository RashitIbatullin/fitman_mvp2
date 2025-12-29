import 'package:flutter/material.dart';

class GroupCard extends StatelessWidget {
  const GroupCard({super.key});

  @override
  Widget build(BuildContext context) {
    return const Card(
      child: ListTile(
        title: Text('Group Name'),
        subtitle: Text('Group Description'),
      ),
    );
  }
}
