import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/medicine.dart';
import '../../data/models/notification_history.dart';
import '../../data/repositories/medicine_repository.dart';
import '../../data/repositories/history_repository.dart';
import '../../core/utils/notification_service.dart';

final medicineRepositoryProvider = Provider<MedicineRepository>((ref) {
  throw UnimplementedError('Repository must be overridden in main.dart');
});

final historyRepositoryProvider = Provider<HistoryRepository>((ref) {
  throw UnimplementedError('History repository must be overridden in main.dart');
});

final notificationServiceProvider = Provider<NotificationService>((ref) {
  throw UnimplementedError('Service must be overridden in main.dart');
});

final medicineListProvider = StreamProvider<List<Medicine>>((ref) {
  final repository = ref.watch(medicineRepositoryProvider);
  return repository.watchMedicines();
});

final historyListProvider = StreamProvider<List<NotificationHistory>>((ref) {
  final repository = ref.watch(historyRepositoryProvider);
  return repository.watchHistory();
});

final medicineActionsProvider = Provider<MedicineActions>((ref) {
  return MedicineActions(
    repository: ref.read(medicineRepositoryProvider),
    historyRepository: ref.read(historyRepositoryProvider),
    notificationService: ref.read(notificationServiceProvider),
    ref: ref,
  );
});

class MedicineActions {
  final MedicineRepository repository;
  final HistoryRepository historyRepository;
  final NotificationService notificationService;
  final Ref ref;

  MedicineActions({
    required this.repository,
    required this.historyRepository,
    required this.notificationService,
    required this.ref,
  });

  /// Add medicine with date range support
  Future<void> addMedicine({
    required String name,
    required String dose,
    required DateTime time,
    required DateTime startDate,
    DateTime? endDate,
    String frequency = 'daily',
    List<int>? customDays,
    String? notes,
  }) async {
    try {
      final id = DateTime.now().millisecondsSinceEpoch.toString();

      final medicine = Medicine(
        id: id,
        name: name,
        dose: dose,
        time: time,
        startDate: startDate,
        endDate: endDate,
        frequency: frequency,
        customDays: customDays,
        notes: notes,
      );

      print('💾 Saving medicine: ${medicine.name}');
      await repository.addMedicine(medicine);
      print('✅ Medicine saved successfully');

      // Schedule notifications
      print('📅 Scheduling notifications...');
      if (frequency == 'daily') {
        await _scheduleDailyNotifications(medicine);
      } else if (frequency == 'weekly' && customDays != null) {
        await _scheduleWeeklyNotifications(medicine, customDays);
      }

      // Show test notification to confirm it's working
      await notificationService.showTestNotification(
        medicineName: name,
        dose: dose,
      );

      // Refresh the list
      ref.invalidate(medicineListProvider);

      // Add to history
      await _addToHistory(medicine);

      print('✅ Medicine added successfully with notifications');
    } catch (e) {
      print('❌ Error adding medicine: $e');
      rethrow;
    }
  }

  /// Schedule daily notifications
  Future<void> _scheduleDailyNotifications(Medicine medicine) async {
    try {
      await notificationService.scheduleMedicineReminder(
        id: medicine.id.hashCode,
        medicineName: medicine.name,
        dose: medicine.dose,
        scheduledTime: medicine.time,
      );
      print('✅ Daily notification scheduled for ${medicine.name}');
    } catch (e) {
      print('❌ Error scheduling daily notification: $e');
    }
  }

  /// Schedule weekly notifications for specific days
  Future<void> _scheduleWeeklyNotifications(
      Medicine medicine,
      List<int> days,
      ) async {
    for (var day in days) {
      try {
        await notificationService.scheduleMedicineReminder(
          id: '${medicine.id}_$day'.hashCode,
          medicineName: medicine.name,
          dose: medicine.dose,
          scheduledTime: medicine.time,
        );
      } catch (e) {
        print('❌ Error scheduling notification for day $day: $e');
      }
    }
    print('✅ Weekly notifications scheduled for ${medicine.name}');
  }

  /// Add medicine addition to history
  Future<void> _addToHistory(Medicine medicine) async {
    try {
      final history = NotificationHistory(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        medicineId: medicine.id,
        medicineName: medicine.name,
        dose: medicine.dose,
        scheduledTime: medicine.time,
        notifiedAt: DateTime.now(),
        wasAcknowledged: true,
      );

      await historyRepository.addHistory(history);
      ref.invalidate(historyListProvider);
    } catch (e) {
      print('⚠️ Could not add to history: $e');
    }
  }

  Future<void> deleteMedicine(Medicine medicine) async {
    try {
      print('🗑️ Deleting medicine: ${medicine.name}');

      await repository.deleteMedicine(medicine.id);

      // Cancel all notifications for this medicine
      if (medicine.frequency == 'weekly' && medicine.customDays != null) {
        for (var day in medicine.customDays!) {
          await notificationService.cancelNotification(
            '${medicine.id}_$day'.hashCode,
          );
        }
      } else {
        await notificationService.cancelNotification(medicine.id.hashCode);
      }

      ref.invalidate(medicineListProvider);
      print('✅ Medicine deleted successfully');
    } catch (e) {
      print('❌ Error deleting medicine: $e');
      rethrow;
    }
  }

  Future<void> updateMedicine(Medicine medicine) async {
    try {
      await repository.updateMedicine(medicine);

      // Reschedule notifications
      if (medicine.frequency == 'daily') {
        await _scheduleDailyNotifications(medicine);
      } else if (medicine.frequency == 'weekly' && medicine.customDays != null) {
        await _scheduleWeeklyNotifications(medicine, medicine.customDays!);
      }

      ref.invalidate(medicineListProvider);
    } catch (e) {
      print('❌ Error updating medicine: $e');
      rethrow;
    }
  }

  /// Get all pending notifications for debugging
  Future<void> checkPendingNotifications() async {
    final pending = await notificationService.getPendingNotifications();
    print('📋 Pending notifications: ${pending.length}');
    for (var notification in pending) {
      print('  - ID: ${notification.id}, Title: ${notification.title}');
    }
  }
}