import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../theme/app_theme.dart';

/// Unified animated app button with gradient styles *or* a flat color override.
///
/// - Use [style] for theme presets (primary/secondary/...).
/// - Pass [color] to override background with a flat color (ignores gradient).
/// - Pass [textColor] to override foreground.
class SportButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final SportButtonStyle style;
  final IconData? icon;
  final double? width;
  final double? height;

  /// Flat background color override. When provided, gradient styles are skipped.
  final Color? color;

  /// Text/icon/spinner color override.
  final Color? textColor;

  const SportButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.style = SportButtonStyle.primary,
    this.icon,
    this.width,
    this.height,
    this.color,
    this.textColor,
  });

  @override
  State<SportButton> createState() => _SportButtonState();
}

class _SportButtonState extends State<SportButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) => _animationController.forward();
  void _onTapUp(TapUpDetails details) => _animationController.reverse();
  void _onTapCancel() => _animationController.reverse();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final effectiveWidth = widget.width ?? double.infinity;
    final fgColor = widget.textColor ?? _getTextColor(widget.style, isDark);

    return GestureDetector(
      onTapDown:
          widget.onPressed != null && !widget.isLoading ? _onTapDown : null,
      onTapUp: widget.onPressed != null && !widget.isLoading ? _onTapUp : null,
      onTapCancel:
          widget.onPressed != null && !widget.isLoading ? _onTapCancel : null,
      onTap:
          widget.onPressed != null && !widget.isLoading
              ? widget.onPressed
              : null,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              width: effectiveWidth,
              height: widget.height ?? 56,
              decoration: _getButtonDecoration(
                widget.style,
                isDark,
                widget.color,
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(AppTheme.borderRadius),
                  onTap:
                      widget.onPressed != null && !widget.isLoading
                          ? widget.onPressed
                          : null,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (widget.icon != null && !widget.isLoading) ...[
                          Icon(widget.icon, color: fgColor, size: 20),
                          const SizedBox(width: 8),
                        ],
                        if (widget.isLoading)
                          SpinKitCircle(color: fgColor, size: 24)
                        else
                          Text(
                            widget.text,
                            style: AppTheme.buttonText.copyWith(color: fgColor),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  BoxDecoration _getButtonDecoration(
    SportButtonStyle style,
    bool isDark,
    Color? overrideColor,
  ) {
    if (overrideColor != null) {
      // Flat color override.
      return BoxDecoration(
        color: overrideColor,
        borderRadius: BorderRadius.circular(AppTheme.borderRadius),
        boxShadow: [
          BoxShadow(
            color: overrideColor.withOpacity(0.4),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      );
    }

    // Use themed styles
    switch (style) {
      case SportButtonStyle.primary:
        return BoxDecoration(
          gradient: AppTheme.primaryGradient,
          borderRadius: BorderRadius.circular(AppTheme.borderRadius),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryColor.withOpacity(0.4),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        );
      case SportButtonStyle.secondary:
        return BoxDecoration(
          gradient: AppTheme.secondaryGradient,
          borderRadius: BorderRadius.circular(AppTheme.borderRadius),
          boxShadow: [
            BoxShadow(
              color: AppTheme.secondaryColor.withOpacity(0.4),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        );
      case SportButtonStyle.accent:
        return BoxDecoration(
          gradient: AppTheme.accentGradient,
          borderRadius: BorderRadius.circular(AppTheme.borderRadius),
          boxShadow: [
            BoxShadow(
              color: AppTheme.accentColor.withOpacity(0.4),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        );
      case SportButtonStyle.outline:
        return BoxDecoration(
          border: Border.all(color: AppTheme.primaryColor, width: 2),
          borderRadius: BorderRadius.circular(AppTheme.borderRadius),
          color: Colors.transparent,
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryColor.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        );
      case SportButtonStyle.ghost:
        return BoxDecoration(
          borderRadius: BorderRadius.circular(AppTheme.borderRadius),
          color:
              isDark
                  ? AppTheme.darkCard.withOpacity(0.6)
                  : AppTheme.lightCard.withOpacity(0.6),
          boxShadow: [
            BoxShadow(
              color:
                  isDark
                      ? Colors.black.withOpacity(0.2)
                      : Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        );
    }
  }

  Color _getTextColor(SportButtonStyle style, bool isDark) {
    switch (style) {
      case SportButtonStyle.primary:
      case SportButtonStyle.secondary:
      case SportButtonStyle.accent:
        return Colors.white;
      case SportButtonStyle.outline:
        return AppTheme.primaryColor;
      case SportButtonStyle.ghost:
        return isDark ? AppTheme.darkText : AppTheme.lightText;
    }
  }
}

enum SportButtonStyle { primary, secondary, accent, outline, ghost }
