import 'package:hive_flutter/hive_flutter.dart';
import '../models/notification_history.dart';

/// Repository for managing notification history
class HistoryRepository {
  static const String _boxName = 'notification_history_box';
  Box<NotificationHistory>? _box;
  bool _isInitialized = false;

  /// Initialize Hive and open the history box
  Future<void> init() async {
    if (_isInitialized) return;

    try {
      // Register adapter only if not already registered
      if (!Hive.isAdapterRegistered(1)) {
        Hive.registerAdapter(NotificationHistoryAdapter());
      }

      // Open box
      _box = await Hive.openBox<NotificationHistory>(_boxName);
      _isInitialized = true;

      print('✅ History Repository initialized successfully');
      print('📊 Total history records: ${_box?.length ?? 0}');
    } catch (e) {
      print('❌ Error initializing history repository: $e');
      rethrow;
    }
  }

  /// Add a notification history entry
  Future<void> addHistory(NotificationHistory history) async {
    if (_box == null || !_box!.isOpen) {
      throw Exception('History box is not initialized');
    }

    await _box!.put(history.id, history);
    print('✅ History added: ${history.medicineName}');
  }

  /// Get all history sorted by date (newest first)
  List<NotificationHistory> getAllHistory() {
    if (_box == null || !_box!.isOpen) return [];

    final history = _box!.values.toList();
    history.sort((a, b) => b.notifiedAt.compareTo(a.notifiedAt));
    return history;
  }

  /// Get history for a specific medicine
  List<NotificationHistory> getHistoryForMedicine(String medicineId) {
    if (_box == null || !_box!.isOpen) return [];

    return _box!.values
        .where((h) => h.medicineId == medicineId)
        .toList()
      ..sort((a, b) => b.notifiedAt.compareTo(a.notifiedAt));
  }

  /// Get history for today
  List<NotificationHistory> getTodayHistory() {
    if (_box == null || !_box!.isOpen) return [];

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return _box!.values
        .where((h) {
      final historyDate = DateTime(
        h.notifiedAt.year,
        h.notifiedAt.month,
        h.notifiedAt.day,
      );
      return historyDate.isAtSameMomentAs(today);
    })
        .toList()
      ..sort((a, b) => b.notifiedAt.compareTo(a.notifiedAt));
  }

  /// Mark history as acknowledged
  Future<void> acknowledgeHistory(String id) async {
    if (_box == null || !_box!.isOpen) return;

    final history = _box!.get(id);
    if (history != null) {
      final updated = history.copyWith(wasAcknowledged: true);
      await _box!.put(id, updated);
    }
  }

  /// Clear old history (keep last 30 days)
  Future<void> clearOldHistory() async {
    if (_box == null || !_box!.isOpen) return;

    final cutoffDate = DateTime.now().subtract(const Duration(days: 30));
    final toDelete = <String>[];

    for (var history in _box!.values) {
      if (history.notifiedAt.isBefore(cutoffDate)) {
        toDelete.add(history.id);
      }
    }

    for (var id in toDelete) {
      await _box!.delete(id);
    }

    print('✅ Cleared ${toDelete.length} old history records');
  }

  /// Watch for changes
  Stream<List<NotificationHistory>> watchHistory() async* {
    if (_box == null || !_box!.isOpen) {
      yield [];
      return;
    }

    yield getAllHistory();

    await for (final _ in _box!.watch()) {
      yield getAllHistory();
    }
  }

  /// Check if repository is initialized
  bool get isInitialized => _isInitialized && _box != null && _box!.isOpen;
}