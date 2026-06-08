import 'package:flutter/material.dart';
import '../../models/animal_note.dart';
import '../../utils/theme.dart';

class AddNoteModal extends StatefulWidget {
  final Future<void> Function(AnimalNote) onSave;
  const AddNoteModal({super.key, required this.onSave});

  @override
  State<AddNoteModal> createState() => _AddNoteModalState();
}

class _AddNoteModalState extends State<AddNoteModal> {
  final _controller = TextEditingController();
  bool _isSaving = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    setState(() => _isSaving = true);
    try {
      await widget.onSave(AnimalNote(content: text, createdAt: DateTime.now()));
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
    return Dialog(
      backgroundColor: isDark ? AppTheme.bgSecondary : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.borderRadiusLg)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 80),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 460),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.sticky_note_2_outlined,
                    color: isDark ? AppTheme.primaryColor : AppTheme.lightPrimaryColor),
                const SizedBox(width: 10),
                Expanded(
                  child: Text('Add Note',
                      style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                ),
                IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _controller,
              autofocus: true,
              maxLines: 5,
              decoration: const InputDecoration(hintText: 'Write your note here...'),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _isSaving ? null : _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDark ? AppTheme.primaryColor : const Color(0xFF2C5530),
                    foregroundColor: isDark ? Colors.black : Colors.white,
                  ),
                  child: _isSaving
                      ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Text('Save Note'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
