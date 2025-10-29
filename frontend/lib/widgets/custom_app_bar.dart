import 'package:fitman_app/screens/shared/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import '../utils/dialog_utils.dart';

class AppBarAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  const AppBarAction({
    super.key,
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          padding: const EdgeInsets.all(8.0),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
          foregroundColor: Theme.of(context).colorScheme.onSurface,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 28.0),
            const SizedBox(height: 2.0),
            Text(label, style: const TextStyle(fontSize: 10.0)),
          ],
        ),
      ),
    );
  }
}

class CustomAppBar extends ConsumerWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool automaticallyImplyLeading;
  final bool showLogout;
  final bool showBackButton;
  final bool showProfileButton;

  const CustomAppBar({
    super.key,
    required this.title,
    this.actions,
    this.leading,
    this.automaticallyImplyLeading = true,
    this.showLogout = true,
    this.showBackButton = false,
    this.showProfileButton = true, // Added for profile button
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 20);

  factory CustomAppBar.client({
    String title = 'Фитнес-трекер',
    List<Widget>? additionalActions,
    bool showBackButton = true,
  }) {
    final defaultActions = [
      AppBarAction(icon: Icons.calendar_today, label: 'Расписание', onPressed: () {}),
      AppBarAction(icon: Icons.assessment, label: 'Прогресс', onPressed: () {}),
    ];

    return CustomAppBar(
      title: title,
      actions: [
        ...?additionalActions,
        ...defaultActions,
      ],
      showBackButton: showBackButton,
    );
  }

  factory CustomAppBar.trainer({
    String title = 'Панель тренера',
    List<Widget>? additionalActions,
  }) {
    final defaultActions = [
      AppBarAction(icon: Icons.group, label: 'Клиенты', onPressed: () {}),
      AppBarAction(icon: Icons.schedule, label: 'Расписание', onPressed: () {}),
    ];

    return CustomAppBar(
      title: title,
      actions: [
        ...?additionalActions,
        ...defaultActions,
      ],
    );
  }

  factory CustomAppBar.admin({
    String title = 'Администрирование',
    required Function(int) onTabSelected,
  }) {
    final defaultActions = [
      AppBarAction(icon: Icons.people, label: 'Пользователи', onPressed: () => onTabSelected(0)),
      AppBarAction(icon: Icons.settings, label: 'Настройки', onPressed: () => onTabSelected(1)),
      AppBarAction(icon: Icons.analytics, label: 'Аналитика', onPressed: () => onTabSelected(2)),
      AppBarAction(icon: Icons.folder_open, label: 'Каталоги', onPressed: () => onTabSelected(3)),
    ];

    return CustomAppBar(
      title: title,
      actions: defaultActions,
    );
  }

  factory CustomAppBar.manager({
    String title = 'Панель менеджера',
    List<Widget>? additionalActions,
    required Function(int) onTabSelected,
  }) {
    final defaultActions = [
      AppBarAction(icon: Icons.people, label: 'Клиенты', onPressed: () => onTabSelected(0)),
      AppBarAction(icon: Icons.sports, label: 'Инструкторы', onPressed: () => onTabSelected(1)),
      AppBarAction(icon: Icons.fitness_center, label: 'Тренеры', onPressed: () => onTabSelected(2)),
      AppBarAction(icon: Icons.calendar_today, label: 'Расписание', onPressed: () => onTabSelected(3)),
      AppBarAction(icon: Icons.access_time, label: 'Табели', onPressed: () => onTabSelected(4)),
      AppBarAction(icon: Icons.folder_open, label: 'Каталоги', onPressed: () => onTabSelected(5)),
    ];

    return CustomAppBar(
      title: title,
      actions: [
        ...?additionalActions,
        ...defaultActions,
      ],
    );
  }

  factory CustomAppBar.instructor({
    String title = 'Панель инструктора',
    List<Widget>? additionalActions,
    required Function(int) onTabSelected,
  }) {
    final defaultActions = [
      AppBarAction(icon: Icons.people, label: 'Клиенты', onPressed: () => onTabSelected(0)),
      AppBarAction(icon: Icons.person, label: 'Тренер', onPressed: () => onTabSelected(1)),
      AppBarAction(icon: Icons.manage_accounts, label: 'Менеджер', onPressed: () => onTabSelected(2)),
      AppBarAction(icon: Icons.calendar_today, label: 'Расписание', onPressed: () => onTabSelected(3)),
      AppBarAction(icon: Icons.access_time, label: 'Табель', onPressed: () => onTabSelected(4)),
    ];

    return CustomAppBar(
      title: title,
      actions: [
        ...?additionalActions,
        ...defaultActions,
      ],
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppBar(
      title: Text(title),
      leading: showBackButton
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const BackButton(),
                if (Scaffold.of(context).hasDrawer)
                  Builder(
                    builder: (BuildContext context) {
                      return IconButton(
                        icon: const Icon(Icons.menu),
                        onPressed: () {
                          Scaffold.of(context).openDrawer();
                        },
                        tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
                      );
                    },
                  ),
              ],
            )
          : leading,
      automaticallyImplyLeading: !showBackButton,
      leadingWidth: showBackButton && (Scaffold.of(context).hasDrawer) ? 100.0 : null,
      actions: [
        ...?actions,
        if (showProfileButton) _buildProfileButton(context, ref),
        if (showLogout) _buildLogoutAction(context, ref),
      ],
      toolbarHeight: preferredSize.height,
    );
  }

  Widget _buildProfileButton(BuildContext context, WidgetRef ref) {
    return IconButton(
      icon: const Icon(Icons.account_circle, size: 30.0),
      tooltip: 'Профиль',
      onPressed: () {
        final user = ref.read(authProvider).value?.user;
        if (user != null) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ProfileScreen(user: user)),
          );
        }
      },
    );
  }

  Widget _buildLogoutAction(BuildContext context, WidgetRef ref) {
    return IconButton(
      icon: const Icon(Icons.logout, size: 30.0),
      tooltip: 'Выйти из системы',
      onPressed: () {
        DialogUtils.showLogoutDialog(context, ref);
      },
    );
  }
}