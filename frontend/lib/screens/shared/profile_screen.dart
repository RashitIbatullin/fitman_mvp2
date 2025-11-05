import 'package:flutter/material.dart';
import '../../models/user_front.dart';

class ProfileScreen extends StatelessWidget {
  final User user;

  const ProfileScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: <Widget>[
        Center(
          child: CircleAvatar(
            radius: 50,
            // TODO: Implement user.photo_url
            // backgroundImage: user.photoUrl != null ? NetworkImage(user.photoUrl!) : null,
            child: user.photoUrl == null
                ? const Icon(Icons.person, size: 50)
                : null,
          ),
        ),
        const SizedBox(height: 16),
        _buildProfileInfoCard(),
      ],
    );
  }

  Widget _buildProfileInfoCard() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow(label: 'ID', value: user.id.toString()),
            _buildInfoRow(label: 'Полное имя', value: user.fullName),
            _buildInfoRow(label: 'Email', value: user.email),
            _buildInfoRow(label: 'Телефон', value: user.phone ?? 'не указан'),
            _buildInfoRow(label: 'Пол', value: user.gender ?? 'не указан'),
            _buildInfoRow(label: 'Дата рождения', value: user.dateOfBirth != null ? '${user.dateOfBirth!.day}.${user.dateOfBirth!.month}.${user.dateOfBirth!.year}' : 'не указана'),
            _buildInfoRow(label: 'Возраст', value: user.age?.toString() ?? 'не указан'),
            const Divider(height: 30),
            // Требование 9.1.4, пункты 2 и 3
            if (user.roles.length > 1 &&
                user.roles.every((r) => r.name != 'client'))
              _buildRolesSection(),
            const Divider(height: 30),
            _buildSettingsSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildRolesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SelectableText(
          'Роли',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ...user.roles.map((role) => SelectableText('  - ${role.title}')),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildSettingsSection() {
    // Требование 9.5
    final isClient = user.roles.any((r) => r.name == 'client');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SelectableText(
          'Настройки',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        SwitchListTile(
          title: const SelectableText('Получать уведомления'),
          value: user.sendNotification,
          onChanged: null, // TODO: Implement settings change
        ),
        _buildInfoRow(
          label: 'Уведомлять за (часы)',
          value: user.hourNotification.toString(),
        ),
        if (isClient)
          SwitchListTile(
            title: const SelectableText('Отслеживать калории'),
            value: user.trackCalories,
            onChanged: null, // TODO: Implement settings change
          ),
        if (isClient)
          _buildInfoRow(
            label: 'Коэф. активности',
            value: user.coeffActivity.toString(),
          ),
      ],
    );
  }

  Widget _buildInfoRow({required String label, required String value}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SelectableText(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          SelectableText(value),
        ],
      ),
    );
  }
}
