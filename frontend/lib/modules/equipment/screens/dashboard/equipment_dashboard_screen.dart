import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitman_app/modules/equipment/providers/equipment/equipment_provider.dart';
import 'package:fitman_app/modules/rooms/providers/room/room_provider.dart';
import '../../models/equipment/equipment_item.model.dart';
import '../../models/equipment/equipment_status.enum.dart';
import '../../models/equipment/equipment_type.model.dart';
import 'package:fitman_app/modules/rooms/models/room/room.model.dart';
import 'package:fitman_app/modules/rooms/utils/room_utils.dart'; // Add this import
import '../equipment/item/equipment_item_detail_screen.dart';
import '../equipment/item/equipment_item_create_screen.dart';
import '../equipment/item/equipment_item_edit_screen.dart';
import 'package:fitman_app/modules/equipment/screens/equipment/type/equipment_types_list_screen.dart'; // Import for EquipmentTypesListScreen

class EquipmentDashboardScreen extends ConsumerStatefulWidget {
  const EquipmentDashboardScreen({super.key});

  @override
  ConsumerState<EquipmentDashboardScreen> createState() =>
      _EquipmentDashboardScreenState();
}

class _EquipmentDashboardScreenState

    extends ConsumerState<EquipmentDashboardScreen> {

  final _searchController = TextEditingController();

  EquipmentType? _selectedEquipmentType;

  EquipmentStatus? _selectedStatus;

  String? _selectedRoomId;

  int? _selectedConditionRating;



  @override

  void initState() {

    super.initState();

    _searchController.addListener(() {

      setState(() {});

    });

  }



  @override

  void dispose() {

    _searchController.dispose();

    super.dispose();

  }



  String? _getRoomName(List<Room>? rooms, String? roomId) {

    if (rooms == null || roomId == null) return 'Не назначено';

    try {

      return rooms.firstWhere((room) => room.id == roomId).name;

    } catch (e) {

      return 'Неизвестно';

    }

  }



  String? _getEquipmentTypeName(List<EquipmentType>? types, String typeId) {

    if (types == null) return 'N/A';

    try {

      return types.firstWhere((type) => type.id == typeId).name;

    } catch (e) {

      return 'N/A';

    }

  }



  @override

  Widget build(BuildContext context) {

    final equipmentItemsAsync = ref.watch(allEquipmentItemsProvider);

    final equipmentTypesAsync = ref.watch(allEquipmentTypesProvider);

    final roomsAsync = ref.watch(allRoomsProvider);



    return Scaffold(

      appBar: AppBar(

        title: const Text('Управление оборудованием'),

        actions: [

          TextButton(

            onPressed: () {

              Navigator.push(

                context,

                MaterialPageRoute(builder: (context) => const EquipmentTypesListScreen()),

              );

            },

            child: const Text(

              'Типы оборудования',

              style: TextStyle(color: Colors.black),

            ),

          ),

          // Add any other existing actions here if there were any that were overwritten

          // For now, I'll assume there were no other actions besides the title, based on the previous read.

        ],

      ),

      body: Column(

        children: [

          // Search Bar

          Padding(

            padding: const EdgeInsets.all(8.0),

            child: TextField(

              controller: _searchController,

              decoration: InputDecoration(

                labelText: 'Поиск по инв. номеру, модели, производителю',

                prefixIcon: const Icon(Icons.search),

                border: const OutlineInputBorder(),

                suffixIcon: IconButton(

                  icon: const Icon(Icons.clear),

                  onPressed: () => _searchController.clear(),

                ),

              ),

            ),

          ),

          // Filter Rows

          Padding(

            padding: const EdgeInsets.fromLTRB(8.0, 4.0, 8.0, 8.0),

            child: Column(

              children: [

                Row(

                  children: [

                    Expanded(

                      child: equipmentTypesAsync.when(

                                              data: (types) => DropdownButtonFormField<EquipmentType>(

                                                decoration: const InputDecoration(labelText: 'Тип оборудования', border: OutlineInputBorder()),

                                                initialValue: _selectedEquipmentType,

                                                items: [

                                                  const DropdownMenuItem(value: null, child: Text('Все')),

                                                  ...types.map((type) => DropdownMenuItem(

                                                    value: type,

                                                    child: Row(

                                                      children: [

                                                        const SizedBox(width: 8.0),

                                                        Text(type.name),

                                                      ],

                                                    ),

                                                  )),

                                                ],

                                                onChanged: (value) => setState(() => _selectedEquipmentType = value),

                                              ),                        loading: () => const Center(child: CircularProgressIndicator()),

                        error: (err, stack) => Text('Error: ${err.toString()}'),

                      ),

                    ),

                    const SizedBox(width: 8.0),

                    Expanded(

                      child: DropdownButtonFormField<EquipmentStatus>(

                        decoration: const InputDecoration(labelText: 'Статус', border: OutlineInputBorder()),

                        initialValue: _selectedStatus,

                        items: [

                          const DropdownMenuItem(value: null, child: Text('Все')),

                          ...EquipmentStatus.values.map((status) =>

                              DropdownMenuItem(

                                value: status,

                                child: Row(

                                  children: [

                                    Icon(status.icon, size: 20, color: status.color),

                                    const SizedBox(width: 8.0),

                                    Text(status.displayName),

                                  ],

                                ),

                              )),

                        ],

                        onChanged: (value) => setState(() => _selectedStatus = value),

                      ),

                    ),

                  ],

                ),

                const SizedBox(height: 8.0),

                Row(

                  children: [

                    Expanded(

                      child: roomsAsync.when(

                        data: (rooms) => DropdownButtonFormField<String>(

                          decoration: const InputDecoration(labelText: 'Помещение', border: OutlineInputBorder()),

                          initialValue: _selectedRoomId,

                          items: [

                            const DropdownMenuItem(value: null, child: Text('Все')),

                            ...rooms.map((room) => DropdownMenuItem(

                                  value: room.id,

                                  child: Row(

                                    children: [

                                      Icon(room.type.icon, size: 20),

                                      const SizedBox(width: 8.0),

                                      Text(room.name),

                                    ],

                                  ),

                                )),

                          ],

                          onChanged: (value) => setState(() => _selectedRoomId = value),

                        ),

                        loading: () => const Center(child: CircularProgressIndicator()),

                        error: (err, stack) => Text('Error: ${err.toString()}'),

                      ),

                    ),

                    const SizedBox(width: 8.0),

                    Expanded(

                      child: DropdownButtonFormField<int>(

                        decoration: const InputDecoration(labelText: 'Состояние', border: OutlineInputBorder()),

                        initialValue: _selectedConditionRating,

                        items: const [

                          DropdownMenuItem(value: null, child: Text('Все')),

                          DropdownMenuItem(value: 5, child: Text('5 - Отличное')),

                          DropdownMenuItem(value: 4, child: Text('4 - Хорошее')),

                          DropdownMenuItem(value: 3, child: Text('3 - Удовлетвор.')),

                          DropdownMenuItem(value: 2, child: Text('2 - Плохое')),

                          DropdownMenuItem(value: 1, child: Text('1 - Очень плохое')),

                        ],

                        onChanged: (value) => setState(() => _selectedConditionRating = value),

                      ),

                    ),

                  ],

                ),

              ],

            ),

          ),

          Expanded(

            child: equipmentItemsAsync.when(

              data: (items) {

                final filteredItems = items.where((item) {

                  final searchQuery = _searchController.text;

                  final matchesSearch = searchQuery.isEmpty ||

                      item.inventoryNumber.toLowerCase().contains(searchQuery.toLowerCase()) ||

                      (item.model?.toLowerCase().contains(searchQuery.toLowerCase()) ?? false) ||

                      (item.manufacturer?.toLowerCase().contains(searchQuery.toLowerCase()) ?? false);

                  final matchesType = _selectedEquipmentType == null || item.typeId == _selectedEquipmentType!.id;

                  final matchesStatus = _selectedStatus == null || item.status == _selectedStatus;

                  final matchesRoom = _selectedRoomId == null || item.roomId == _selectedRoomId;

                  final matchesCondition = _selectedConditionRating == null || item.conditionRating == _selectedConditionRating;



                  return matchesSearch && matchesType && matchesStatus && matchesRoom && matchesCondition;

                }).toList();



                if (filteredItems.isEmpty) {

                  return const Center(child: Text('Экземпляры оборудования не найдены.'));

                }



                return ListView.builder(

                  itemCount: filteredItems.length,

                  itemBuilder: (context, index) {

                    final item = filteredItems[index];

                    return EquipmentItemCard(

                      item: item,

                      roomName: _getRoomName(roomsAsync.value, item.roomId),

                      equipmentTypeName: _getEquipmentTypeName(equipmentTypesAsync.value, item.typeId),

                      onTap: () {

                        Navigator.push(

                          context,

                          MaterialPageRoute(builder: (context) => EquipmentItemDetailScreen(itemId: item.id)),

                        );

                      },

                    );

                  },

                );

              },

              loading: () => const Center(child: CircularProgressIndicator()),

              error: (err, stack) => Center(child: Text('Error: $err')),

            ),

          ),

        ],

      ),

      floatingActionButton: FloatingActionButton(

        onPressed: () async {

          await Navigator.push(

            context,

            MaterialPageRoute(builder: (context) => const EquipmentItemCreateScreen()),

          );

          ref.invalidate(allEquipmentItemsProvider);

        },

        child: const Icon(Icons.add),

      ),

    );

  }

}



