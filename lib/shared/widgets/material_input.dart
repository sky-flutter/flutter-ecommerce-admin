import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/constants/app_theme.dart';

/// Modern Material 3 text input field
class MaterialInput extends StatelessWidget {
  final String? label;
  final String? hint;
  final String? helperText;
  final String? errorText;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final bool obscureText;
  final bool enabled;
  final bool readOnly;
  final int? maxLines;
  final int? maxLength;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final VoidCallback? onTap;
  final ValueChanged<String>? onChanged;
  final FormFieldValidator<String>? validator;
  final List<TextInputFormatter>? inputFormatters;
  final FocusNode? focusNode;
  final TextInputAction? textInputAction;
  final VoidCallback? onEditingComplete;
  final ValueChanged<String>? onFieldSubmitted;
  final bool autofocus;
  final bool autocorrect;
  final bool enableSuggestions;
  final bool expands;
  final TextAlign textAlign;
  final TextAlignVertical textAlignVertical;
  final EdgeInsetsGeometry? contentPadding;
  final Color? fillColor;
  final BorderRadius? borderRadius;

  const MaterialInput({
    super.key,
    this.label,
    this.hint,
    this.helperText,
    this.errorText,
    this.controller,
    this.keyboardType,
    this.obscureText = false,
    this.enabled = true,
    this.readOnly = false,
    this.maxLines = 1,
    this.maxLength,
    this.prefixIcon,
    this.suffixIcon,
    this.onTap,
    this.onChanged,
    this.validator,
    this.inputFormatters,
    this.focusNode,
    this.textInputAction,
    this.onEditingComplete,
    this.onFieldSubmitted,
    this.autofocus = false,
    this.autocorrect = true,
    this.enableSuggestions = true,
    this.expands = false,
    this.textAlign = TextAlign.start,
    this.textAlignVertical = TextAlignVertical.center,
    this.contentPadding,
    this.fillColor,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      enabled: enabled,
      readOnly: readOnly,
      maxLines: maxLines,
      maxLength: maxLength,
      onTap: onTap,
      onChanged: onChanged,
      validator: validator,
      inputFormatters: inputFormatters,
      focusNode: focusNode,
      textInputAction: textInputAction,
      onEditingComplete: onEditingComplete,
      onFieldSubmitted: onFieldSubmitted,
      autofocus: autofocus,
      autocorrect: autocorrect,
      enableSuggestions: enableSuggestions,
      expands: expands,
      textAlign: textAlign,
      textAlignVertical: textAlignVertical,
      style: theme.textTheme.bodyLarge?.copyWith(
        color: enabled
            ? colorScheme.onSurface
            : colorScheme.onSurface.withValues(alpha: 0.6),
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        helperText: helperText,
        errorText: errorText,
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: fillColor ?? colorScheme.surfaceVariant,
        contentPadding: contentPadding ??
            const EdgeInsets.symmetric(
              horizontal: AppTheme.spacing16,
              vertical: AppTheme.spacing12,
            ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
              borderRadius?.resolve(TextDirection.ltr).topLeft.x ??
                  AppTheme.radius12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
              borderRadius?.resolve(TextDirection.ltr).topLeft.x ??
                  AppTheme.radius12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
              borderRadius?.resolve(TextDirection.ltr).topLeft.x ??
                  AppTheme.radius12),
          borderSide: BorderSide(
            color: colorScheme.primary,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
              borderRadius?.resolve(TextDirection.ltr).topLeft.x ??
                  AppTheme.radius12),
          borderSide: BorderSide(
            color: colorScheme.error,
            width: 2,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
              borderRadius?.resolve(TextDirection.ltr).topLeft.x ??
                  AppTheme.radius12),
          borderSide: BorderSide(
            color: colorScheme.error,
            width: 2,
          ),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
              borderRadius?.resolve(TextDirection.ltr).topLeft.x ??
                  AppTheme.radius12),
          borderSide: BorderSide.none,
        ),
        labelStyle: theme.textTheme.bodyMedium?.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
        hintStyle: theme.textTheme.bodyMedium?.copyWith(
          color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
        ),
        helperStyle: theme.textTheme.bodySmall?.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
        errorStyle: theme.textTheme.bodySmall?.copyWith(
          color: colorScheme.error,
        ),
        counterStyle: theme.textTheme.bodySmall?.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

/// Search input field with Material 3 styling
class MaterialSearchInput extends StatefulWidget {
  final String? hint;
  final String? label;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onClear;
  final VoidCallback? onSearch;
  final bool showClearButton;
  final bool showSearchButton;
  final FocusNode? focusNode;
  final TextInputAction? textInputAction;

  const MaterialSearchInput({
    super.key,
    this.hint,
    this.label,
    this.controller,
    this.onChanged,
    this.onClear,
    this.onSearch,
    this.showClearButton = true,
    this.showSearchButton = true,
    this.focusNode,
    this.textInputAction,
  });

  @override
  State<MaterialSearchInput> createState() => _MaterialSearchInputState();
}

class _MaterialSearchInputState extends State<MaterialSearchInput> {
  late TextEditingController _controller;
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  void _onTextChanged() {
    setState(() {
      _hasText = _controller.text.isNotEmpty;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return MaterialInput(
      controller: _controller,
      label: widget.label,
      hint: widget.hint ?? 'Search...',
      onChanged: widget.onChanged,
      focusNode: widget.focusNode,
      textInputAction: widget.textInputAction ?? TextInputAction.search,
      onFieldSubmitted: (_) => widget.onSearch?.call(),
      prefixIcon: Icon(
        Icons.search,
        color: colorScheme.onSurfaceVariant,
        size: 20,
      ),
      suffixIcon: _buildSuffixIcon(colorScheme),
    );
  }

  Widget? _buildSuffixIcon(ColorScheme colorScheme) {
    if (!widget.showClearButton && !widget.showSearchButton) {
      return null;
    }

    if (_hasText && widget.showClearButton) {
      return IconButton(
        onPressed: () {
          _controller.clear();
          widget.onClear?.call();
        },
        icon: Icon(
          Icons.clear,
          color: colorScheme.onSurfaceVariant,
          size: 20,
        ),
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(
          minWidth: 40,
          minHeight: 40,
        ),
      );
    }

    if (widget.showSearchButton) {
      return IconButton(
        onPressed: widget.onSearch,
        icon: Icon(
          Icons.search,
          color: colorScheme.primary,
          size: 20,
        ),
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(
          minWidth: 40,
          minHeight: 40,
        ),
      );
    }

    return null;
  }
}

/// Password input field with Material 3 styling
class MaterialPasswordInput extends StatefulWidget {
  final String? label;
  final String? hint;
  final String? helperText;
  final String? errorText;
  final TextEditingController? controller;
  final bool enabled;
  final bool readOnly;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onChanged;
  final FocusNode? focusNode;
  final TextInputAction? textInputAction;
  final VoidCallback? onEditingComplete;
  final ValueChanged<String>? onFieldSubmitted;
  final bool autofocus;

  const MaterialPasswordInput({
    super.key,
    this.label,
    this.hint,
    this.helperText,
    this.errorText,
    this.controller,
    this.enabled = true,
    this.readOnly = false,
    this.validator,
    this.onChanged,
    this.focusNode,
    this.textInputAction,
    this.onEditingComplete,
    this.onFieldSubmitted,
    this.autofocus = false,
  });

  @override
  State<MaterialPasswordInput> createState() => _MaterialPasswordInputState();
}

class _MaterialPasswordInputState extends State<MaterialPasswordInput> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return MaterialInput(
      label: widget.label,
      hint: widget.hint,
      helperText: widget.helperText,
      errorText: widget.errorText,
      controller: widget.controller,
      keyboardType: TextInputType.visiblePassword,
      obscureText: _obscureText,
      enabled: widget.enabled,
      readOnly: widget.readOnly,
      validator: widget.validator,
      onChanged: widget.onChanged,
      focusNode: widget.focusNode,
      textInputAction: widget.textInputAction,
      onEditingComplete: widget.onEditingComplete,
      onFieldSubmitted: widget.onFieldSubmitted,
      autofocus: widget.autofocus,
      prefixIcon: Icon(
        Icons.lock_outline,
        color: colorScheme.onSurfaceVariant,
        size: 20,
      ),
      suffixIcon: IconButton(
        onPressed: () {
          setState(() {
            _obscureText = !_obscureText;
          });
        },
        icon: Icon(
          _obscureText
              ? Icons.visibility_outlined
              : Icons.visibility_off_outlined,
          color: colorScheme.onSurfaceVariant,
          size: 20,
        ),
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(
          minWidth: 40,
          minHeight: 40,
        ),
      ),
    );
  }
}

/// Number input field with Material 3 styling
class MaterialNumberInput extends StatelessWidget {
  final String? label;
  final String? hint;
  final String? helperText;
  final String? errorText;
  final TextEditingController? controller;
  final bool enabled;
  final bool readOnly;
  final int? maxLength;
  final double? minValue;
  final double? maxValue;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onChanged;
  final FocusNode? focusNode;
  final TextInputAction? textInputAction;
  final VoidCallback? onEditingComplete;
  final ValueChanged<String>? onFieldSubmitted;
  final bool autofocus;
  final Widget? prefixIcon;
  final Widget? suffixIcon;

  const MaterialNumberInput({
    super.key,
    this.label,
    this.hint,
    this.helperText,
    this.errorText,
    this.controller,
    this.enabled = true,
    this.readOnly = false,
    this.maxLength,
    this.minValue,
    this.maxValue,
    this.validator,
    this.onChanged,
    this.focusNode,
    this.textInputAction,
    this.onEditingComplete,
    this.onFieldSubmitted,
    this.autofocus = false,
    this.prefixIcon,
    this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialInput(
      label: label,
      hint: hint,
      helperText: helperText,
      errorText: errorText,
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      enabled: enabled,
      readOnly: readOnly,
      maxLength: maxLength,
      validator: validator ?? _numberValidator,
      onChanged: onChanged,
      focusNode: focusNode,
      textInputAction: textInputAction,
      onEditingComplete: onEditingComplete,
      onFieldSubmitted: onFieldSubmitted,
      autofocus: autofocus,
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
      ],
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
    );
  }

  String? _numberValidator(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }

    final number = double.tryParse(value);
    if (number == null) {
      return 'Please enter a valid number';
    }

    if (minValue != null && number < minValue!) {
      return 'Value must be at least $minValue';
    }

    if (maxValue != null && number > maxValue!) {
      return 'Value must be at most $maxValue';
    }

    return null;
  }
}
