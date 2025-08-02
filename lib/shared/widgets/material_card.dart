import 'package:flutter/material.dart';
import '../../core/constants/app_theme.dart';

/// Modern Material 3 card widget with enhanced styling
class MaterialCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? elevation;
  final Color? backgroundColor;
  final BorderRadius? borderRadius;
  final VoidCallback? onTap;
  final bool isInteractive;
  final bool showShadow;

  const MaterialCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.elevation,
    this.backgroundColor,
    this.borderRadius,
    this.onTap,
    this.isInteractive = false,
    this.showShadow = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: margin ?? const EdgeInsets.all(AppTheme.spacing16),
      child: Material(
        color: backgroundColor ?? colorScheme.surface,
        elevation: showShadow ? (elevation ?? 1) : 0,
        shadowColor: AppTheme.neutral900.withValues(alpha: 0.1),
        borderRadius: borderRadius ?? BorderRadius.circular(AppTheme.radius16),
        child: InkWell(
          onTap: onTap,
          borderRadius:
              borderRadius ?? BorderRadius.circular(AppTheme.radius16),
          splashColor: colorScheme.primary.withValues(alpha: 0.1),
          highlightColor: colorScheme.primary.withValues(alpha: 0.05),
          child: Container(
            padding: padding ?? const EdgeInsets.all(AppTheme.spacing20),
            decoration: BoxDecoration(
              borderRadius:
                  borderRadius ?? BorderRadius.circular(AppTheme.radius16),
              border: Border.all(
                color: colorScheme.outline.withValues(alpha: 0.1),
                width: 1,
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

/// Elevated card with more prominent styling
class ElevatedMaterialCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? backgroundColor;
  final BorderRadius? borderRadius;
  final VoidCallback? onTap;

  const ElevatedMaterialCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.backgroundColor,
    this.borderRadius,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialCard(
      padding: padding,
      margin: margin,
      backgroundColor: backgroundColor,
      borderRadius: borderRadius,
      onTap: onTap,
      elevation: 4,
      showShadow: true,
      child: child,
    );
  }
}

/// Outlined card with border styling
class OutlinedMaterialCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? borderColor;
  final BorderRadius? borderRadius;
  final VoidCallback? onTap;

  const OutlinedMaterialCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.borderColor,
    this.borderRadius,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: margin ?? const EdgeInsets.all(AppTheme.spacing16),
      child: Material(
        color: colorScheme.surface,
        elevation: 0,
        borderRadius: borderRadius ?? BorderRadius.circular(AppTheme.radius16),
        child: InkWell(
          onTap: onTap,
          borderRadius:
              borderRadius ?? BorderRadius.circular(AppTheme.radius16),
          splashColor: colorScheme.primary.withValues(alpha: 0.1),
          highlightColor: colorScheme.primary.withValues(alpha: 0.05),
          child: Container(
            padding: padding ?? const EdgeInsets.all(AppTheme.spacing20),
            decoration: BoxDecoration(
              borderRadius:
                  borderRadius ?? BorderRadius.circular(AppTheme.radius16),
              border: Border.all(
                color: borderColor ?? colorScheme.outline,
                width: 1.5,
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

/// Interactive card with hover effects
class InteractiveMaterialCard extends StatefulWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? backgroundColor;
  final BorderRadius? borderRadius;
  final VoidCallback? onTap;
  final bool isSelected;

  const InteractiveMaterialCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.backgroundColor,
    this.borderRadius,
    this.onTap,
    this.isSelected = false,
  });

  @override
  State<InteractiveMaterialCard> createState() =>
      _InteractiveMaterialCardState();
}

class _InteractiveMaterialCardState extends State<InteractiveMaterialCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.02,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onHover(bool isHovered) {
    setState(() {
      _isHovered = isHovered;
    });
    if (isHovered) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return MouseRegion(
      onEnter: (_) => _onHover(true),
      onExit: (_) => _onHover(false),
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              margin: widget.margin ?? const EdgeInsets.all(AppTheme.spacing16),
              child: Material(
                color: widget.isSelected
                    ? colorScheme.primaryContainer
                    : widget.backgroundColor ?? colorScheme.surface,
                elevation: _isHovered ? 8 : 2,
                shadowColor: AppTheme.neutral900.withValues(alpha: 0.15),
                borderRadius: widget.borderRadius ??
                    BorderRadius.circular(AppTheme.radius16),
                child: InkWell(
                  onTap: widget.onTap,
                  borderRadius: widget.borderRadius ??
                      BorderRadius.circular(AppTheme.radius16),
                  splashColor: colorScheme.primary.withValues(alpha: 0.1),
                  highlightColor: colorScheme.primary.withValues(alpha: 0.05),
                  child: Container(
                    padding: widget.padding ??
                        const EdgeInsets.all(AppTheme.spacing20),
                    decoration: BoxDecoration(
                      borderRadius: widget.borderRadius ??
                          BorderRadius.circular(AppTheme.radius16),
                      border: widget.isSelected
                          ? Border.all(
                              color: colorScheme.primary,
                              width: 2,
                            )
                          : Border.all(
                              color: colorScheme.outline.withValues(alpha: 0.1),
                              width: 1,
                            ),
                    ),
                    child: widget.child,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
