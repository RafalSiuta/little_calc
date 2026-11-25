import 'package:flutter/material.dart';

const _completionDuration = Duration(milliseconds: 200);

class EquationAfterEquals extends StatefulWidget {
  const EquationAfterEquals({
    super.key,
    required this.equation,
    required this.completedCalculations,
    required this.builder,
    this.flexible = false,
  });

  final String equation;
  final int completedCalculations;
  final Widget Function(String equation) builder;
  final bool flexible;

  @override
  State<EquationAfterEquals> createState() => _EquationAfterEqualsState();
}

class _EquationAfterEqualsState extends State<EquationAfterEquals>
    with SingleTickerProviderStateMixin {
  late final AnimationController _opacity = AnimationController(
    vsync: this,
    duration: _completionDuration,
    value: 1,
  )..addStatusListener(_onStatusChanged);
  late final Animation<double> _fade = _opacity.drive(
    CurveTween(curve: Curves.easeInOut),
  );
  String? _fadingEquation;

  @override
  void didUpdateWidget(EquationAfterEquals oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.equation.isNotEmpty) {
      _fadingEquation = null;
      if (_opacity.value != 1) _opacity.value = 1;
    } else if (oldWidget.equation.isNotEmpty &&
        widget.completedCalculations != oldWidget.completedCalculations &&
        !MediaQuery.disableAnimationsOf(context)) {
      _fadingEquation = oldWidget.equation;
      _opacity.reverse(from: 1);
    }
  }

  void _onStatusChanged(AnimationStatus status) {
    if (status == AnimationStatus.dismissed && _fadingEquation != null) {
      setState(() => _fadingEquation = null);
    }
  }

  @override
  void dispose() {
    _opacity.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final equation = _fadingEquation ?? widget.equation;
    final child = widget.builder(equation);
    if (equation.isEmpty) return child;

    final display = FadeTransition(
      opacity: _fade,
      child: ExcludeSemantics(
        excluding: _fadingEquation != null,
        child: IgnorePointer(
          ignoring: _fadingEquation != null,
          child: TickerMode(enabled: _fadingEquation == null, child: child),
        ),
      ),
    );
    return widget.flexible ? Flexible(child: display) : display;
  }
}

class ResultAfterEquals extends StatefulWidget {
  const ResultAfterEquals({
    super.key,
    required this.completedCalculations,
    required this.child,
  });

  final int completedCalculations;
  final Widget child;

  @override
  State<ResultAfterEquals> createState() => _ResultAfterEqualsState();
}

class _ResultAfterEqualsState extends State<ResultAfterEquals>
    with SingleTickerProviderStateMixin {
  late final AnimationController _progress = AnimationController(
    vsync: this,
    duration: _completionDuration,
    value: 1,
  );
  late final Animation<double> _scale = _progress
      .drive(CurveTween(curve: Curves.easeOutCubic))
      .drive(Tween<double>(begin: 0.90, end: 1));

  @override
  void didUpdateWidget(ResultAfterEquals oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.completedCalculations != oldWidget.completedCalculations &&
        !MediaQuery.disableAnimationsOf(context)) {
      _progress.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _progress.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ScaleTransition(
    scale: _scale,
    alignment: Alignment.centerRight,
    child: widget.child,
  );
}
