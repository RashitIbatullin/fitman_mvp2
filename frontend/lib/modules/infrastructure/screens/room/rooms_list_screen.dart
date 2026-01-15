import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/room/room.model.dart';
import '../../models/room/room_type.enum.dart'; // Import RoomType enum
import 'room_detail_screen.dart';
import 'room_create_screen.dart';
import 'room_edit_screen.dart';
import '../../utils/room_utils.dart';
import 'package:fitman_app/widgets/filter_popup_menu.dart';
import 'package:fitman_app/services/api_service.dart';
import '../../providers/room_provider.dart'; // Import from the new location

class RoomsListViewScreen extends ConsumerStatefulWidget {
  const RoomsListViewScreen({super.key});

  @override
  ConsumerState<RoomsListViewScreen> createState() => _RoomsListViewScreenState();
}

class _RoomsListViewScreenState extends ConsumerState<RoomsListViewScreen> {
  Room? _selectedRoom;
  final TextEditingController _searchQueryController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchQueryController.addListener(() {
      setState(() {}); // Rebuild to apply search filter
    });
  }

  @override
  void dispose() {
    _searchQueryController.dispose();
    super.dispose();
  }

  // Helper method to filter rooms on the client side based on search query
  List<Room> _filterRooms(List<Room> allRooms) {
    if (_searchQueryController.text.isEmpty) {
      return allRooms;
    }
    return allRooms.where((room) {
      return room.name.toLowerCase().contains(_searchQueryController.text.toLowerCase()) ||
             (room.roomNumber?.toLowerCase().contains(_searchQueryController.text.toLowerCase()) ?? false);
    }).toList();
  }

  Future<void> _archiveRoom() async {
    final selectedRoom = _selectedRoom;
    if (selectedRoom == null) return; // _selectedRoom?.id was already checked in FilterOption
    try {
      await ApiService.updateRoom(selectedRoom.id, selectedRoom.copyWith(archivedAt: DateTime.now()));
      ref.invalidate(allRoomsProvider);
      if (mounted) {
        setState(() => _selectedRoom = null);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Помещение архивировано')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка архивации: $e')),
        );
      }
    }
  }

  Future<void> _unarchiveRoom() async {
    final selectedRoom = _selectedRoom;
    if (selectedRoom == null) return; // _selectedRoom?.id was already checked in FilterOption
    try {
      await ApiService.updateRoom(selectedRoom.id, selectedRoom.copyWith(archivedAt: null));
      ref.invalidate(allRoomsProvider);
      if (mounted) {
        setState(() => _selectedRoom = null);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Помещение восстановлено из архива')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка восстановления: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final roomsAsync = ref.watch(allRoomsProvider);
    final roomTypeFilter = ref.watch(roomTypeFilterProvider);
    final isUnderMaintenanceFilter = ref.watch(roomIsUnderMaintenanceFilterProvider);


    return Scaffold(
      appBar: AppBar(
        title: const Text('Помещения'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight + 56.0), // Extra height for search and filters
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: _searchQueryController,
                  decoration: InputDecoration(
                    labelText: 'Поиск по названию или номеру',
                    prefixIcon: const Icon(Icons.search),
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () => _searchQueryController.clear(),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    FilterPopupMenuButton<String>(
                      tooltip: 'Действия',
                      allOptionText: 'Действия',
                      showAllOption: false,
                      initialValue: null,
                      avatar: const Icon(Icons.more_vert),
                      onSelected: (value) async {
                        switch (value) {
                          case 'add':
                            await Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const RoomCreateScreen()),
                            );
                            ref.read(allRoomsProvider.notifier).refresh();
                            break;
                          case 'edit':
                            final selectedRoom = _selectedRoom;
                            if (selectedRoom != null && selectedRoom.archivedAt == null) {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => RoomEditScreen(room: selectedRoom),
                                ),
                              );
                              ref.read(allRoomsProvider.notifier).refresh();
                            }
                            break;
                          case 'archive':
                            final selectedRoom = _selectedRoom;
                            if (selectedRoom != null && selectedRoom.archivedAt == null) {
                              _archiveRoom();
                            }
                            break;
                          case 'unarchive':
                            final selectedRoom = _selectedRoom;
                            if (selectedRoom != null && selectedRoom.archivedAt != null) {
                              _unarchiveRoom();
                            }
                            break;
                        }
                      },
                      options: [
                        const FilterOption(label: 'Добавить', value: 'add'),
                        FilterOption(
                            label: 'Изменить',
                            value: 'edit',
                            enabled: _selectedRoom != null && _selectedRoom!.archivedAt == null),
                        FilterOption(
                            label: 'Архивировать',
                            value: 'archive',
                            enabled: _selectedRoom != null && _selectedRoom!.archivedAt == null),
                        FilterOption(
                            label: 'Деархивировать',
                            value: 'unarchive',
                            enabled: _selectedRoom != null && _selectedRoom!.archivedAt != null),
                      ],
                    ),
                    const SizedBox(width: 8),
                    FilterPopupMenuButton<RoomType?>(
                      tooltip: 'Тип помещения',
                      allOptionText: 'Тип: Все',
                      initialValue: roomTypeFilter,
                      avatar: const Icon(Icons.category_outlined),
                      onSelected: (value) {
                        ref.read(roomTypeFilterProvider.notifier).state = value;
                      },
                      options: RoomType.values.map((type) => FilterOption(label: type.displayName, value: type)).toList(),
                      showAllOption: true,
                    ),
                    const SizedBox(width: 8),
                    FilterPopupMenuButton<bool?>(
                      tooltip: 'Статус',
                      allOptionText: 'Статус: Все',
                      initialValue: isUnderMaintenanceFilter,
                      avatar: const Icon(Icons.build_outlined),
                      onSelected: (value) {
                        ref.read(roomIsUnderMaintenanceFilterProvider.notifier).state = value;
                      },
                      options: const [
                        FilterOption(label: 'На ремонте', value: true),
                        FilterOption(label: 'Активные', value: false),
                      ],
                      showAllOption: true,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      body: roomsAsync.when(
        data: (allRooms) {
          final filteredRooms = _filterRooms(allRooms); // Apply local search filter

          if (filteredRooms.isEmpty) {
            return const Center(child: Text('Помещения не найдены.'));
          }

          return ListView.builder(
            itemCount: filteredRooms.length,
            itemBuilder: (context, index) {
              final room = filteredRooms[index];
              final isSelected = _selectedRoom?.id == room.id;

              return Card(
                color: room.archivedAt != null ? Colors.grey[200] : null,
                margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                child: ListTile(
                  selected: isSelected,
                  selectedTileColor: Theme.of(context).primaryColorLight,
                  leading: SizedBox(
                    width: 50,
                    height: 50,
                    child: room.photoUrls.isNotEmpty
                        ? Image.network(
                            room.photoUrls.first,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image),
                          )
                        : const Icon(Icons.meeting_room),
                  ),
                  title: Text(room.name),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (room.roomNumber?.isNotEmpty == true) Text('Номер: ${room.roomNumber}'), // Display room number
                      Text('Тип: ${room.type.displayName}'),
                      Text('Вместимость: ${room.maxCapacity} чел.'),
                      Text('Площадь: ${room.area == null ? 'N/A' : room.area.toString()} м²'), // ignore: unnecessary_null_comparison
                      Row(
                        children: [
                          Text('Статус: '),
                          room.isUnderMaintenance
                              ? const Chip(
                                  label: Text('На ремонте'),
                                  backgroundColor: Colors.orangeAccent,
                                )
                              : const Chip(
                                  label: Text('Активно'),
                                  backgroundColor: Colors.greenAccent,
                                ),
                          if (room.archivedAt != null)
                            const Padding(
                              padding: EdgeInsets.only(left: 8.0),
                              child: Chip(
                                label: Text('В архиве'),
                                backgroundColor: Colors.blueGrey,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RoomDetailScreen(roomId: room.id),
                      ),
                    );
                  },
                  onLongPress: () {
                    setState(() {
                      _selectedRoom = isSelected ? null : room;
                    });
                  },
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Ошибка: $err')),
      ),
    );
  }
}
