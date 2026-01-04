import 'package:fitman_app/screens/admin/groups/analytic_groups_screen.dart';
import 'package:fitman_app/screens/admin/groups/training_groups_screen.dart';
import 'package:flutter/material.dart';

class GroupsDashboardScreen extends StatelessWidget {
  const GroupsDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Группы'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Тренировочные'),
              Tab(text: 'Аналитические'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            TrainingGroupsScreen(),
            AnalyticGroupsScreen(),
          ],
        ),
      ),
    );
  }
}