class EquipmentItemCard extends ConsumerWidget {

  const EquipmentItemCard({

    super.key,

    required this.item,

    this.roomName,

    this.equipmentTypeName,

    this.onTap,

  });



  final EquipmentItem item;

  final String? roomName;

  final String? equipmentTypeName;

  final VoidCallback? onTap;



  @override

  Widget build(BuildContext context, WidgetRef ref) {

    return Card(

      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),

      child: ListTile(

        onTap: onTap,

        leading: SizedBox(

          width: 50,

          height: 50,

          child: item.photoUrls.isNotEmpty

              ? Image.network(

                  item.photoUrls.first,

                  fit: BoxFit.cover,

                  errorBuilder: (context, error, stackTrace) =>

                      const Icon(Icons.broken_image),

                )

              : const Icon(Icons.fitness_center),

        ),

        title: Text(

          item.inventoryNumber,

          style: Theme.of(context).textTheme.titleMedium,

        ),

        subtitle: Row(

          crossAxisAlignment: CrossAxisAlignment.start,

          children: [

            Expanded(

              child: Column(

                crossAxisAlignment: CrossAxisAlignment.start,

                children: [

                  _buildInfoRow(context, 'Тип:', equipmentTypeName ?? 'N/A'),

                  _buildInfoRow(context, 'Модель:', item.model ?? 'N/A'),

                  _buildInfoRow(context, 'Помещение:', roomName ?? 'Не назначено'),

                ],

              ),

            ),

            const SizedBox(width: 16.0),

            Expanded(

              child: Column(

                crossAxisAlignment: CrossAxisAlignment.start,

                children: [

                  _buildInfoRow(context, 'Производитель:', item.manufacturer ?? 'N/A'),

                  Padding(

                    padding: const EdgeInsets.symmetric(vertical: 2.0),

                    child: Row(

                      children: [

                        Text('Статус: ', style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold)),

                        Flexible(

                          child: Chip(

                            label: Text(item.status.displayName),

                            backgroundColor: item.status.color,

                            visualDensity: VisualDensity.compact,

                          ),

                        ),

                      ],

                    ),

                  ),

                  Padding(

                    padding: const EdgeInsets.symmetric(vertical: 2.0),

                    child: Row(

                      children: [

                        Text('Состояние: ', style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold)),

                        ...List.generate(5, (index) {

                          return Icon(

                            index < item.conditionRating ? Icons.star : Icons.star_border,

                            color: Colors.amber,

                            size: 16,

                          );

                        }),

                      ],

                    ),

                  ),

                ],

              ),

            ),

          ],

        ),

