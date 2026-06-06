import 'package:flutter/material.dart';
import '../utils/theme.dart';

class StatCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final String value;
  final String change;
  final bool? isPositive; // null for neutral, true for positive, false for negative

  const StatCard({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
    required this.change,
    this.isPositive,
  });

  @override
  State<StatCard> createState() => _StatCardState();
}

class _StatCardState extends State<StatCard> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobileBrowser = screenWidth <= 768;
    final isMediumScreen = screenWidth > 768 && screenWidth <= 1486;
    
    return MouseRegion(
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.ease,
        decoration: BoxDecoration(
          color: AppTheme.bgPrimary,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: const Color(0x4D000000), // rgba(0,0,0,0.3)
              offset: Offset(0, isHovered ? 4 : 2),
              blurRadius: isHovered ? 8 : 4,
            ),
          ],
        ),
        transform: isHovered ? Matrix4.translationValues(0, -2, 0) : Matrix4.identity(),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: isMobileBrowser ? 12 : (isMediumScreen ? 16 : 20), 
            vertical: isMobileBrowser ? 16 : (isMediumScreen ? 20 : 24)
          ),
          child: Row(
            children: [
              // Icon container on the left
              Container(
                width: isMobileBrowser ? 40 : (isMediumScreen ? 50 : 60),
                height: isMobileBrowser ? 40 : (isMediumScreen ? 50 : 60),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(isMobileBrowser ? 20 : (isMediumScreen ? 25 : 30)),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppTheme.primaryColor,
                      AppTheme.primaryLight,
                    ],
                  ),
                ),
                child: Icon(
                  widget.icon,
                  color: Colors.white,
                  size: isMobileBrowser ? 18 : (isMediumScreen ? 22 : 24),
                ),
              ),
              SizedBox(width: isMobileBrowser ? 12 : (isMediumScreen ? 16 : 20)),
              // Content on the right
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      widget.title,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.textSecondary,
                        fontWeight: FontWeight.w500,
                        fontSize: isMobileBrowser ? 11 : (isMediumScreen ? 13 : 14.4),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: isMobileBrowser ? 2 : (isMediumScreen ? 3 : 4)),
                    Text(
                      widget.value,
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: isMobileBrowser ? 20 : (isMediumScreen ? 26 : 32),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: isMobileBrowser ? 2 : (isMediumScreen ? 3 : 4)),
                    Text(
                      widget.change,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: widget.isPositive == null 
                            ? AppTheme.textSecondary
                            : widget.isPositive! 
                                ? AppTheme.successColor 
                                : AppTheme.dangerColor,
                        fontSize: isMobileBrowser ? 10 : (isMediumScreen ? 12 : 12.8),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

 