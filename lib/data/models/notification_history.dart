import 'package:hive/hive.dart';

part 'notification_history.g.dart';

@HiveType(typeId: 1)
class NotificationHistory extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String medicineId;

  @HiveField(2)
  final String medicineName;

  @HiveField(3)
  final String dose;

  @HiveField(4)
  final DateTime scheduledTime;

  @HiveField(5)
  final DateTime notifiedAt;

  @HiveField(6)
  final bool wasAcknowledged;

  NotificationHistory({
    required this.id,
    required this.medicineId,
    required this.medicineName,
    required this.dose,
    required this.scheduledTime,
    required this.notifiedAt,
    this.wasAcknowledged = false,
  });


  NotificationHistory copyWith({
    String? id,
    String? medicineId,
    String? medicineName,
    String? dose,
    DateTime? scheduledTime,
    DateTime? notifiedAt,
    bool? wasAcknowledged,
  }) {
    return NotificationHistory(
      id: id ?? this.id,
      medicineId: medicineId ?? this.medicineId,
      medicineName: medicineName ?? this.medicineName,
      dose: dose ?? this.dose,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      notifiedAt: notifiedAt ?? this.notifiedAt,
      wasAcknowledged: wasAcknowledged ?? this.wasAcknowledged,
    );
  }

  @override
  String toString() {
    return 'NotificationHistory(medicine: $medicineName, time: $notifiedAt)';
  }
}
