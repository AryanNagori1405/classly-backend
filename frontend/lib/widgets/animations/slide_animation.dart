import 'package:flutter/material.dart';

enum SlideDirection { fromLeft, fromRight, fromTop, fromBottom }

class SlideAnimation extends StatefulWidget {
  final Widget child;
  final SlideDirection direction;
  final Duration duration;
  final Curve curve;
  final double offset;

  const SlideAnimation({
    Key? key,
    required this.child,
    this.direction = SlideDirection.fromBottom,
    this.duration = const Duration(milliseconds: 500),
    this.curve = Curves.easeInOut,
    this.offset = 50,
  }) : super(key: key);

  @override
  State<SlideAnimation> createState() => _SlideAnimationState();
}

class _SlideAnimationState extends State<SlideAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _offsetAnimation = Tween<Offset>(
      begin: _getBeginOffset(),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: widget.curve));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Offset _getBeginOffset() {
    switch (widget.direction) {
      case SlideDirection.fromLeft:
        return Offset(-widget.offset / 100, 0);
      case SlideDirection.fromRight:
        return Offset(widget.offset / 100, 0);
      case SlideDirection.fromTop:
        return Offset(0, -widget.offset / 100);
      case SlideDirection.fromBottom:
        return Offset(0, widget.offset / 100);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _offsetAnimation,
      child: FadeTransition(
        opacity: _controller,
        child: widget.child,
      ),
    );
  }
}