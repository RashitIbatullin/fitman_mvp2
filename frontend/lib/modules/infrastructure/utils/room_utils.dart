import '../models/room/room_type.enum.dart';

extension RoomTypeLocalization on RoomType {
  String get displayName {
    switch (this) {
      case RoomType.groupHall:
        return 'Зал групповых занятий';
      case RoomType.cardioZone:
        return 'Кардио-зона';
      case RoomType.strengthZone:
        return 'Силовая зона';
      case RoomType.mixedZone:
        return 'Смешанная зона';
      case RoomType.studio:
        return 'Студия';
      case RoomType.boxingRing:
        return 'Бокс/единоборства';
      case RoomType.pool:
        return 'Бассейн';
      case RoomType.lockerRoom:
        return 'Раздевалка';
      case RoomType.reception:
        return 'Ресепшен';
      case RoomType.office:
        return 'Офис';
      case RoomType.other:
        return 'Прочее';
    }
  }
}
