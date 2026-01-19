import 'package:hive_flutter/hive_flutter.dart';
import '../models/medicine.dart';

/// Repository for managing medicine data persistence using Hive
class MedicineRepository {
  static const String _boxName = 'medicines_box';
  Box<Medicine>? _box;
  bool _isInitialized = false;

  /// Initialize Hive and open the medicines box
  Future<void> init() async {
    if (_isInitialized) return;

    try {
      await Hive.initFlutter();

      // Register adapter only if not already registered
      if (!Hive.isAdapterRegistered(0)) {
        Hive.registerAdapter(MedicineAdapter());
      }

      // Open box
      _box = await Hive.openBox<Medicine>(_boxName);
      _isInitialized = true;

      print('✅ Medicine Repository initialized successfully');
      print('📊 Current medicines count: ${_box?.length ?? 0}');
    } catch (e) {
      print('❌ Error initializing repository: $e');
      rethrow;
    }
  }

  /// Get all medicines sorted by time (earliest first)
  List<Medicine> getAllMedicines() {
    if (_box == null || !_box!.isOpen) {
      print('⚠️ Warning: Box is not open');
      return [];
    }

    final medicines = _box!.values.toList();
    print('📋 Retrieved ${medicines.length} medicines from storage');

    medicines.sort((a, b) {
      // Sort by hour and minute only
      final aTime = a.time.hour * 60 + a.time.minute;
      final bTime = b.time.hour * 60 + b.time.minute;
      return aTime.compareTo(bTime);
    });

    return medicines;
  }

  /// Add a new medicine to the database
  Future<void> addMedicine(Medicine medicine) async {
    if (_box == null || !_box!.isOpen) {
      throw Exception('Box is not initialized');
    }

    await _box!.put(medicine.id, medicine);
    print('✅ Medicine added: ${medicine.name} (ID: ${medicine.id})');
    print('📊 Total medicines: ${_box!.length}');
  }

  /// Update an existing medicine
  Future<void> updateMedicine(Medicine medicine) async {
    if (_box == null || !_box!.isOpen) {
      throw Exception('Box is not initialized');
    }

    await _box!.put(medicine.id, medicine);
    print('✅ Medicine updated: ${medicine.name}');
  }

  /// Delete a medicine by ID
  Future<void> deleteMedicine(String id) async {
    if (_box == null || !_box!.isOpen) {
      throw Exception('Box is not initialized');
    }

    await _box!.delete(id);
    print('✅ Medicine deleted: $id');
    print('📊 Remaining medicines: ${_box!.length}');
  }

  /// Get a medicine by ID
  Medicine? getMedicineById(String id) {
    if (_box == null || !_box!.isOpen) return null;
    return _box!.get(id);
  }

  /// Watch for changes in the medicine database (REAL-TIME UPDATES)
  Stream<List<Medicine>> watchMedicines() async* {
    if (_box == null || !_box!.isOpen) {
      print('⚠️ Warning: Box is not open for watching');
      yield [];
      return;
    }

    // Yield initial data
    yield getAllMedicines();

    // Listen for changes
    await for (final _ in _box!.watch()) {
      yield getAllMedicines();
    }
  }

  /// Check if repository is initialized
  bool get isInitialized => _isInitialized && _box != null && _box!.isOpen;
}