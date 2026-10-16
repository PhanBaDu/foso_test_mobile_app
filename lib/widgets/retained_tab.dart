import 'package:flutter/material.dart';

/// Fades cached tab surfaces without recreating their controllers or scroll state.
class RetainedTab extends StatefulWidget {
  const RetainedTab({super.key, required this.active, required this.child});

  final bool active;
  final Widget child;

  @override
  State<RetainedTab> createState() => _RetainedTabState();
}

class _RetainedTabState extends State<RetainedTab>
    with SingleTickerProviderStateMixin {
  late final _opacity = AnimationController(
    vsync: this,
    value: widget.active ? 1 : 0,
    duration: const Duration(milliseconds: 120),
  );
  late final _fade = CurvedAnimation(
    parent: _opacity,
    curve: Curves.easeOut,
    reverseCurve: Curves.easeIn,
  );
  bool _reduceMotion = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _reduceMotion = MediaQuery.disableAnimationsOf(context);
    if (_reduceMotion) _opacity.value = widget.active ? 1 : 0;
  }

  @override
  void didUpdateWidget(RetainedTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.active == oldWidget.active) return;
    if (_reduceMotion) {
      _opacity.value = widget.active ? 1 : 0;
    } else if (widget.active) {
      _opacity.forward();
    } else {
      _opacity.reverse();
    }
  }

  @override
  void dispose() {
    _fade.dispose();
    _opacity.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _opacity,
    child: IgnorePointer(
      ignoring: !widget.active,
      child: ExcludeSemantics(
        excluding: !widget.active,
        child: TickerMode(
          enabled: widget.active,
          child: RepaintBoundary(child: widget.child),
        ),
      ),
    ),
    builder: (context, child) => Offstage(
      offstage: !widget.active && _opacity.isDismissed,
      child: FadeTransition(opacity: _fade, child: child),
    ),
  );
}
