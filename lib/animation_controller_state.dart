import 'package:flutter/material.dart';

/// abstract class to reduce animation controller boilerplate
/// See: https://codewithandrea.com/videos/reduce-animation-controller-boilerplate-flutter-hooks/
abstract class AnimationControllerState<T extends StatefulWidget> extends State<T>
    with SingleTickerProviderStateMixin {
  AnimationControllerState(this.animationDuration, [this.easingCurve = Curves.easeOut]);
  final Duration animationDuration;
  late final AnimationController animationController;

  late final Animation animation;
  final Curve easingCurve;

  @override
  void initState() {
    super.initState();
    animationController = AnimationController(vsync: this, duration: animationDuration);
    animation = CurveTween(curve: easingCurve).animate(animationController);
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }
}
