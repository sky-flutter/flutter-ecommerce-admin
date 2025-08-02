import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';

/// Custom button widget with consistent styling
class CustomButton extends StatelessWidget {
  /// The text to display on the button
  final String text;

  /// Callback function when button is pressed
  final VoidCallback? onPressed;

  /// Whether the button is in loading state
  final bool isLoading;

  /// The type of button
  final ButtonType type;

  /// Whether the button is full width
  final bool isFullWidth;

  /// Custom icon to display
  final IconData? icon;

  /// Whether the button is disabled
  final bool isDisabled;

  /// Custom text style
  final TextStyle? textStyle;

  /// Custom padding
  final EdgeInsetsGeometry? padding;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.type = ButtonType.primary,
    this.isFullWidth = false,
    this.icon,
    this.isDisabled = false,
    this.textStyle,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: isFullWidth ? double.infinity : null,
      child: ElevatedButton(
        onPressed: (isDisabled || isLoading) ? null : onPressed,
        style: _getButtonStyle(context),
        child: _buildButtonContent(),
      ),
    );
  }

  /// Builds the button content
  Widget _buildButtonContent() {
    if (isLoading) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                _getTextColor(),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'Loading...',
            style: _getTextStyle(),
          ),
        ],
      );
    }

    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: 8),
          Text(text, style: _getTextStyle()),
        ],
      );
    }

    return Text(text, style: _getTextStyle());
  }

  /// Gets the button style based on type
  ButtonStyle _getButtonStyle(BuildContext context) {
    return ElevatedButton.styleFrom(
      backgroundColor: _getBackgroundColor(),
      foregroundColor: _getTextColor(),
      padding: padding ??
          const EdgeInsets.symmetric(
            horizontal: AppConstants.defaultPadding,
            vertical: 12,
          ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
      ),
      elevation: _getElevation(),
    );
  }

  /// Gets the background color based on button type
  Color _getBackgroundColor() {
    switch (type) {
      case ButtonType.primary:
        return Colors.blue;
      case ButtonType.secondary:
        return Colors.grey[200]!;
      case ButtonType.success:
        return Colors.green;
      case ButtonType.danger:
        return Colors.red;
      case ButtonType.warning:
        return Colors.orange;
    }
  }

  /// Gets the text color based on button type
  Color _getTextColor() {
    switch (type) {
      case ButtonType.primary:
      case ButtonType.success:
      case ButtonType.danger:
      case ButtonType.warning:
        return Colors.white;
      case ButtonType.secondary:
        return Colors.black87;
    }
  }

  /// Gets the elevation based on button type
  double _getElevation() {
    switch (type) {
      case ButtonType.primary:
      case ButtonType.success:
      case ButtonType.danger:
      case ButtonType.warning:
        return AppConstants.defaultElevation;
      case ButtonType.secondary:
        return 0;
    }
  }

  /// Gets the text style
  TextStyle _getTextStyle() {
    return textStyle ??
        TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: _getTextColor(),
        );
  }
}

/// Enum for button types
enum ButtonType {
  primary,
  secondary,
  success,
  danger,
  warning,
}
