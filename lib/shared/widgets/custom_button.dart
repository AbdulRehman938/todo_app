import 'package:flutter/material.dart';
import '../../app/constants/app_colors.dart';

enum ButtonType {
  primary,
  secondary,
  outlined,
  text,
}

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final ButtonType buttonType;
  final double? width;
  final double? height;
  final IconData? icon;
  final bool isFullWidth;
  final bool isDisabled;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.buttonType = ButtonType.primary,
    this.width,
    this.height,
    this.icon,
    this.isFullWidth = false,
    this.isDisabled = false,
  });

  @override
  Widget build(BuildContext context) {
    final isEnabled = onPressed != null && !isLoading && !isDisabled;

    Widget buttonChild;
    VoidCallback? handlePress = isEnabled
        ? () {
            print('CustomButton: Button pressed - $text');
            onPressed?.call();
          }
        : null;
    if (isLoading) {
      buttonChild = SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(
            _getTextColor(buttonType),
          ),
        ),
      );
    } else if (icon != null) {
      buttonChild = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 8),
          Text(text),
        ],
      );
    } else {
      buttonChild = Text(text);
    }

    final button = switch (buttonType) {
      ButtonType.primary => ElevatedButton(
          onPressed: handlePress,
          style: _getPrimaryStyle(context),
          child: buttonChild,
        ),
      ButtonType.secondary => ElevatedButton(
          onPressed: handlePress,
          style: _getSecondaryStyle(context),
          child: buttonChild,
        ),
      ButtonType.outlined => OutlinedButton(
          onPressed: handlePress,
          style: _getOutlinedStyle(context),
          child: buttonChild,
        ),
      ButtonType.text => TextButton(
          onPressed: handlePress,
          style: _getTextButtonStyle(context),
          child: buttonChild,
        ),
    };

    if (isFullWidth) {
      return SizedBox(
        width: double.infinity,
        child: button,
      );
    }

    if (width != null || height != null) {
      return SizedBox(
        width: width,
        height: height,
        child: button,
      );
    }

    return button;
  }

  ButtonStyle _getPrimaryStyle(BuildContext context) {
    return ElevatedButton.styleFrom(
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      disabledBackgroundColor: AppColors.textTertiary.withValues(alpha: 0.3),
      disabledForegroundColor: AppColors.textTertiary,
      elevation: 2,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      textStyle: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  ButtonStyle _getSecondaryStyle(BuildContext context) {
    return ElevatedButton.styleFrom(
      backgroundColor: AppColors.secondary,
      foregroundColor: Colors.white,
      disabledBackgroundColor: AppColors.textTertiary.withValues(alpha: 0.3),
      disabledForegroundColor: AppColors.textTertiary,
      elevation: 2,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      textStyle: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  ButtonStyle _getOutlinedStyle(BuildContext context) {
    return OutlinedButton.styleFrom(
      foregroundColor: AppColors.primary,
      disabledForegroundColor: AppColors.textTertiary,
      side: const BorderSide(color: AppColors.primary, width: 1.5),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      textStyle: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  ButtonStyle _getTextButtonStyle(BuildContext context) {
    return TextButton.styleFrom(
      foregroundColor: AppColors.primary,
      disabledForegroundColor: AppColors.textTertiary,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      textStyle: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Color _getTextColor(ButtonType type) {
    switch (type) {
      case ButtonType.primary:
      case ButtonType.secondary:
        return Colors.white;
      case ButtonType.outlined:
      case ButtonType.text:
        return AppColors.primary;
    }
  }
}
