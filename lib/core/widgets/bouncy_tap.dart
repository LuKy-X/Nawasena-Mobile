import 'package:flutter/material.dart';

class BouncyTap extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double scaleFactor;
  final bool enabled;

  const BouncyTap({
    super.key,
    required this.child,
    this.onTap,
    this.scaleFactor = 0.93,
    this.enabled = true,
  });

  @override
  State<BouncyTap> createState() => _BouncyTapState();
}

class _BouncyTapState extends State<BouncyTap>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double>   _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _anim = Tween<double>(begin: 1.0, end: widget.scaleFactor).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  void _down(_) { if (widget.enabled) _ctrl.forward(); }
  void _up(_)   { _ctrl.reverse(); widget.onTap?.call(); }
  void _cancel(){ _ctrl.reverse(); }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _down,
      onTapUp:   _up,
      onTapCancel: _cancel,
      child: AnimatedBuilder(
        animation: _anim,
        builder: (_, child) => Transform.scale(scale: _anim.value, child: child),
        child: widget.child,
      ),
    );
  }
}
