import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/medicine_provider.dart';

class AddMedicineScreen extends ConsumerStatefulWidget {
  const AddMedicineScreen({super.key});

  @override
  ConsumerState<AddMedicineScreen> createState() => _AddMedicineScreenState();
}

class _AddMedicineScreenState extends ConsumerState<AddMedicineScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _doseController = TextEditingController();
  final _notesController = TextEditingController();

  TimeOfDay? _selectedTime;
  DateTime _startDate = DateTime.now();
  DateTime? _endDate;
  String _frequency = 'daily';
  List<int> _selectedDays = [];
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _doseController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  bool get _isFormValid {
    return _nameController.text.trim().isNotEmpty &&
        _doseController.text.trim().isNotEmpty &&
        _selectedTime != null &&
        (_frequency != 'weekly' || _selectedDays.isNotEmpty);
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() => _selectedTime = picked);
    }
  }

  Future<void> _selectStartDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _startDate = picked);
    }
  }

  Future<void> _selectEndDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _endDate ?? _startDate.add(const Duration(days: 7)),
      firstDate: _startDate,
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _endDate = picked);
    }
  }

  void _clearEndDate() {
    setState(() => _endDate = null);
  }

  Future<void> _saveMedicine() async {
    if (!_formKey.currentState!.validate() || !_isFormValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all required fields'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final scheduledTime = DateTime(
        _startDate.year,
        _startDate.month,
        _startDate.day,
        _selectedTime!.hour,
        _selectedTime!.minute,
      );

      final actions = ref.read(medicineActionsProvider);
      await actions.addMedicine(
        name: _nameController.text.trim(),
        dose: _doseController.text.trim(),
        time: scheduledTime,
        startDate: _startDate,
        endDate: _endDate,
        frequency: _frequency,
        customDays: _frequency == 'weekly' ? _selectedDays : null,
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${_nameController.text} added successfully'),
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM dd, yyyy');

    return Scaffold(
      appBar: AppBar(title: const Text('Add Medicine')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Medicine Name
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Medicine Name *',
                  hintText: 'e.g., Aspirin',
                  prefixIcon: Icon(Icons.medication),
                ),
                textCapitalization: TextCapitalization.words,
                validator: (v) => v?.trim().isEmpty ?? true
                    ? 'Required' : null,
                onChanged: (_) => setState(() {}),
              ),

              const SizedBox(height: 16),

              // Dose
              TextFormField(
                controller: _doseController,
                decoration: const InputDecoration(
                  labelText: 'Dose *',
                  hintText: 'e.g., 1 tablet, 5ml',
                  prefixIcon: Icon(Icons.local_pharmacy),
                ),
                validator: (v) => v?.trim().isEmpty ?? true
                    ? 'Required' : null,
                onChanged: (_) => setState(() {}),
              ),

              const SizedBox(height: 16),

              // Time Picker
              _buildTimePicker(),

              const SizedBox(height: 16),

              // Start Date
              _buildDatePicker(
                label: 'Start Date *',
                date: _startDate,
                onTap: _selectStartDate,
              ),

              const SizedBox(height: 16),

              // End Date
              _buildEndDatePicker(dateFormat),

              const SizedBox(height: 16),

              // Frequency Selection
              _buildFrequencySelector(),

              // Weekly Days Selector
              if (_frequency == 'weekly') ...[
                const SizedBox(height: 16),
                _buildWeekdaySelector(),
              ],

              const SizedBox(height: 16),

              // Notes (Optional)
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Notes (Optional)',
                  hintText: 'e.g., Take with food',
                  prefixIcon: Icon(Icons.note),
                ),
                maxLines: 2,
              ),

              const SizedBox(height: 24),

              // Save Button
              ElevatedButton(
                onPressed: _isFormValid && !_isLoading ? _saveMedicine : null,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading
                    ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
                    : const Text('Save Medicine'),
              ),

              const SizedBox(height: 16),

              // Info Card
              _buildInfoCard(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimePicker() {
    return InkWell(
      onTap: _selectTime,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(Icons.access_time,
                color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Reminder Time *',
                      style: Theme.of(context).textTheme.bodySmall),
                  const SizedBox(height: 4),
                  Text(
                    _selectedTime?.format(context) ?? 'Select time',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: _selectedTime != null
                          ? Colors.black87
                          : Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }

  Widget _buildDatePicker({
    required String label,
    required DateTime date,
    required VoidCallback onTap,
  }) {
    final dateFormat = DateFormat('MMM dd, yyyy');
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today,
                color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: Theme.of(context).textTheme.bodySmall),
                  const SizedBox(height: 4),
                  Text(dateFormat.format(date),
                      style: Theme.of(context).textTheme.titleMedium),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }

  Widget _buildEndDatePicker(DateFormat dateFormat) {
    return InkWell(
      onTap: _selectEndDate,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(Icons.event,
                color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('End Date (Optional)',
                      style: Theme.of(context).textTheme.bodySmall),
                  const SizedBox(height: 4),
                  Text(
                    _endDate != null
                        ? dateFormat.format(_endDate!)
                        : 'Continuous (No end date)',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: _endDate != null
                          ? Colors.black87
                          : Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),
            if (_endDate != null)
              IconButton(
                icon: const Icon(Icons.clear, size: 20),
                onPressed: _clearEndDate,
                color: Colors.grey[600],
              )
            else
              Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }

  Widget _buildFrequencySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Frequency *',
            style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: [
            ChoiceChip(
              label: const Text('Daily'),
              selected: _frequency == 'daily',
              onSelected: (selected) {
                if (selected) setState(() => _frequency = 'daily');
              },
            ),
            ChoiceChip(
              label: const Text('Specific Days'),
              selected: _frequency == 'weekly',
              onSelected: (selected) {
                if (selected) setState(() => _frequency = 'weekly');
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildWeekdaySelector() {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Select Days *',
            style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: List.generate(7, (index) {
            final dayNum = index + 1;
            return FilterChip(
              label: Text(days[index]),
              selected: _selectedDays.contains(dayNum),
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _selectedDays.add(dayNum);
                  } else {
                    _selectedDays.remove(dayNum);
                  }
                });
              },
            );
          }),
        ),
        if (_frequency == 'weekly' && _selectedDays.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text('Please select at least one day',
                style: TextStyle(color: Colors.red[700], fontSize: 12)),
          ),
      ],
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline,
              color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '• Reminders will be sent daily at the selected time\n'
                  '• Start date: When reminders begin\n'
                  '• End date: When reminders stop (optional)\n'
                  '• Works even when app is closed',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}