// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'analytic_group.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AnalyticGroup _$AnalyticGroupFromJson(Map<String, dynamic> json) =>
    AnalyticGroup(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      type: const AnalyticGroupTypeConverter().fromJson(
        (json['type'] as num).toInt(),
      ),
      isAutoUpdate: json['isAutoUpdate'] as bool? ?? false,
      conditions:
          (json['conditions'] as List<dynamic>?)
              ?.map((e) => GroupCondition.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      clientIds:
          (json['clientIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      lastUpdatedAt: json['lastUpdatedAt'] == null
          ? null
          : DateTime.parse(json['lastUpdatedAt'] as String),
      metadata: json['metadata'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$AnalyticGroupToJson(AnalyticGroup instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'type': const AnalyticGroupTypeConverter().toJson(instance.type),
      'isAutoUpdate': instance.isAutoUpdate,
      'conditions': instance.conditions,
      'clientIds': instance.clientIds,
      'lastUpdatedAt': instance.lastUpdatedAt?.toIso8601String(),
      'metadata': instance.metadata,
    };
