import 'package:fitman_backend/config/database.dart';
import 'package:fitman_backend/modules/infrastructure/models/equipment/equipment_type.model.dart';

abstract class EquipmentTypeRepository {
  Future<EquipmentType> getById(String id);
  Future<List<EquipmentType>> getAll();
  Future<EquipmentType> create(EquipmentType equipmentType);
  Future<EquipmentType> update(EquipmentType equipmentType);
  Future<void> delete(String id);
}

class EquipmentTypeRepositoryImpl implements EquipmentTypeRepository {
  EquipmentTypeRepositoryImpl(this._db);

  final Database _db;

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
  Future<List<EquipmentType>> getAll() async {
    try {
      final conn = await _db.connection;
      final result = await conn.execute('SELECT * FROM equipment_types WHERE archived_at IS NULL');

      return result
          .map(
            (row) => EquipmentType.fromMap(row.toColumnMap()),
          )
          .toList();
    } catch (e) {
      print('Error fetching all equipment types: $e');
      rethrow;
    }
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
