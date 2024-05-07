// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'timer_value.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TimerValueAdapter extends TypeAdapter<TimerValue> {
  @override
  final int typeId = 23;

  @override
  TimerValue read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TimerValue(
      isRunning: fields[0] as bool,
      milliseconds: fields[1] as int,
    );
  }

  @override
  void write(BinaryWriter writer, TimerValue obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.isRunning)
      ..writeByte(1)
      ..write(obj.milliseconds);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TimerValueAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
