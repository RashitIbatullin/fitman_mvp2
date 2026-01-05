import 'package:fitman_backend/config/database.dart';
import 'package:fitman_backend/modules/infrastructure/models/equipment/equipment_item.model.dart';

abstract class EquipmentItemRepository {
  Future<EquipmentItem> getById(String id);
  Future<List<EquipmentItem>> getAll();
  Future<EquipmentItem> create(EquipmentItem equipmentItem);
  Future<EquipmentItem> update(EquipmentItem equipmentItem);
  Future<void> delete(String id);
}

class EquipmentItemRepositoryImpl implements EquipmentItemRepository {
  EquipmentItemRepositoryImpl(this._db);

  final Database _db;

  @override
  Future<EquipmentItem> create(EquipmentItem equipmentItem) {
    // TODO: implement create
    throw UnimplementedError();
  }

  @override
  Future<void> delete(String id) {
    // TODO: implement delete
    throw UnimplementedError();
  }

  @override
  Future<List<EquipmentItem>> getAll() async {
    try {
      final conn = await _db.connection;
      final result = await conn.execute('SELECT * FROM equipment_items WHERE archived_at IS NULL');

      return result
          .map(
            (row) => EquipmentItem.fromMap(row.toColumnMap()),
          )
          .toList();
    } catch (e) {
      print('Error fetching all equipment items: $e');
      rethrow;
    }
  }

  @override
  Future<EquipmentItem> getById(String id) {
    // TODO: implement getById
    throw UnimplementedError();
  }

  @override
  Future<EquipmentItem> update(EquipmentItem equipmentItem) {
    // TODO: implement update
    throw UnimplementedError();
  }
}
