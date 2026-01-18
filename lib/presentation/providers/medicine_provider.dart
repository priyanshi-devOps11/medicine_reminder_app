import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/medicine.dart';
import '../../data/repositories/medicine_repository.dart';
import '../../core/utils/notification_service.dart';

/// Repository Provider
final medicineRepositoryProvider = Provider<MedicineRepository>((ref) {
  return MedicineRepository();
});

/// Notification Service Provider
final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

/// Medicine List Provider
final medicineListProvider = StreamProvider<List<Medicine>>((ref) {
  final repository = ref.watch(medicineRepositoryProvider);
  return repository.watchMedicines();
});

/// Medicine Actions Provider
final medicineActionsProvider = Provider<MedicineActions>((ref) {
  final repository = ref.watch(medicineRepositoryProvider);
  final notificationService = ref.watch(notificationServiceProvider);
  return MedicineActions(repository, notificationService);
});

/// Medicine Actions Class
class MedicineActions {
  final MedicineRepository _repository;
  final NotificationService _notificationService;

  MedicineActions(this._repository, this._notificationService);

  /// Add a new medicine
  Future<void> addMedicine({
    required String name,
    required String dose,
    required DateTime time,
  }) async {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final medicine = Medicine(
      id: id,
      name: name,
      dose: dose,
      time: time,
    );

    await _repository.addMedicine(medicine);

    // Schedule notification
    await _notificationService.scheduleMedicineReminder(
      id: id.hashCode, // Convert string ID to int
      medicineName: name,
      dose: dose,
      scheduledTime: time,
    );
  }

  /// Delete a medicine
  Future<void> deleteMedicine(Medicine medicine) async {
    await _repository.deleteMedicine(medicine.id);
    await _notificationService.cancelNotification(medicine.id.hashCode);
  }

  /// Update a medicine
  Future<void> updateMedicine(Medicine medicine) async {
    await _repository.updateMedicine(medicine);

    // Reschedule notification
    await _notificationService.cancelNotification(medicine.id.hashCode);
    await _notificationService.scheduleMedicineReminder(
      id: medicine.id.hashCode,
      medicineName: medicine.name,
      dose: medicine.dose,
      scheduledTime: medicine.time,
    );
  }
}