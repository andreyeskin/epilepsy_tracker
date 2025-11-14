import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';

/// Roter FAB mit Warning-Icon
/// Muss auf ALLEN Screens außer Modals sichtbar sein
/// Position: bottom-right, über Bottom Nav
class FloatingEmergencyButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String? tooltip;

  const FloatingEmergencyButton({
    super.key,
    required this.onPressed,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: onPressed,
      backgroundColor: AppColors.error,
      elevation: 6,
      highlightElevation: 8,
      tooltip: tooltip ?? 'Schnelles Anfall-Protokoll',
      child: const Icon(
        Icons.warning,
        color: AppColors.textOnPrimary,
        size: AppDimensions.fabIconSize,
      ),
    );
  }
}

/// Alternative Version mit Puls-Animation (optional)
class FloatingEmergencyButtonAnimated extends StatefulWidget {
  final VoidCallback onPressed;
  final String? tooltip;

  const FloatingEmergencyButtonAnimated({
    super.key,
    required this.onPressed,
    this.tooltip,
  });

  @override
  State<FloatingEmergencyButtonAnimated> createState() =>
      _FloatingEmergencyButtonAnimatedState();
}

class _FloatingEmergencyButtonAnimatedState
    extends State<FloatingEmergencyButtonAnimated>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _animation,
      child: FloatingActionButton(
        onPressed: widget.onPressed,
        backgroundColor: AppColors.error,
        elevation: 6,
        highlightElevation: 8,
        tooltip: widget.tooltip ?? 'Schnelles Anfall-Protokoll',
        child: const Icon(
          Icons.warning,
          color: AppColors.textOnPrimary,
          size: AppDimensions.fabIconSize,
        ),
      ),
    );
  }
}
