import 'package:hive_flutter/hive_flutter.dart';
import '../models/medicine.dart';

class MedicineRepository {
  static const String _boxName = 'medicines';
  Box<Medicine>? _box;

  /// Initialize Hive and open box
  Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(MedicineAdapter());
    _box = await Hive.openBox<Medicine>(_boxName);
  }

  /// Get all medicines sorted by time
  List<Medicine> getAllMedicines() {
    final medicines = _box?.values.toList() ?? [];
    medicines.sort((a, b) {
      // Sort by hour and minute only (ignore date)
      final aTime = a.time.hour * 60 + a.time.minute;
      final bTime = b.time.hour * 60 + b.time.minute;
      return aTime.compareTo(bTime);
    });
    return medicines;
  }

  /// Add a new medicine
  Future<void> addMedicine(Medicine medicine) async {
    await _box?.put(medicine.id, medicine);
  }

  /// Update an existing medicine
  Future<void> updateMedicine(Medicine medicine) async {
    await _box?.put(medicine.id, medicine);
  }

  /// Delete a medicine
  Future<void> deleteMedicine(String id) async {
    await _box?.delete(id);
  }

  /// Get medicine by ID
  Medicine? getMedicineById(String id) {
    return _box?.get(id);
  }

  /// Watch for changes
  Stream<List<Medicine>> watchMedicines() {
    return _box!.watch().map((_) => getAllMedicines());
  }
}