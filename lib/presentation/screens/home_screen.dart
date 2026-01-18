import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/medicine_provider.dart';
import '../widgets/medicine_card.dart';
import '../widgets/empty_state.dart';
import 'add_medicine_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final medicinesAsync = ref.watch(medicineListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Medicine Reminder'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showAboutDialog(context),
          ),
        ],
      ),

      body: medicinesAsync.when(
        /// ---------------- DATA ----------------
        data: (medicines) {
          // Defensive: ensure non-null list
          if (medicines.isEmpty) {
            return const EmptyState();
          }

          // Sort medicines by time (earlier first)
          medicines.sort(
                (a, b) => a.time.compareTo(b.time),
          );

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
                      content: Text('${medicine.name} deleted'),
                      backgroundColor: Colors.red,
                    ),
                  );
                },
              );
            },
          );
        },

        /// ---------------- LOADING ----------------
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),

        /// ---------------- ERROR ----------------
        error: (_, __) => const Center(
          child: Text(
            'Something went wrong.\nPlease restart the app.',
            textAlign: TextAlign.center,
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

  /// ---------------- ABOUT DIALOG ----------------
  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('About'),
        content: const Text(
          'Medicine Reminder App\n\n'
              'This app helps you remember to take your medicines on time. '
              'Add your daily medicines and get notified at the scheduled time.',
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
