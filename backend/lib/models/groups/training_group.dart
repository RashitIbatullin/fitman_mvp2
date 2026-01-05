import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';

part 'training_group.g.dart';

@JsonSerializable()
class TrainingGroup extends Equatable {
  final int id;
  final String name;
  final String? description;
  
  // ПЕРСОНАЛ (обязательные для тренировочного процесса)
  final int primaryTrainerId;     // Основной тренер группы (обязательно)
  final int? primaryInstructorId; // Основной инструктор группы
  final int? responsibleManagerId; // Ответственный менеджер
  
  // СОСТАВ ГРУППЫ (фиксированный)
  final List<int> clientIds;      // Фиксированный состав участников
  
  // РАСПИСАНИЕ ЗАНЯТИЙ - This will be fetched separately or populated by a service
  // List<GroupScheduleSlot> scheduleSlots; 
  
  // ПАРАМЕТРЫ ТРЕНИРОВКИ
  final int? programId;           // Ссылка на программу тренировок
  final int? goalId;              // Цель тренировок (похудение, набор массы и т.д.)
  final int? levelId;             // Уровень подготовки группы
  
  // ЛИМИТЫ И ОГРАНИЧЕНИЯ
  final DateTime startDate;          // Дата начала работы группы
  final DateTime? endDate;           // Дата окончания (если предусмотрена)
  final int maxParticipants;         // Максимальное количество участников
  final int? currentParticipants;     // Текущее количество участников
  
  // СТАТУС И СВЯЗИ
  final bool? isActive;               // Активна ли группа
  final int? chatId;              // Ссылка на групповой чат (создается автоматически)

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
    this.currentParticipants, // Теперь nullable, убираем дефолтное значение
    this.isActive,            // Теперь nullable, убираем дефолтное значение
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

  TrainingGroup copyWith({
    int? id,
    String? name,
    String? description,
    int? primaryTrainerId,
    int? primaryInstructorId,
    int? responsibleManagerId,
    List<int>? clientIds,
    int? programId,
    int? goalId,
    int? levelId,
    DateTime? startDate,
    DateTime? endDate,
    int? maxParticipants,
    int? currentParticipants,
    bool? isActive,
    int? chatId,
  }) {
    return TrainingGroup(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      primaryTrainerId: primaryTrainerId ?? this.primaryTrainerId,
      primaryInstructorId: primaryInstructorId ?? this.primaryInstructorId,
      responsibleManagerId: responsibleManagerId ?? this.responsibleManagerId,
      clientIds: clientIds ?? this.clientIds,
      programId: programId ?? this.programId,
      goalId: goalId ?? this.goalId,
      levelId: levelId ?? this.levelId,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      maxParticipants: maxParticipants ?? this.maxParticipants,
      currentParticipants: currentParticipants ?? this.currentParticipants,
      isActive: isActive ?? this.isActive,
      chatId: chatId ?? this.chatId,
    );
  }
}