        trailing: PopupMenuButton<String>(

          icon: const Icon(Icons.more_vert),

          onSelected: (value) async {

            switch (value) {

              case 'edit':

                await Navigator.push(

                  context,

                  MaterialPageRoute(

                    builder: (context) => EquipmentItemEditScreen(equipmentItem: item),

                  ),

                );

                ref.invalidate(allEquipmentItemsProvider);

                break;

              case 'archive':

                // TODO: Implement archive logic

                break;

              case 'maintenance':

                // TODO: Implement mark maintenance logic

                break;

              case 'book':

                // TODO: Implement booking logic

                break;

            }

          },

          itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[

            const PopupMenuItem<String>(

              value: 'edit',

              child: Text('Изменить'),

            ),

            const PopupMenuItem<String>(

              value: 'maintenance',

              child: Text('Отметить ТО'),

            ),

            const PopupMenuItem<String>(

              value: 'book',

              child: Text('Бронировать'),

            ),

            const PopupMenuItem<String>(

              value: 'archive',

              child: Text('Архивировать'),

            ),

          ],

        ),

      ),

    );

  }



  Widget _buildInfoRow(BuildContext context, String label, String value) {

    return Padding(

      padding: const EdgeInsets.symmetric(vertical: 2.0),

      child: Row(

        children: [

          Text('$label ', style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold)),

          Expanded(child: Text(value, style: Theme.of(context).textTheme.bodySmall)),

        ],

      ),

    );

  }

}
