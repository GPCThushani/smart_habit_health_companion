// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'habit_hive.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class HabitHiveAdapter extends TypeAdapter<HabitHive> {
  @override
  final int typeId = 0;

  @override
  HabitHive read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HabitHive(
      id: fields[0] as String,
      title: fields[1] as String,
      notes: fields[2] as String?,
      isCompleted: fields[3] as bool,
      reminderHour: fields[4] as int?,
      reminderMinute: fields[5] as int?,
      createdAtIso: fields[6] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, HabitHive obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.notes)
      ..writeByte(3)
      ..write(obj.isCompleted)
      ..writeByte(4)
      ..write(obj.reminderHour)
      ..writeByte(5)
      ..write(obj.reminderMinute)
      ..writeByte(6)
      ..write(obj.createdAtIso);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HabitHiveAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
