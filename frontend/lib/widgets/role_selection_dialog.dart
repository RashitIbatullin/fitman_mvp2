import 'package:flutter/material.dart';
import '../models/role.dart';

class RoleSelectionDialog extends StatelessWidget {
  final List<Role> roles;

  const RoleSelectionDialog({super.key, required this.roles});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Выберите роль'),
      content: SingleChildScrollView(
        child: ListBody(
          children: roles.map((role) {
            return ListTile(
              title: Text(role.title),
              leading: role.icon != null
                  ? Icon(
                      IconData(
                        int.parse(role.icon!),
                        fontFamily: 'MaterialIcons',
                      ),
                    )
                  : const Icon(Icons.person),
              onTap: () {
                Navigator.of(context).pop(role);
              },
            );
          }).toList(),
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: const Text('Отмена'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
