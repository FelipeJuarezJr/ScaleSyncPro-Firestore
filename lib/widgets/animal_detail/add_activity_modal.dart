import 'package:flutter/material.dart';
import '../../models/activity_log.dart';
import '../../utils/theme.dart';

class AddActivityModal extends StatefulWidget {
  final Future<void> Function(ActivityLog) onSave;
  const AddActivityModal({super.key, required this.onSave});

  @override
  State<AddActivityModal> createState() => _AddActivityModalState();
}

class _AddActivityModalState extends State<AddActivityModal> {
  final _eventController = TextEditingController();
  final _detailController = TextEditingController();
  String? _selectedPreset;
  DateTime _logDate = DateTime.now();
  bool _isSaving = false;

  static const List<String> _presets = [
    'Took a bath',
    'Water changed',
    'Breeding observed',
    'Shed started',
    'Shed completed',
    'Health check',
    'Vet visit',
    'Custom event',
  ];

  @override
  void dispose() {
    _eventController.dispose();
    _detailController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _logDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );
    if (picked != null) setState(() => _logDate = picked);
  }

  Future<void> _save() async {
    final event = _selectedPreset == 'Custom event' || _selectedPreset == null
        ? _eventController.text.trim()
        : _selectedPreset!;
    if (event.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter or select an event')),
      );
      return;
    }
    setState(() => _isSaving = true);
    try {
      await widget.onSave(ActivityLog(
        event: event,
        detail: _detailController.text.trim().isNotEmpty ? _detailController.text.trim() : null,
        type: 'manual',
        logDate: _logDate,
      ));
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: AppTheme.dangerColor),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final headerBg = isDark ? AppTheme.bgPrimary : const Color(0xFF2C5530);
    final showCustom = _selectedPreset == 'Custom event' || _selectedPreset == null;

    return Dialog(
      backgroundColor: isDark ? AppTheme.bgSecondary : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.borderRadiusLg)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 60),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 480),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              decoration: BoxDecoration(
                color: headerBg,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(AppTheme.borderRadiusLg),
                  topRight: Radius.circular(AppTheme.borderRadiusLg),
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              child: Row(
                children: [
                  const Icon(Icons.history, color: Colors.white, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text('Log Activity',
                        style: theme.textTheme.titleLarge?.copyWith(
                            color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                  IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.pop(context)),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Date
                  Text('Date',
                      style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isDark ? AppTheme.textSecondary : AppTheme.lightTextSecondary)),
                  const SizedBox(height: 6),
                  InkWell(
                    onTap: _pickDate,
                    borderRadius: BorderRadius.circular(AppTheme.borderRadius),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      decoration: BoxDecoration(
                        color: isDark ? AppTheme.bgTertiary : AppTheme.lightBgSecondary,
                        borderRadius: BorderRadius.circular(AppTheme.borderRadius),
                        border: Border.all(color: isDark ? AppTheme.borderColor : AppTheme.lightBorderColor),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.calendar_today, size: 16,
                              color: isDark ? AppTheme.textSecondary : AppTheme.lightTextSecondary),
                          const SizedBox(width: 8),
                          Text('${_logDate.day}/${_logDate.month}/${_logDate.year}',
                              style: theme.textTheme.bodyMedium),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Event preset
                  Text('Event',
                      style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isDark ? AppTheme.textSecondary : AppTheme.lightTextSecondary)),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: _presets.map((p) {
                      final selected = _selectedPreset == p;
                      return ChoiceChip(
                        label: Text(p, style: const TextStyle(fontSize: 12)),
                        selected: selected,
                        onSelected: (_) => setState(() {
                          _selectedPreset = p;
                          if (p != 'Custom event') _eventController.text = p;
                        }),
                        selectedColor:
                            (isDark ? AppTheme.primaryColor : AppTheme.lightPrimaryColor).withOpacity(0.2),
                        checkmarkColor: isDark ? AppTheme.primaryColor : AppTheme.lightPrimaryColor,
                      );
                    }).toList(),
                  ),
                  if (showCustom) ...[
                    const SizedBox(height: 12),
                    TextField(
                      controller: _eventController,
                      autofocus: _selectedPreset == 'Custom event',
                      decoration: const InputDecoration(hintText: 'Describe the event...'),
                    ),
                  ],
                  const SizedBox(height: 12),
                  TextField(
                    controller: _detailController,
                    decoration: const InputDecoration(hintText: 'Additional detail (optional)'),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : _save,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isDark ? AppTheme.primaryColor : const Color(0xFF2C5530),
                        foregroundColor: isDark ? Colors.black : Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppTheme.borderRadius)),
                      ),
                      child: _isSaving
                          ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2))
                          : const Text('Save Activity', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
