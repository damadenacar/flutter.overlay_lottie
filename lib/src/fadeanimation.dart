import 'package:flutter/widgets.dart';

/// This is a class to control the fade in animation for an arbitrary widget. It is inspired in the example in https://api.flutter.dev/flutter/widgets/FadeTransition-class.html
class FadeAnimation extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final bool fadeIn;
  const FadeAnimation({required this.child, this.duration = const Duration(milliseconds: 200), this.fadeIn = true, super.key});

  @override
  State<FadeAnimation> createState() => _FadeAnimationState();
}

class _FadeAnimationState extends State<FadeAnimation>
    with SingleTickerProviderStateMixin {
  
  late final AnimationController _controller = AnimationController(
    duration: widget.duration,
    vsync: this,
  );

  late final Animation<double> _animation = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeIn,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.fadeIn) {
      _controller.forward();
    } else {
      _controller.reverse(from: _controller.upperBound);
    }
    return FadeTransition(
      opacity: _animation,
      child: widget.child,
    );
  }
}
