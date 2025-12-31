import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';

part 'training_group.g.dart';

@JsonSerializable()
class TrainingGroup extends Equatable {
  final String id;
  final String name;
  final String? description;
  
  // ПЕРСОНАЛ (обязательные для тренировочного процесса)
  final String primaryTrainerId;     // Основной тренер группы (обязательно)
  final String? primaryInstructorId; // Основной инструктор группы
  final String? responsibleManagerId; // Ответственный менеджер
  
  // СОСТАВ ГРУППЫ (фиксированный)
  final List<String> clientIds;      // Фиксированный состав участников
  
  // РАСПИСАНИЕ ЗАНЯТИЙ - This will be fetched separately or populated by a service
  // List<GroupScheduleSlot> scheduleSlots; 
  
  // ПАРАМЕТРЫ ТРЕНИРОВКИ
  final String? programId;           // Ссылка на программу тренировок
  final String? goalId;              // Цель тренировок (похудение, набор массы и т.д.)
  final String? levelId;             // Уровень подготовки группы
  
  // ЛИМИТЫ И ОГРАНИЧЕНИЯ
  final DateTime startDate;          // Дата начала работы группы
  final DateTime? endDate;           // Дата окончания (если предусмотрена)
  final int maxParticipants;         // Максимальное количество участников
  final int currentParticipants;     // Текущее количество участников
  
  // СТАТУС И СВЯЗИ
  final bool isActive;               // Активна ли группа
  final String? chatId;              // Ссылка на групповой чат (создается автоматически)

  const TrainingGroup({
    required this.id,
    required this.name,
    this.description,
    required this.primaryTrainerId,
    this.primaryInstructorId,
    this.responsibleManagerId,
    this.clientIds = const [],
    this.programId,
    this.goalId,
    this.levelId,
    required this.startDate,
    this.endDate,
    required this.maxParticipants,
    this.currentParticipants = 0,
    required this.isActive,
    this.chatId,
  });

  factory TrainingGroup.fromJson(Map<String, dynamic> json) => _$TrainingGroupFromJson(json);
  Map<String, dynamic> toJson() => _$TrainingGroupToJson(this);

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        primaryTrainerId,
        primaryInstructorId,
        responsibleManagerId,
        clientIds,
        programId,
        goalId,
        levelId,
        startDate,
        endDate,
        maxParticipants,
        currentParticipants,
        isActive,
        chatId,
      ];
}