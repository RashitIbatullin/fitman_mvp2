// ignore_for_file: constant_identifier_names

enum RoomType {
  groupHall(0),
  cardioZone(1),
  strengthZone(2),
  mixedZone(3),
  studio(4),
  boxingRing(5),
  pool(6),
  sauna(7),
  lockerRoom(8),
  reception(9),
  office(10),
  other(11);

  final int value;
  const RoomType(this.value);
}