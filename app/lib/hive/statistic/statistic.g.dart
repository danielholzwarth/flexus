// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'statistic.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class StatisticAdapter extends TypeAdapter<Statistic> {
  @override
  final int typeId = 24;

  @override
  Statistic read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Statistic(
      title: fields[0] as String,
      labelX: fields[1] as String,
      labelY: fields[2] as String,
      diagramType: fields[3] as int,
    );
  }

  @override
  void write(BinaryWriter writer, Statistic obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.title)
      ..writeByte(1)
      ..write(obj.labelX)
      ..writeByte(2)
      ..write(obj.labelY)
      ..writeByte(3)
      ..write(obj.diagramType);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StatisticAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
