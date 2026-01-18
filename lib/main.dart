import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';
import 'core/utils/notification_service.dart';
import 'data/repositories/medicine_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize services
  final notificationService = NotificationService();
  await notificationService.init();

  final repository = MedicineRepository();
  await repository.init();

  runApp(
    const ProviderScope(
      child: MedicineReminderApp(),
    ),
  );
}