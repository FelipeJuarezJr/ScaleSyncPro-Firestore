import 'package:flutter/material.dart';
import '../models/reptile.dart';
import '../models/feeding_log.dart';
import '../models/activity_log.dart';
import '../models/animal_note.dart';
import '../services/reptile_service.dart';
import '../utils/theme.dart';
import '../widgets/animal_detail/detail_section_card.dart';
import '../widgets/animal_detail/add_feeding_modal.dart';
import '../widgets/animal_detail/add_note_modal.dart';
import '../widgets/animal_detail/add_activity_modal.dart';
import '../widgets/animal_detail/edit_reptile_modal.dart';

class AnimalDetailScreen extends StatefulWidget {
  final Reptile reptile;

  const AnimalDetailScreen({super.key, required this.reptile});

  @override
  State<AnimalDetailScreen> createState() => _AnimalDetailScreenState();
}

class _AnimalDetailScreenState extends State<AnimalDetailScreen> {
  late Reptile _reptile;
  final _service = ReptileService();

  bool _showAllFeedings = false;
  bool _showAllActivity = false;
  bool _showAllNotes = false;

  @override
  void initState() {
    super.initState();
    _reptile = widget.reptile;
  }

  // ─── Helpers ────────────────────────────────────────────────────────────

  String _timeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    if (diff.inDays < 30) return '${(diff.inDays / 7).floor()}w ago';
    if (diff.inDays < 365) return '${(diff.inDays / 30).floor()} months ago';
    return '${(diff.inDays / 365).floor()} year(s) ago';
  }

  String _ageLabel() {
    final age = _reptile.age;
    if (age == null) return '—';
    if (age == 0) return '< 1 year';
    return '$age year${age > 1 ? 's' : ''}';
  }

  // ─── Modals ────────────────────────────────────────────────────────────

  void _openEditModal() async {
    final updated = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (_) => EditReptileModal(reptile: _reptile),
    );
    if (updated == true && mounted) {
      // Re-fetch reptile to get fresh data
      final fresh = await _service.getReptile(_reptile.id!);
      if (fresh != null && mounted) setState(() => _reptile = fresh);
    }
  }

  void _openAddFeeding() {
    showDialog(
      context: context,
      builder: (_) => AddFeedingModal(
        reptileId: _reptile.id!,
        onSave: (log) => _service.addFeedingLog(_reptile.id!, log),
      ),
    );
  }

  void _openAddActivity() {
    showDialog(
      context: context,
      builder: (_) => AddActivityModal(
        onSave: (log) => _service.addActivityLog(_reptile.id!, log),
      ),
    );
  }

  void _openAddNote() {
    showDialog(
      context: context,
      builder: (_) => AddNoteModal(
        onSave: (note) => _service.addNote(_reptile.id!, note),
      ),
    );
  }

  void _confirmDeleteReptile() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Animal'),
        content: Text('Are you sure you want to delete ${_reptile.name}? This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _service.deleteReptile(_reptile.id!);
              if (mounted) Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.dangerColor),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // ─── Build ────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.bgPrimary : AppTheme.lightBgSecondary,
      body: Column(
        children: [
          _buildHeader(theme, isDark),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth > 700;
                if (isWide) {
                  return _buildTwoColumnBody(isDark);
                } else {
                  return _buildSingleColumnBody(isDark);
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  // ─── Header ────────────────────────────────────────────────────────────

  Widget _buildHeader(ThemeData theme, bool isDark) {
    final bgColor = isDark ? AppTheme.bgSecondary : AppTheme.lightBgPrimary;
    final borderColor = isDark ? AppTheme.borderColor : AppTheme.lightBorderColor;
    final weight = _reptile.measurements['weight'];
    final weightUnit = _reptile.measurements['weightUnit'] ?? 'gr';
    final length = _reptile.measurements['length'];
    final lengthUnit = _reptile.measurements['lengthUnit'] ?? 'cm';

    return Container(
      color: bgColor,
      child: Column(
        children: [
          // Breadcrumb
          Container(
            color: isDark ? AppTheme.bgTertiary : const Color(0xFFF1F3F4),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                InkWell(
                  onTap: () => Navigator.pop(context),
                  child: Row(
                    children: [
                      Icon(Icons.arrow_back_ios, size: 14,
                          color: isDark ? AppTheme.textSecondary : AppTheme.lightTextSecondary),
                      const SizedBox(width: 4),
                      Text('Animals',
                          style: theme.textTheme.bodySmall?.copyWith(
                              color: isDark ? AppTheme.textSecondary : AppTheme.lightTextSecondary)),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, size: 14,
                    color: isDark ? AppTheme.textLight : AppTheme.lightTextLight),
                Text('Animal details',
                    style: theme.textTheme.bodySmall?.copyWith(
                        color: isDark ? AppTheme.textPrimary : AppTheme.lightTextPrimary,
                        fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          // Animal info row
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Avatar
                ClipRRect(
                  borderRadius: BorderRadius.circular(40),
                  child: Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isDark ? AppTheme.bgTertiary : AppTheme.lightBgTertiary,
                    ),
                    child: _reptile.photoUrls.isNotEmpty
                        ? Image.network(_reptile.photoUrls.first, fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => _avatarPlaceholder(isDark))
                        : _avatarPlaceholder(isDark),
                  ),
                ),
                const SizedBox(width: 16),
                // Name + species
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _reptile.name.toUpperCase(),
                        style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: isDark ? AppTheme.textPrimary : AppTheme.lightTextPrimary),
                      ),
                      Text(
                        _reptile.species,
                        style: theme.textTheme.bodyMedium?.copyWith(
                            color: isDark ? AppTheme.textSecondary : AppTheme.lightTextSecondary),
                      ),
                    ],
                  ),
                ),
                // Stats chips
                Wrap(
                  spacing: 20,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    _statChip(_ageLabel(), 'age', theme, isDark),
                    if (weight != null)
                      _statChip('$weight $weightUnit', 'weight', theme, isDark),
                    if (length != null)
                      _statChip('$length $lengthUnit', 'length', theme, isDark),
                  ],
                ),
                const SizedBox(width: 16),
                // Action buttons
                Row(
                  children: [
                    OutlinedButton.icon(
                      onPressed: _openEditModal,
                      icon: const Icon(Icons.edit_outlined, size: 16),
                      label: const Text('Edit details'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: isDark ? AppTheme.textPrimary : AppTheme.lightTextPrimary,
                        side: BorderSide(
                            color: isDark ? AppTheme.borderColor : AppTheme.lightBorderColor),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                    ),
                    const SizedBox(width: 8),
                    PopupMenuButton<String>(
                      onSelected: (val) {
                        if (val == 'delete') _confirmDeleteReptile();
                      },
                      itemBuilder: (_) => [
                        const PopupMenuItem(value: 'delete', child: Text('Delete animal')),
                      ],
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          border: Border.all(
                              color: isDark ? AppTheme.borderColor : AppTheme.lightBorderColor),
                          borderRadius: BorderRadius.circular(AppTheme.borderRadius),
                        ),
                        child: Icon(Icons.more_vert, size: 18,
                            color: isDark ? AppTheme.textSecondary : AppTheme.lightTextSecondary),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Divider(height: 1, thickness: 1, color: borderColor),
        ],
      ),
    );
  }

  Widget _avatarPlaceholder(bool isDark) {
    return Container(
      color: isDark ? AppTheme.bgTertiary : AppTheme.lightBgTertiary,
      child: Icon(Icons.pets, size: 28,
          color: isDark ? AppTheme.textLight : AppTheme.lightTextLight),
    );
  }

  Widget _statChip(String value, String label, ThemeData theme, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(value,
            style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: isDark ? AppTheme.primaryColor : AppTheme.lightPrimaryColor)),
        Text(label,
            style: theme.textTheme.bodySmall?.copyWith(
                color: isDark ? AppTheme.textLight : AppTheme.lightTextLight)),
      ],
    );
  }

  // ─── Body layouts ──────────────────────────────────────────────────────

  Widget _buildTwoColumnBody(bool isDark) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 5,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildFeedingSection(),
                const SizedBox(height: 16),
                _buildHistorySection(),
              ],
            ),
          ),
        ),
        VerticalDivider(
          width: 1,
          thickness: 1,
          color: isDark ? AppTheme.borderColor : AppTheme.lightBorderColor,
        ),
        Expanded(
          flex: 4,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildNotesSection(),
                const SizedBox(height: 16),
                _buildPhotosSection(),
                const SizedBox(height: 16),
                _buildFilesSection(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSingleColumnBody(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildFeedingSection(),
          const SizedBox(height: 16),
          _buildHistorySection(),
          const SizedBox(height: 16),
          _buildNotesSection(),
          const SizedBox(height: 16),
          _buildPhotosSection(),
          const SizedBox(height: 16),
          _buildFilesSection(),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // ─── Section widgets ──────────────────────────────────────────────────

  Widget _buildFeedingSection() {
    return StreamBuilder<List<FeedingLog>>(
      stream: _service.watchFeedingLogs(_reptile.id!),
      builder: (context, snapshot) {
        final theme = Theme.of(context);
        final isDark = theme.brightness == Brightness.dark;
        final logs = snapshot.data ?? [];
        final visibleLogs = _showAllFeedings ? logs : logs.take(3).toList();

        return DetailSectionCard(
          title: 'Feeding',
          onSettings: () {},
          onAdd: _openAddFeeding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (snapshot.connectionState == ConnectionState.waiting && logs.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (logs.isEmpty)
                _emptyMessage('No feeding logs yet. Tap + to log a feeding.', isDark, theme)
              else
                ...visibleLogs.map((log) => _feedingTile(log, isDark, theme)).toList(),
              if (logs.length > 3)
                _showMoreButton(
                  _showAllFeedings ? 'SHOW LESS' : 'SHOW ALL HISTORY',
                  () => setState(() => _showAllFeedings = !_showAllFeedings),
                  isDark, theme,
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _feedingTile(FeedingLog log, bool isDark, ThemeData theme) {
    final borderColor = isDark ? AppTheme.borderColor : AppTheme.lightBorderColor;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: borderColor, width: 0.5)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(log.summary,
                    style: theme.textTheme.bodyMedium?.copyWith(
                        color: isDark ? AppTheme.textPrimary : AppTheme.lightTextPrimary)),
                if (log.supplements.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(log.supplements.join(', '),
                      style: theme.textTheme.bodySmall?.copyWith(
                          color: isDark ? AppTheme.textLight : AppTheme.lightTextLight)),
                ],
              ],
            ),
          ),
          Text(_timeAgo(log.feedingDate),
              style: theme.textTheme.bodySmall?.copyWith(
                  color: isDark ? AppTheme.textLight : AppTheme.lightTextLight)),
        ],
      ),
    );
  }

  Widget _buildHistorySection() {
    return StreamBuilder<List<ActivityLog>>(
      stream: _service.watchActivityLogs(_reptile.id!),
      builder: (context, snapshot) {
        final theme = Theme.of(context);
        final isDark = theme.brightness == Brightness.dark;
        final logs = snapshot.data ?? [];
        final visibleLogs = _showAllActivity ? logs : logs.take(5).toList();

        return DetailSectionCard(
          title: 'History',
          onSettings: () {},
          onAdd: _openAddActivity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (snapshot.connectionState == ConnectionState.waiting && logs.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (logs.isEmpty)
                _emptyMessage('No activity logged yet. Tap + to add an entry.', isDark, theme)
              else
                ...visibleLogs.map((log) => _activityTile(log, isDark, theme)).toList(),
              if (logs.length > 5)
                _showMoreButton(
                  _showAllActivity ? 'SHOW LESS' : 'SHOW ALL HISTORY',
                  () => setState(() => _showAllActivity = !_showAllActivity),
                  isDark, theme,
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _activityTile(ActivityLog log, bool isDark, ThemeData theme) {
    final borderColor = isDark ? AppTheme.borderColor : AppTheme.lightBorderColor;
    final icon = _activityIcon(log.type);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: borderColor, width: 0.5)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 14,
              color: isDark ? AppTheme.textLight : AppTheme.lightTextLight),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(log.event,
                    style: theme.textTheme.bodyMedium?.copyWith(
                        color: isDark ? AppTheme.textPrimary : AppTheme.lightTextPrimary)),
                if (log.detail != null)
                  Text(log.detail!,
                      style: theme.textTheme.bodySmall?.copyWith(
                          color: isDark ? AppTheme.textSecondary : AppTheme.lightTextSecondary)),
              ],
            ),
          ),
          Text(_timeAgo(log.logDate),
              style: theme.textTheme.bodySmall?.copyWith(
                  color: isDark ? AppTheme.textLight : AppTheme.lightTextLight)),
        ],
      ),
    );
  }

  IconData _activityIcon(String type) {
    switch (type) {
      case 'feeding': return Icons.restaurant;
      case 'weight_change': return Icons.scale;
      case 'length_change': return Icons.straighten;
      case 'note': return Icons.note;
      case 'photo': return Icons.photo;
      default: return Icons.circle_outlined;
    }
  }

  Widget _buildNotesSection() {
    return StreamBuilder<List<AnimalNote>>(
      stream: _service.watchNotes(_reptile.id!),
      builder: (context, snapshot) {
        final theme = Theme.of(context);
        final isDark = theme.brightness == Brightness.dark;
        final notes = snapshot.data ?? [];
        final visibleNotes = _showAllNotes ? notes : notes.take(3).toList();

        return DetailSectionCard(
          title: 'Notes',
          onAdd: _openAddNote,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (snapshot.connectionState == ConnectionState.waiting && notes.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (notes.isEmpty)
                _emptyMessage('No notes yet. Tap + to add a note.', isDark, theme)
              else
                ...visibleNotes.map((note) => _noteTile(note, isDark, theme)).toList(),
              if (notes.length > 3)
                _showMoreButton(
                  _showAllNotes ? 'SHOW LESS' : 'SHOW ALL NOTES',
                  () => setState(() => _showAllNotes = !_showAllNotes),
                  isDark, theme,
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _noteTile(AnimalNote note, bool isDark, ThemeData theme) {
    final borderColor = isDark ? AppTheme.borderColor : AppTheme.lightBorderColor;
    return Dismissible(
      key: Key(note.id ?? note.createdAt.toIso8601String()),
      direction: DismissDirection.endToStart,
      background: Container(
        color: AppTheme.dangerColor.withOpacity(0.15),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        child: const Icon(Icons.delete_outline, color: AppTheme.dangerColor),
      ),
      onDismissed: (_) => _service.deleteNote(_reptile.id!, note.id!),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: borderColor, width: 0.5)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(note.content,
                  style: theme.textTheme.bodyMedium?.copyWith(
                      color: isDark ? AppTheme.textPrimary : AppTheme.lightTextPrimary)),
            ),
            const SizedBox(width: 12),
            Text(_timeAgo(note.createdAt),
                style: theme.textTheme.bodySmall?.copyWith(
                    color: isDark ? AppTheme.textLight : AppTheme.lightTextLight)),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotosSection() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final photos = _reptile.photoUrls;

    return DetailSectionCard(
      title: 'Photos',
      onEdit: () {},
      onAdd: () {},
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: photos.isEmpty
            ? _emptyMessage('You haven\'t uploaded any photos yet.', isDark, theme,
                inline: true)
            : GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: 1,
                ),
                itemCount: photos.length,
                itemBuilder: (_, i) => ClipRRect(
                  borderRadius: BorderRadius.circular(AppTheme.borderRadius),
                  child: Image.network(photos[i], fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                            color: isDark ? AppTheme.bgTertiary : AppTheme.lightBgTertiary,
                            child: const Icon(Icons.broken_image_outlined),
                          )),
                ),
              ),
      ),
    );
  }

  Widget _buildFilesSection() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return DetailSectionCard(
      title: 'Files',
      onAdd: () {},
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: _emptyMessage('You haven\'t uploaded any files yet.', isDark, theme,
            inline: true),
      ),
    );
  }

  // ─── Shared UI ────────────────────────────────────────────────────────

  Widget _emptyMessage(String msg, bool isDark, ThemeData theme, {bool inline = false}) {
    final w = Padding(
      padding: EdgeInsets.all(inline ? 0 : 16),
      child: Text(msg,
          style: theme.textTheme.bodySmall?.copyWith(
              color: isDark ? AppTheme.textLight : AppTheme.lightTextLight)),
    );
    return inline ? w : w;
  }

  Widget _showMoreButton(
      String label, VoidCallback onTap, bool isDark, ThemeData theme) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: isDark ? AppTheme.primaryColor : AppTheme.lightPrimaryColor,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(width: 4),
            Icon(Icons.chevron_right, size: 14,
                color: isDark ? AppTheme.primaryColor : AppTheme.lightPrimaryColor),
          ],
        ),
      ),
    );
  }
}
