import 'package:flutter/material.dart';
import '../../utils/theme.dart';

/// Reusable section card used throughout the Animal Detail screen.
/// Renders a titled card with optional action buttons (gear, pencil, +).
class DetailSectionCard extends StatelessWidget {
  final String title;
  final Widget child;
  final VoidCallback? onAdd;
  final VoidCallback? onSettings;
  final VoidCallback? onEdit;
  final Widget? trailing;

  const DetailSectionCard({
    super.key,
    required this.title,
    required this.child,
    this.onAdd,
    this.onSettings,
    this.onEdit,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cardColor = isDark ? AppTheme.bgSecondary : AppTheme.lightBgPrimary;
    final borderColor = isDark ? AppTheme.borderColor : AppTheme.lightBorderColor;

    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusLg),
        border: Border.all(color: borderColor, width: 1),
        boxShadow: isDark ? [] : AppTheme.shadowSm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    title.toUpperCase(),
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.8,
                      color: isDark ? AppTheme.textSecondary : AppTheme.lightTextSecondary,
                    ),
                  ),
                ),
                if (trailing != null) trailing!,
                if (onSettings != null) ...[
                  const SizedBox(width: 4),
                  _HeaderIcon(icon: Icons.settings, onTap: onSettings!, isDark: isDark),
                ],
                if (onEdit != null) ...[
                  const SizedBox(width: 4),
                  _HeaderIcon(icon: Icons.edit_outlined, onTap: onEdit!, isDark: isDark),
                ],
                if (onAdd != null) ...[
                  const SizedBox(width: 4),
                  _HeaderIcon(icon: Icons.add, onTap: onAdd!, isDark: isDark, accent: true),
                ],
              ],
            ),
          ),
          Divider(height: 1, thickness: 1, color: borderColor),
          child,
        ],
      ),
    );
  }
}

class _HeaderIcon extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool isDark;
  final bool accent;

  const _HeaderIcon({
    required this.icon,
    required this.onTap,
    required this.isDark,
    this.accent = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = accent
        ? (isDark ? AppTheme.primaryColor : AppTheme.lightPrimaryColor)
        : (isDark ? AppTheme.textSecondary : AppTheme.lightTextSecondary);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Icon(icon, size: 18, color: color),
      ),
    );
  }
}
