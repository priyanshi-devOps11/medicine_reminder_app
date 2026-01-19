import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/medicine_provider.dart';
import '../widgets/medicine_card.dart';
import '../widgets/empty_state.dart';
import 'add_medicine_screen.dart';
import 'history_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final medicinesAsync = ref.watch(medicineListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Medicine Reminder'),
        actions: [
          // History button
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: 'View History',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const HistoryScreen(),
                ),
              );
            },
          ),
          // Debug info button
          IconButton(
            icon: const Icon(Icons.bug_report),
            tooltip: 'Debug Info',
            onPressed: () => _showDebugInfo(context, ref),
          ),
          // About button
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showAboutDialog(context),
          ),
        ],
      ),
      body: medicinesAsync.when(
        data: (medicines) {
          if (medicines.isEmpty) {
            return const EmptyState();
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: medicines.length,
            itemBuilder: (context, index) {
              final medicine = medicines[index];
              return MedicineCard(
                medicine: medicine,
                onDelete: () async {
                  final actions = ref.read(medicineActionsProvider);
                  await actions.deleteMedicine(medicine);

                  if (!context.mounted) return;

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${medicine.name} deleted successfully'),
                      backgroundColor: Colors.red[700],
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
              );
            },
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red[300],
              ),
              const SizedBox(height: 16),
              const Text(
                'Something went wrong',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Error: $error',
                style: const TextStyle(color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const AddMedicineScreen(),
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Medicine'),
      ),
    );
  }

  void _showDebugInfo(BuildContext context, WidgetRef ref) async {
    final actions = ref.read(medicineActionsProvider);
    await actions.checkPendingNotifications();

    if (!context.mounted) return;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('🐛 Debug Info'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '📊 Check the console/logcat for:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('• Number of medicines saved'),
              Text('• Pending notifications count'),
              Text('• Notification scheduling status'),
              Text('• Permission status'),
              SizedBox(height: 16),
              Text(
                '💡 Tips:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('• Check Android logcat for detailed logs'),
              Text('• Ensure notifications are enabled in settings'),
              Text('• Verify exact alarm permission is granted'),
              Text('• Test with a time 1-2 minutes from now'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('About'),
        content: const Text(
          'Medicine Reminder App\n\n'
              'Features:\n'
              '• Daily medicine reminders\n'
              '• Custom scheduling (daily/weekly)\n'
              '• Date range support\n'
              '• Notification history\n'
              '• Background notifications\n'
              '• Data persistence\n\n'
              'All data is stored locally on your device.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}