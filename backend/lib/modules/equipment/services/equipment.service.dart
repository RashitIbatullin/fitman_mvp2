
import 'package:fitman_backend/modules/equipment/models/equipment/equipment_item.model.dart';
import 'package:fitman_backend/modules/equipment/models/equipment/equipment_type.model.dart';
import 'package:fitman_backend/modules/equipment/repositories/equipment_item.repository.dart';
import 'package:fitman_backend/modules/equipment/repositories/equipment_type.repository.dart';

abstract class EquipmentService {
  Future<EquipmentType> getTypeById(String id);
  Future<List<EquipmentType>> getAllTypes();
  Future<EquipmentType> createType(EquipmentType equipmentType);
  Future<EquipmentType> updateType(EquipmentType equipmentType);
  Future<void> deleteType(String id);

  Future<EquipmentItem> getItemById(String id);
  Future<List<EquipmentItem>> getAllItems();
  Future<List<EquipmentItem>> getItemsByRoomId(String roomId);
  Future<EquipmentItem> createItem(EquipmentItem equipmentItem);
  Future<EquipmentItem> updateItem(EquipmentItem equipmentItem);
  Future<void> deleteItem(String id);
}

class EquipmentServiceImpl implements EquipmentService {
  EquipmentServiceImpl(this._typeRepository, this._itemRepository);

  final EquipmentTypeRepository _typeRepository;
  final EquipmentItemRepository _itemRepository;

  @override
  Future<EquipmentType> createType(EquipmentType equipmentType) {
    return _typeRepository.create(equipmentType);
  }

  @override
  Future<void> deleteType(String id) {
    return _typeRepository.delete(id);
  }

  @override
  Future<List<EquipmentType>> getAllTypes() {
    return _typeRepository.getAll();
  }

  @override
  Future<EquipmentType> getTypeById(String id) {
    return _typeRepository.getById(id);
  }

  @override
  Future<EquipmentType> updateType(EquipmentType equipmentType) {
    return _typeRepository.update(equipmentType);
  }

  @override
  Future<EquipmentItem> createItem(EquipmentItem equipmentItem) {
    return _itemRepository.create(equipmentItem);
  }

  @override
  Future<void> deleteItem(String id) {
    return _itemRepository.delete(id);
  }

  @override
  Future<List<EquipmentItem>> getAllItems() {
    return _itemRepository.getAll();
  }

  @override
  Future<List<EquipmentItem>> getItemsByRoomId(String roomId) {
    return _itemRepository.getByRoomId(roomId);
  }

  @override
  Future<EquipmentItem> getItemById(String id) {
    return _itemRepository.getById(id);
  }

  @override
  Future<EquipmentItem> updateItem(EquipmentItem equipmentItem) {
    return _itemRepository.update(equipmentItem);
  }
}
