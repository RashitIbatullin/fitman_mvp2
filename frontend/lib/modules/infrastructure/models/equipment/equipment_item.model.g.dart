// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'equipment_item.model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$EquipmentItemImpl _$$EquipmentItemImplFromJson(Map<String, dynamic> json) =>
    _$EquipmentItemImpl(
      id: json['id'] as String,
      typeId: json['typeId'] as String,
      inventoryNumber: json['inventoryNumber'] as String,
      serialNumber: json['serialNumber'] as String?,
      model: json['model'] as String?,
      manufacturer: json['manufacturer'] as String?,
      roomId: json['roomId'] as String?,
      placementNote: json['placementNote'] as String?,
      status: $enumDecode(_$EquipmentStatusEnumMap, json['status']),
      conditionRating: (json['conditionRating'] as num).toInt(),
      conditionNotes: json['conditionNotes'] as String?,
      lastMaintenanceDate: json['lastMaintenanceDate'] == null
          ? null
          : DateTime.parse(json['lastMaintenanceDate'] as String),
      nextMaintenanceDate: json['nextMaintenanceDate'] == null
          ? null
          : DateTime.parse(json['nextMaintenanceDate'] as String),
      maintenanceNotes: json['maintenanceNotes'] as String?,
      purchaseDate: json['purchaseDate'] == null
          ? null
          : DateTime.parse(json['purchaseDate'] as String),
      purchasePrice: (json['purchasePrice'] as num?)?.toDouble(),
      supplier: json['supplier'] as String?,
      warrantyMonths: (json['warrantyMonths'] as num?)?.toInt(),
      usageHours: (json['usageHours'] as num?)?.toInt() ?? 0,
      lastUsedDate: json['lastUsedDate'] == null
          ? null
          : DateTime.parse(json['lastUsedDate'] as String),
      photoUrls:
          (json['photoUrls'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
    );

Map<String, dynamic> _$$EquipmentItemImplToJson(_$EquipmentItemImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'typeId': instance.typeId,
      'inventoryNumber': instance.inventoryNumber,
      'serialNumber': instance.serialNumber,
      'model': instance.model,
      'manufacturer': instance.manufacturer,
      'roomId': instance.roomId,
      'placementNote': instance.placementNote,
      'status': _$EquipmentStatusEnumMap[instance.status]!,
      'conditionRating': instance.conditionRating,
      'conditionNotes': instance.conditionNotes,
      'lastMaintenanceDate': instance.lastMaintenanceDate?.toIso8601String(),
      'nextMaintenanceDate': instance.nextMaintenanceDate?.toIso8601String(),
      'maintenanceNotes': instance.maintenanceNotes,
      'purchaseDate': instance.purchaseDate?.toIso8601String(),
      'purchasePrice': instance.purchasePrice,
      'supplier': instance.supplier,
      'warrantyMonths': instance.warrantyMonths,
      'usageHours': instance.usageHours,
      'lastUsedDate': instance.lastUsedDate?.toIso8601String(),
      'photoUrls': instance.photoUrls,
    };

const _$EquipmentStatusEnumMap = {
  EquipmentStatus.available: 'available',
  EquipmentStatus.inUse: 'inUse',
  EquipmentStatus.reserved: 'reserved',
  EquipmentStatus.maintenance: 'maintenance',
  EquipmentStatus.outOfOrder: 'outOfOrder',
  EquipmentStatus.storage: 'storage',
};
