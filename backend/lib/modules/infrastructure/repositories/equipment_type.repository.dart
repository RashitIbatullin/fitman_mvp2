import 'package:fitman_backend/modules/infrastructure/models/equipment/equipment_type.model.dart';
import 'package:postgres/postgres.dart';

abstract class EquipmentTypeRepository {
  Future<EquipmentType> getById(String id);
  Future<List<EquipmentType>> getAll();
  Future<EquipmentType> create(EquipmentType equipmentType);
  Future<EquipmentType> update(EquipmentType equipmentType);
  Future<void> delete(String id);
}

class EquipmentTypeRepositoryImpl implements EquipmentTypeRepository {
  EquipmentTypeRepositoryImpl(this._db);

  final Connection _db;

  @override
  Future<EquipmentType> create(EquipmentType equipmentType) {
    // TODO: implement create
    throw UnimplementedError();
  }

  @override
  Future<void> delete(String id) {
    // TODO: implement delete
    throw UnimplementedError();
  }

  @override
  Future<List<EquipmentType>> getAll() {
    // TODO: implement getAll
    throw UnimplementedError();
  }

  @override
  Future<EquipmentType> getById(String id) {
    // TODO: implement getById
    throw UnimplementedError();
  }

  @override
  Future<EquipmentType> update(EquipmentType equipmentType) {
    // TODO: implement update
    throw UnimplementedError();
  }
}
