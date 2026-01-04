import 'package:fitman_backend/modules/infrastructure/models/equipment/equipment_item.model.dart';
import 'package:postgres/postgres.dart';

abstract class EquipmentItemRepository {
  Future<EquipmentItem> getById(String id);
  Future<List<EquipmentItem>> getAll();
  Future<EquipmentItem> create(EquipmentItem equipmentItem);
  Future<EquipmentItem> update(EquipmentItem equipmentItem);
  Future<void> delete(String id);
}

class EquipmentItemRepositoryImpl implements EquipmentItemRepository {
  EquipmentItemRepositoryImpl(this._db);

  final Connection _db;

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
  Future<List<EquipmentItem>> getAll() {
    // TODO: implement getAll
    throw UnimplementedError();
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
