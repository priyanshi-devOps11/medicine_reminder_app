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
  final DateTime time;

  @HiveField(4)
  final bool isActive;

  Medicine({
    required this.id,
    required this.name,
    required this.dose,
    required this.time,
    this.isActive = true,
  });

  Medicine copyWith({
    String? id,
    String? name,
    String? dose,
    DateTime? time,
    bool? isActive,
  }) {
    return Medicine(
      id: id ?? this.id,
      name: name ?? this.name,
      dose: dose ?? this.dose,
      time: time ?? this.time,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  String toString() {
    return 'Medicine(id: $id, name: $name, dose: $dose, time: $time)';
  }
}