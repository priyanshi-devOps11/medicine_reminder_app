// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_history.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class NotificationHistoryAdapter extends TypeAdapter<NotificationHistory> {
  @override
  final int typeId = 1;

  @override
  NotificationHistory read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return NotificationHistory(
      id: fields[0] as String,
      medicineId: fields[1] as String,
      medicineName: fields[2] as String,
      dose: fields[3] as String,
      scheduledTime: fields[4] as DateTime,
      notifiedAt: fields[5] as DateTime,
      wasAcknowledged: fields[6] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, NotificationHistory obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.medicineId)
      ..writeByte(2)
      ..write(obj.medicineName)
      ..writeByte(3)
      ..write(obj.dose)
      ..writeByte(4)
      ..write(obj.scheduledTime)
      ..writeByte(5)
      ..write(obj.notifiedAt)
      ..writeByte(6)
      ..write(obj.wasAcknowledged);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NotificationHistoryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
