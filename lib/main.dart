import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';
import 'core/utils/notification_service.dart';
import 'data/repositories/medicine_repository.dart';
import 'data/repositories/history_repository.dart';
import 'presentation/providers/medicine_provider.dart';

/// Entry point of the Medicine Reminder application
void main() async {
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();

  print('🚀 Starting Medicine Reminder App...');
  print('=' * 50);

  try {
    // Initialize notification service
    print('🔔 Initializing Notification Service...');
    final notificationService = NotificationService();
    await notificationService.init();
    print('✅ Notification Service initialized\n');

    // Initialize medicine repository
    print('💾 Initializing Medicine Repository...');
    final repository = MedicineRepository();
    await repository.init();
    print('✅ Medicine Repository initialized\n');

    // Initialize history repository
    print('📚 Initializing History Repository...');
    final historyRepository = HistoryRepository();
    await historyRepository.init();
    print('✅ History Repository initialized\n');

    print('=' * 50);
    print('🎉 All services initialized successfully!');
    print('📱 Starting app...\n');

    // Run app with provider overrides
    runApp(
      ProviderScope(
        overrides: [
          medicineRepositoryProvider.overrideWithValue(repository),
          historyRepositoryProvider.overrideWithValue(historyRepository),
          notificationServiceProvider.overrideWithValue(notificationService),
        ],
        child: const MedicineReminderApp(),
      ),
    );
  } catch (e, stackTrace) {
    print('❌ FATAL ERROR during initialization:');
    print('Error: $e');
    print('Stack trace: $stackTrace');

    // Show error screen
    runApp(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 80,
                    color: Colors.red,
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Failed to Initialize App',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error: $e',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Please restart the app',
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}