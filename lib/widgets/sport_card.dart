import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class SportCard extends StatefulWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? width;
  final double? height;
  final VoidCallback? onTap;
  final bool showShadow;
  final bool showBorder;
  final Color? backgroundColor;
  final double borderRadius;
  final SportCardStyle style;

  const SportCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.onTap,
    this.showShadow = true,
    this.showBorder = false,
    this.backgroundColor,
    this.borderRadius = AppTheme.borderRadius,
    this.style = SportCardStyle.elevated,
  });

  @override
  State<SportCard> createState() => _SportCardState();
}

class _SportCardState extends State<SportCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _elevationAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.98).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _elevationAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    if (widget.onTap != null) {
      _animationController.forward();
    }
  }

  void _onTapUp(TapUpDetails details) {
    if (widget.onTap != null) {
      _animationController.reverse();
    }
  }

  void _onTapCancel() {
    if (widget.onTap != null) {
      _animationController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            width: widget.width,
            height: widget.height,
            margin: widget.margin,
            decoration: _getCardDecoration(isDark),
            child: Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(widget.borderRadius),
              child: InkWell(
                borderRadius: BorderRadius.circular(widget.borderRadius),
                onTap: widget.onTap,
                onTapDown: _onTapDown,
                onTapUp: _onTapUp,
                onTapCancel: _onTapCancel,
                child: Container(
                  padding: widget.padding ?? const EdgeInsets.all(16),
                  child: widget.child,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  BoxDecoration _getCardDecoration(bool isDark) {
    Color backgroundColor =
        widget.backgroundColor ??
        (isDark ? AppTheme.darkCard : AppTheme.lightCard);

    List<BoxShadow>? shadows;
    if (widget.showShadow && widget.style == SportCardStyle.elevated) {
      shadows = [
        BoxShadow(
          color:
              isDark
                  ? Colors.black.withOpacity(0.3)
                  : Colors.black.withOpacity(0.1),
          blurRadius: 8 + (_elevationAnimation.value * 4),
          offset: Offset(0, 2 + (_elevationAnimation.value * 2)),
        ),
      ];
    }

    Border? border;
    if (widget.showBorder || widget.style == SportCardStyle.outlined) {
      border = Border.all(
        color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
        width: 1,
      );
    }

    switch (widget.style) {
      case SportCardStyle.elevated:
        return BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(widget.borderRadius),
          boxShadow: shadows,
          border: border,
        );
      case SportCardStyle.outlined:
        return BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(widget.borderRadius),
          border: Border.all(
            color: AppTheme.primaryColor.withOpacity(0.3),
            width: 1,
          ),
        );
      case SportCardStyle.filled:
        return BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(widget.borderRadius),
        );
      case SportCardStyle.gradient:
        return BoxDecoration(
          gradient: AppTheme.primaryGradient,
          borderRadius: BorderRadius.circular(widget.borderRadius),
          boxShadow: shadows,
        );
      case SportCardStyle.glassmorphism:
        return AppTheme.glassmorphismDecoration(
          radius: widget.borderRadius,
          isDark: isDark,
        );
    }
  }
}

enum SportCardStyle { elevated, outlined, filled, gradient, glassmorphism }
