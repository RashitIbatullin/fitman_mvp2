// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'training_group.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TrainingGroup _$TrainingGroupFromJson(Map<String, dynamic> json) =>
    TrainingGroup(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      trainingGroupTypeId: (json['trainingGroupTypeId'] as num).toInt(),
      primaryTrainerId: json['primaryTrainerId'] as String,
      primaryInstructorId: json['primaryInstructorId'] as String?,
      responsibleManagerId: json['responsibleManagerId'] as String?,
      clientIds:
          (json['clientIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      programId: json['programId'] as String?,
      goalId: json['goalId'] as String?,
      levelId: json['levelId'] as String?,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: json['endDate'] == null
          ? null
          : DateTime.parse(json['endDate'] as String),
      maxParticipants: (json['maxParticipants'] as num).toInt(),
      currentParticipants: (json['currentParticipants'] as num?)?.toInt() ?? 0,
      isActive: json['isActive'] as bool,
      chatId: json['chatId'] as String?,
    );

Map<String, dynamic> _$TrainingGroupToJson(TrainingGroup instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'trainingGroupTypeId': instance.trainingGroupTypeId,
      'primaryTrainerId': instance.primaryTrainerId,
      'primaryInstructorId': instance.primaryInstructorId,
      'responsibleManagerId': instance.responsibleManagerId,
      'clientIds': instance.clientIds,
      'programId': instance.programId,
      'goalId': instance.goalId,
      'levelId': instance.levelId,
      'startDate': instance.startDate.toIso8601String(),
      'endDate': instance.endDate?.toIso8601String(),
      'maxParticipants': instance.maxParticipants,
      'currentParticipants': instance.currentParticipants,
      'isActive': instance.isActive,
      'chatId': instance.chatId,
    };
