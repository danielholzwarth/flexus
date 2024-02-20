// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workout_overview.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class WorkoutOverviewAdapter extends TypeAdapter<WorkoutOverview> {
  @override
  final int typeId = 3;

  @override
  WorkoutOverview read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return WorkoutOverview(
      workout: fields[0] as Workout,
      splitName: fields[1] as String?,
      planName: fields[2] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, WorkoutOverview obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.workout)
      ..writeByte(1)
      ..write(obj.splitName)
      ..writeByte(2)
      ..write(obj.planName);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WorkoutOverviewAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
