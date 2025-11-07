import 'package:fitman_app/services/api_service.dart';
import 'package:flutter/material.dart';
import '../../models/user_front.dart';
import 'package:file_picker/file_picker.dart';

class ProfileScreen extends StatefulWidget {
  final User user;

  const ProfileScreen({super.key, required this.user});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late String? _photoUrl;

  @override
  void initState() {
    super.initState();
    _photoUrl = widget.user.photoUrl;
  }

  Future<void> _pickAndUploadAvatar() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.image);

    if (result != null) {
      final fileBytes = result.files.single.bytes;
      final fileName = result.files.single.name;

      if (fileBytes != null) {
        try {
          final response = await ApiService.uploadAvatar(fileBytes, fileName, widget.user.id);
          if (!mounted) return;

          setState(() {
            _photoUrl = response['photoUrl'];
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Аватар успешно обновлен')),
          );
        } catch (e) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Ошибка загрузки аватара: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: <Widget>[
        Center(
          child: Column(
            children: [
              CircleAvatar(
                radius: 50,
                backgroundImage: _photoUrl != null 
                    ? NetworkImage(Uri.parse(ApiService.baseUrl).replace(path: _photoUrl).toString())
                    : null,
                child: _photoUrl == null
                    ? const Icon(Icons.person, size: 50)
                    : null,
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: _pickAndUploadAvatar,
                child: const Text('Загрузить фото'),
              ),
            ],
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
            _buildInfoRow(label: 'ID', value: widget.user.id.toString()),
            _buildInfoRow(label: 'Полное имя', value: widget.user.fullName),
            _buildInfoRow(label: 'Email', value: widget.user.email),
            _buildInfoRow(label: 'Телефон', value: widget.user.phone ?? 'не указан'),
            _buildInfoRow(label: 'Пол', value: widget.user.gender ?? 'не указан'),
            _buildInfoRow(label: 'Дата рождения', value: widget.user.dateOfBirth != null ? '${widget.user.dateOfBirth!.day}.${widget.user.dateOfBirth!.month}.${widget.user.dateOfBirth!.year}' : 'не указана'),
            _buildInfoRow(label: 'Возраст', value: widget.user.age?.toString() ?? 'не указан'),
            const Divider(height: 30),
            // Требование 9.1.4, пункты 2 и 3
            if (widget.user.roles.length > 1 &&
                widget.user.roles.every((r) => r.name != 'client'))
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
        ...widget.user.roles.map((role) => SelectableText('  - ${role.title}')),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildSettingsSection() {
    // Требование 9.5
    final isClient = widget.user.roles.any((r) => r.name == 'client');

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
          value: widget.user.sendNotification,
          onChanged: null, // TODO: Implement settings change
        ),
        _buildInfoRow(
          label: 'Уведомлять за (часы)',
          value: widget.user.hourNotification.toString(),
        ),
        if (isClient)
          SwitchListTile(
            title: const SelectableText('Отслеживать калории'),
            value: widget.user.trackCalories,
            onChanged: null, // TODO: Implement settings change
          ),
        if (isClient)
          _buildInfoRow(
            label: 'Коэф. активности',
            value: widget.user.coeffActivity.toString(),
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
