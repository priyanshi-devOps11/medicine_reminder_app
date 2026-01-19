import 'package:hive/hive.dart';

part 'medicine.g.dart';

@HiveType(typeId: 0)
class Medicine extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String dose;

  @HiveField(3)
  final DateTime time; // Time of day for reminder

  @HiveField(4)
  final bool isActive;

  @HiveField(5)
  final DateTime startDate; // When to start reminders

  @HiveField(6)
  final DateTime? endDate; // When to end reminders (null = continuous)

  @HiveField(7)
  final String frequency; // 'daily', 'weekly', 'custom'

  @HiveField(8)
  final List<int>? customDays; // For weekly: [1=Mon, 2=Tue, etc.]

  @HiveField(9)
  final String? notes; // Optional notes

  Medicine({
    required this.id,
    required this.name,
    required this.dose,
    required this.time,
    required this.startDate,
    this.endDate,
    this.frequency = 'daily',
    this.customDays,
    this.notes,
    this.isActive = true,
  });

  /// Check if medicine is active today
  bool isActiveToday() {
    final now = DateTime.now();

    // Check if within date range
    if (now.isBefore(startDate)) return false;
    if (endDate != null && now.isAfter(endDate!)) return false;

    // Check frequency
    if (frequency == 'daily') return true;

    if (frequency == 'weekly' && customDays != null) {
      return customDays!.contains(now.weekday);
    }

    return true;
  }

  /// Get days remaining in the course
  int? getDaysRemaining() {
    if (endDate == null) return null;
    final now = DateTime.now();
    return endDate!.difference(now).inDays;
  }

  /// Get readable duration text
  String getDurationText() {
    if (endDate == null) return 'Continuous';
    final days = getDaysRemaining();
    if (days == null || days < 0) return 'Completed';
    if (days == 0) return 'Last day';
    if (days == 1) return '1 day left';
    if (days < 7) return '$days days left';
    if (days < 30) return '${(days / 7).ceil()} weeks left';
    return '${(days / 30).ceil()} months left';
  }

  Medicine copyWith({
    String? id,
    String? name,
    String? dose,
    DateTime? time,
    DateTime? startDate,
    DateTime? endDate,
    String? frequency,
    List<int>? customDays,
    String? notes,
    bool? isActive,
  }) {
    return Medicine(
      id: id ?? this.id,
      name: name ?? this.name,
      dose: dose ?? this.dose,
      time: time ?? this.time,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      frequency: frequency ?? this.frequency,
      customDays: customDays ?? this.customDays,
      notes: notes ?? this.notes,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  String toString() {
    return 'Medicine(id: $id, name: $name, dose: $dose, '
        'start: $startDate, end: $endDate, frequency: $frequency)';
  }
}