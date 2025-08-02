import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/constants/app_constants.dart';

/// Custom text field widget with consistent styling
class CustomTextField extends StatefulWidget {
  /// The label text for the field
  final String label;

  /// The hint text for the field
  final String? hint;

  /// The initial value of the field
  final String? initialValue;

  /// Callback function when text changes
  final ValueChanged<String>? onChanged;

  /// Callback function when field is submitted
  final ValueChanged<String>? onSubmitted;

  /// Whether the field is required
  final bool isRequired;

  /// Whether the field is enabled
  final bool isEnabled;

  /// Whether the field is read-only
  final bool isReadOnly;

  /// Whether to obscure the text (for passwords)
  final bool isObscure;

  /// The type of keyboard to show
  final TextInputType? keyboardType;

  /// The maximum number of lines
  final int? maxLines;

  /// The maximum number of characters
  final int? maxLength;

  /// Custom validator function
  final String? Function(String?)? validator;

  /// Custom prefix icon
  final IconData? prefixIcon;

  /// Custom suffix icon
  final IconData? suffixIcon;

  /// Callback for suffix icon tap
  final VoidCallback? onSuffixIconTap;

  /// Custom text input formatters
  final List<TextInputFormatter>? inputFormatters;

  /// Custom text style
  final TextStyle? textStyle;

  /// Custom label style
  final TextStyle? labelStyle;

  /// Custom hint style
  final TextStyle? hintStyle;

  /// Custom decoration
  final InputDecoration? decoration;

  const CustomTextField({
    super.key,
    required this.label,
    this.hint,
    this.initialValue,
    this.onChanged,
    this.onSubmitted,
    this.isRequired = false,
    this.isEnabled = true,
    this.isReadOnly = false,
    this.isObscure = false,
    this.keyboardType,
    this.maxLines = 1,
    this.maxLength,
    this.validator,
    this.prefixIcon,
    this.suffixIcon,
    this.onSuffixIconTap,
    this.inputFormatters,
    this.textStyle,
    this.labelStyle,
    this.hintStyle,
    this.decoration,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  bool _isObscured = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
    _focusNode = FocusNode();
    _isObscured = widget.isObscure;
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: _controller,
      focusNode: _focusNode,
      enabled: widget.isEnabled,
      readOnly: widget.isReadOnly,
      obscureText: _isObscured,
      keyboardType: widget.keyboardType,
      maxLines: widget.maxLines,
      maxLength: widget.maxLength,
      onChanged: widget.onChanged,
      onFieldSubmitted: widget.onSubmitted,
      validator: widget.validator ?? _defaultValidator,
      inputFormatters: widget.inputFormatters,
      style: widget.textStyle,
      decoration: widget.decoration ?? _buildDecoration(),
    );
  }

  /// Builds the default decoration
  InputDecoration _buildDecoration() {
    return InputDecoration(
      labelText: widget.isRequired ? '${widget.label} *' : widget.label,
      hintText: widget.hint,
      prefixIcon: widget.prefixIcon != null
          ? Icon(widget.prefixIcon, color: Colors.grey[600])
          : null,
      suffixIcon: _buildSuffixIcon(),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
        borderSide: BorderSide(color: Colors.blue, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
        borderSide: BorderSide(color: Colors.red),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
        borderSide: BorderSide(color: Colors.red, width: 2),
      ),
      labelStyle: widget.labelStyle,
      hintStyle: widget.hintStyle,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppConstants.defaultPadding,
        vertical: 12,
      ),
    );
  }

  /// Builds the suffix icon
  Widget? _buildSuffixIcon() {
    if (widget.isObscure) {
      return IconButton(
        icon: Icon(
          _isObscured ? Icons.visibility : Icons.visibility_off,
          color: Colors.grey[600],
        ),
        onPressed: () {
          setState(() {
            _isObscured = !_isObscured;
          });
        },
      );
    }

    if (widget.suffixIcon != null) {
      return IconButton(
        icon: Icon(widget.suffixIcon, color: Colors.grey[600]),
        onPressed: widget.onSuffixIconTap,
      );
    }

    return null;
  }

  /// Default validator function
  String? _defaultValidator(String? value) {
    if (widget.isRequired && (value == null || value.isEmpty)) {
      return '${widget.label} is required';
    }

    if (widget.keyboardType == TextInputType.emailAddress && value != null) {
      if (!_isValidEmail(value)) {
        return 'Please enter a valid email address';
      }
    }

    if (widget.maxLength != null &&
        value != null &&
        value.length > widget.maxLength!) {
      return '${widget.label} cannot exceed ${widget.maxLength} characters';
    }

    return null;
  }

  /// Validates email format
  bool _isValidEmail(String email) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }
}
