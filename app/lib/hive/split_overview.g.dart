// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'split_overview.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SplitOverviewAdapter extends TypeAdapter<SplitOverview> {
  @override
  final int typeId = 16;

  @override
  SplitOverview read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SplitOverview(
      split: fields[0] as Split,
      exercises: (fields[1] as List).cast<Exercise>(),
      repetitions: (fields[2] as List)
          .map((dynamic e) => (e as List).cast<String>())
          .toList(),
    );
  }

  @override
  void write(BinaryWriter writer, SplitOverview obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.split)
      ..writeByte(1)
      ..write(obj.exercises)
      ..writeByte(2)
      ..write(obj.repetitions);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SplitOverviewAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
