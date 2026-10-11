import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../app/constants/app_colors.dart';

class CustomTextField extends StatefulWidget {
  final String? label;
  final String? hint;
  final String? initialValue;
  final TextEditingController? controller;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final bool isPassword;
  final bool isEmail;
  final bool isNumber;
  final bool isPhone;
  final bool readOnly;
  final int maxLines;
  final int? maxLength;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final void Function(String?)? onSaved;
  final void Function()? onTap;
  final TextInputAction? textInputAction;
  final void Function()? onEditingComplete;
  final FocusNode? focusNode;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final bool enabled;
  final String? errorText;

  const CustomTextField({
    super.key,
    this.label,
    this.hint,
    this.initialValue,
    this.controller,
    this.prefixIcon,
    this.suffixIcon,
    this.isPassword = false,
    this.isEmail = false,
    this.isNumber = false,
    this.isPhone = false,
    this.readOnly = false,
    this.maxLines = 1,
    this.maxLength,
    this.validator,
    this.onChanged,
    this.onSaved,
    this.onTap,
    this.textInputAction,
    this.onEditingComplete,
    this.focusNode,
    this.keyboardType,
    this.inputFormatters,
    this.enabled = true,
    this.errorText,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool _obscureText = true;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.isPassword;
  }

  void _toggleObscureText() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  TextInputType _getKeyboardType() {
    if (widget.keyboardType != null) return widget.keyboardType!;
    if (widget.isEmail) return TextInputType.emailAddress;
    if (widget.isNumber) return TextInputType.number;
    if (widget.isPhone) return TextInputType.phone;
    if (widget.maxLines > 1) return TextInputType.multiline;
    return TextInputType.text;
  }

  List<TextInputFormatter> _getInputFormatters() {
    final formatters = <TextInputFormatter>[];
    if (widget.inputFormatters != null) {
      formatters.addAll(widget.inputFormatters!);
    }
    if (widget.isNumber) {
      formatters.add(FilteringTextInputFormatter.digitsOnly);
    }
    if (widget.isPhone) {
      formatters.add(FilteringTextInputFormatter.digitsOnly);
    }
    return formatters;
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: widget.enabled
                      ? (isDarkMode
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimary)
                      : AppColors.textTertiary,
                ),
          ),
          const SizedBox(height: 8),
        ],
        TextFormField(
          controller: widget.controller,
          initialValue: widget.initialValue,
          obscureText: widget.isPassword ? _obscureText : false,
          readOnly: widget.readOnly,
          maxLines: widget.isPassword ? 1 : widget.maxLines,
          maxLength: widget.maxLength,
          validator: widget.validator,
          onChanged: widget.onChanged,
          onSaved: widget.onSaved,
          onTap: widget.onTap,
          textInputAction: widget.textInputAction,
          onEditingComplete: widget.onEditingComplete,
          focusNode: widget.focusNode,
          keyboardType: _getKeyboardType(),
          inputFormatters: _getInputFormatters(),
          enabled: widget.enabled,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: isDarkMode
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimary,
              ),
          decoration: InputDecoration(
            hintText: widget.hint,
            filled: true,
            fillColor: widget.enabled
                ? (isDarkMode
                    ? AppColors.surfaceVariantDark
                    : AppColors.surfaceVariant)
                : AppColors.textTertiary.withValues(alpha: 0.1),
            prefixIcon: widget.prefixIcon != null
                ? Icon(
                    widget.prefixIcon,
                    color: widget.enabled
                        ? AppColors.textSecondary
                        : AppColors.textTertiary,
                  )
                : null,
            suffixIcon: _buildSuffixIcon(),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.error, width: 2),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.error, width: 2),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AppColors.border.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            counterText: widget.maxLength != null ? null : '',
          ),
        ),
        if (widget.errorText != null) ...[
          const SizedBox(height: 4),
          Text(
            widget.errorText!,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.error,
                ),
          ),
        ],
      ],
    );
  }

  Widget? _buildSuffixIcon() {
    if (widget.isPassword) {
      return IconButton(
        icon: Icon(
          _obscureText ? Icons.visibility_outlined : Icons.visibility_off_outlined,
          color: AppColors.textSecondary,
        ),
        onPressed: _toggleObscureText,
      );
    }
    if (widget.suffixIcon != null) {
      return Icon(
        widget.suffixIcon,
        color: AppColors.textSecondary,
      );
    }
    return null;
  }
}
