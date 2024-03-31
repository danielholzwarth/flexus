// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'plan.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PlanAdapter extends TypeAdapter<Plan> {
  @override
  final int typeId = 12;

  @override
  Plan read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Plan(
      id: fields[0] as int,
      userID: fields[1] as int,
      splitCount: fields[2] as int,
      name: fields[3] as String,
      startDate: fields[4] as DateTime,
      isWeekly: fields[5] as bool,
      isMondayRest: fields[6] as bool,
      isTuesdayRest: fields[7] as bool,
      isWednesdayRest: fields[8] as bool,
      isThursdayRest: fields[9] as bool,
      isFridayRest: fields[10] as bool,
      isSaturdayRest: fields[11] as bool,
      isSundayRest: fields[12] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, Plan obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.userID)
      ..writeByte(2)
      ..write(obj.splitCount)
      ..writeByte(3)
      ..write(obj.name)
      ..writeByte(4)
      ..write(obj.startDate)
      ..writeByte(5)
      ..write(obj.isWeekly)
      ..writeByte(6)
      ..write(obj.isMondayRest)
      ..writeByte(7)
      ..write(obj.isTuesdayRest)
      ..writeByte(8)
      ..write(obj.isWednesdayRest)
      ..writeByte(9)
      ..write(obj.isThursdayRest)
      ..writeByte(10)
      ..write(obj.isFridayRest)
      ..writeByte(11)
      ..write(obj.isSaturdayRest)
      ..writeByte(12)
      ..write(obj.isSundayRest);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PlanAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
