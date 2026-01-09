// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reminder_hive.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ReminderHiveAdapter extends TypeAdapter<ReminderHive> {
  @override
  final int typeId = 1;

  @override
  ReminderHive read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ReminderHive(
      id: fields[0] as String,
      title: fields[1] as String,
      hour: fields[2] as int,
      minute: fields[3] as int,
      createdAtIso: fields[4] as String?,
      sent: fields[5] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, ReminderHive obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.hour)
      ..writeByte(3)
      ..write(obj.minute)
      ..writeByte(4)
      ..write(obj.createdAtIso)
      ..writeByte(5)
      ..write(obj.sent);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReminderHiveAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
