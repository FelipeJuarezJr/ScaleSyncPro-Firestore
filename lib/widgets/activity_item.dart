import 'package:flutter/material.dart';
import '../utils/theme.dart';

class ActivityItem extends StatefulWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String description;
  final String time;

  const ActivityItem({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.description,
    required this.time,
  });

  @override
  State<ActivityItem> createState() => _ActivityItemState();
}

class _ActivityItemState extends State<ActivityItem> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.ease,
        decoration: BoxDecoration(
          color: isHovered ? const Color(0xFF373737) : AppTheme.bgSecondary, // RGB(55,55,55) = #373737
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.all(15),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: widget.iconColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                widget.icon,
                color: Colors.white,
                size: 16,
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.description,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.time,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.textLight,
                      fontSize: 10,
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