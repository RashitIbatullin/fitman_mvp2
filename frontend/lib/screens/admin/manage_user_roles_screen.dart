import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/user_front.dart';
import '../../models/role.dart';
import '../../services/api_service.dart';
import '../../widgets/custom_app_bar.dart';

class ManageUserRolesScreen extends ConsumerStatefulWidget {
  final User user;

  const ManageUserRolesScreen({super.key, required this.user});

  @override
  ConsumerState<ManageUserRolesScreen> createState() => _ManageUserRolesScreenState();
}

class _ManageUserRolesScreenState extends ConsumerState<ManageUserRolesScreen> {
  List<Role> _allRoles = [];
  List<String> _selectedRoleNames = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _selectedRoleNames = widget.user.roles.map((r) => r.name).toList();
    _loadRoles();
  }

  Future<void> _loadRoles() async {
    try {
      final roles = await ApiService.getAllRoles();
      setState(() {
        _allRoles = roles.where((role) => role.name != 'client').toList(); // Filter out 'client' role
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  bool _isRoleRemovable(String roleName) {
    // A client user can only have one role, so no roles are removable if they are a client
    if (widget.user.roles.any((r) => r.name == 'client')) {
      return false;
    }
    // Cannot remove the initial role if it's the only one left
    if (widget.user.roles.length == 1 && widget.user.roles.first.name == roleName) {
      return false;
    }
    return true;
  }

  Future<void> _updateRoles() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      print('Attempting to update roles for user ID: ${widget.user.id}');
      print('Selected roles to send: $_selectedRoleNames');
      await ApiService.updateUserRoles(widget.user.id, _selectedRoleNames);
      print('Roles updated successfully!');
      if (mounted) {
        Navigator.pop(context); // Go back to the user list
      }
    } catch (e) {
      print('Error updating roles: $e');
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Управление ролями для ${widget.user.fullName}',
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text('Ошибка: $_error'))
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Текущие роли: ${widget.user.roles.map((r) => r.title).join(', ')}',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      const Text('Доступные роли:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      Expanded(
                        child: ListView.builder(
                          itemCount: _allRoles.length,
                          itemBuilder: (context, index) {
                            final role = _allRoles[index];
                            final isSelected = _selectedRoleNames.contains(role.name);
                            final isClientUser = widget.user.roles.any((r) => r.name == 'client');
                            final isOnlyRole = widget.user.roles.length == 1 && widget.user.roles.first.name == role.name;

                            // Disable checkbox if it's a client role, or if it's a client user, or if it's the only role and trying to deselect
                            final bool isDisabled = role.name == 'client' || isClientUser || (isOnlyRole && isSelected && _selectedRoleNames.length == 1);

                            return CheckboxListTile(
                              title: Text(role.title),
                              value: isSelected,
                              onChanged: isDisabled
                                  ? null
                                  : (bool? newValue) {
                                      setState(() {
                                        if (newValue == true) {
                                          _selectedRoleNames.add(role.name);
                                        } else {
                                          _selectedRoleNames.remove(role.name);
                                        }
                                      });
                                    },
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                      Center(
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _updateRoles,
                          child: const Text('Сохранить изменения'),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}