import 'package:flutter/material.dart';
import '../../core/constants/app_theme.dart';
import 'material_card.dart';

/// Modern Material 3 dashboard card with statistics
class DashboardCard extends StatelessWidget {
  final String title;
  final String value;
  final String? subtitle;
  final IconData icon;
  final Color? iconColor;
  final Color? backgroundColor;
  final VoidCallback? onTap;
  final bool isLoading;
  final bool isPositive;
  final String? changeText;
  final double? changePercentage;

  const DashboardCard({
    super.key,
    required this.title,
    required this.value,
    this.subtitle,
    required this.icon,
    this.iconColor,
    this.backgroundColor,
    this.onTap,
    this.isLoading = false,
    this.isPositive = true,
    this.changeText,
    this.changePercentage,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return InteractiveMaterialCard(
      onTap: onTap,
      backgroundColor: backgroundColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppTheme.spacing12),
                decoration: BoxDecoration(
                  color: iconColor ?? colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(AppTheme.radius12),
                ),
                child: Icon(
                  icon,
                  color: iconColor ?? colorScheme.onPrimaryContainer,
                  size: 24,
                ),
              ),
              const Spacer(),
              if (changePercentage != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.spacing8,
                    vertical: AppTheme.spacing4,
                  ),
                  decoration: BoxDecoration(
                    color: isPositive
                        ? AppTheme.successColor.withValues(alpha: 0.1)
                        : AppTheme.errorColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppTheme.radius8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isPositive ? Icons.trending_up : Icons.trending_down,
                        size: 12,
                        color: isPositive
                            ? AppTheme.successColor
                            : AppTheme.errorColor,
                      ),
                      const SizedBox(width: AppTheme.spacing4),
                      Text(
                        '${isPositive ? '+' : ''}${changePercentage!.toStringAsFixed(1)}%',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: isPositive
                              ? AppTheme.successColor
                              : AppTheme.errorColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppTheme.spacing16),
          if (isLoading)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 24,
                  width: 120,
                  decoration: BoxDecoration(
                    color: colorScheme.onSurface.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppTheme.radius4),
                  ),
                ),
                const SizedBox(height: AppTheme.spacing8),
                Container(
                  height: 16,
                  width: 80,
                  decoration: BoxDecoration(
                    color: colorScheme.onSurface.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppTheme.radius4),
                  ),
                ),
              ],
            )
          else
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: AppTheme.spacing4),
                Text(
                  title,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: AppTheme.spacing4),
                  Text(
                    subtitle!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color:
                          colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                    ),
                  ),
                ],
                if (changeText != null) ...[
                  const SizedBox(height: AppTheme.spacing8),
                  Text(
                    changeText!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: isPositive
                          ? AppTheme.successColor
                          : AppTheme.errorColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
        ],
      ),
    );
  }
}

/// Modern Material 3 chart card
class ChartCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget chart;
  final List<Widget>? actions;
  final VoidCallback? onTap;

  const ChartCard({
    super.key,
    required this.title,
    this.subtitle,
    required this.chart,
    this.actions,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return MaterialCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: AppTheme.spacing4),
                      Text(
                        subtitle!,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (actions != null) ...[
                const SizedBox(width: AppTheme.spacing16),
                ...actions!,
              ],
            ],
          ),
          const SizedBox(height: AppTheme.spacing24),
          SizedBox(
            height: 300,
            child: chart,
          ),
        ],
      ),
    );
  }
}

/// Modern Material 3 activity card
class ActivityCard extends StatelessWidget {
  final String title;
  final String description;
  final DateTime timestamp;
  final IconData icon;
  final Color? iconColor;
  final VoidCallback? onTap;

  const ActivityCard({
    super.key,
    required this.title,
    required this.description,
    required this.timestamp,
    required this.icon,
    this.iconColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return MaterialCard(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppTheme.spacing12),
            decoration: BoxDecoration(
              color: iconColor ?? colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(AppTheme.radius12),
            ),
            child: Icon(
              icon,
              color: iconColor ?? colorScheme.onPrimaryContainer,
              size: 20,
            ),
          ),
          const SizedBox(width: AppTheme.spacing16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: AppTheme.spacing4),
                Text(
                  description,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: AppTheme.spacing8),
                Text(
                  _formatTimestamp(timestamp),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
    } else {
      return 'Just now';
    }
  }
}

/// Modern Material 3 quick action card
class QuickActionCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final Color? iconColor;
  final Color? backgroundColor;
  final VoidCallback? onTap;

  const QuickActionCard({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    this.iconColor,
    this.backgroundColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return InteractiveMaterialCard(
      onTap: onTap,
      backgroundColor: backgroundColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(AppTheme.spacing16),
            decoration: BoxDecoration(
              color: iconColor ?? colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(AppTheme.radius16),
            ),
            child: Icon(
              icon,
              color: iconColor ?? colorScheme.onPrimaryContainer,
              size: 32,
            ),
          ),
          const SizedBox(height: AppTheme.spacing16),
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: AppTheme.spacing4),
          Text(
            description,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
