// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'current_plan.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CurrentPlanAdapter extends TypeAdapter<CurrentPlan> {
  @override
  final int typeId = 22;

  @override
  CurrentPlan read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CurrentPlan(
      plan: fields[0] as Plan,
      currentSplit: fields[1] as int,
      splits: (fields[2] as List).cast<Split>(),
    );
  }

  @override
  void write(BinaryWriter writer, CurrentPlan obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.plan)
      ..writeByte(1)
      ..write(obj.currentSplit)
      ..writeByte(2)
      ..write(obj.splits);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CurrentPlanAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
