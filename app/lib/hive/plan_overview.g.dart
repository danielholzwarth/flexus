// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'plan_overview.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PlanOverviewAdapter extends TypeAdapter<PlanOverview> {
  @override
  final int typeId = 14;

  @override
  PlanOverview read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PlanOverview(
      plan: fields[0] as Plan,
      splitOverviews: (fields[1] as List).cast<SplitOverview>(),
    );
  }

  @override
  void write(BinaryWriter writer, PlanOverview obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.plan)
      ..writeByte(1)
      ..write(obj.splitOverviews);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PlanOverviewAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
