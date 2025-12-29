import 'package:flutter/material.dart';

class AutoGroupEditForm extends StatefulWidget {
  const AutoGroupEditForm({super.key});

  @override
  State<AutoGroupEditForm> createState() => _AutoGroupEditFormState();
}

class _AutoGroupEditFormState extends State<AutoGroupEditForm> {
  final List<String> _conditions = [];
  final TextEditingController _newConditionController = TextEditingController();

  void _addCondition() {
    if (_newConditionController.text.isNotEmpty) {
      setState(() {
        _conditions.add(_newConditionController.text.trim());
        _newConditionController.clear();
      });
    }
  }

  void _removeCondition(int index) {
    setState(() {
      _conditions.removeAt(index);
    });
  }

  @override
  void dispose() {
    _newConditionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Условия для автоматической группы',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            ListView.builder(
              shrinkWrap: true,
              itemCount: _conditions.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(_conditions[index]),
                  trailing: IconButton(
                    icon: const Icon(Icons.remove_circle),
                    onPressed: () => _removeCondition(index),
                  ),
                );
              },
            ),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _newConditionController,
                    decoration: const InputDecoration(
                      hintText: 'Добавить условие (напр., "age > 30")',
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: _addCondition,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'TODO: Реализовать парсер и логику применения условий',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
