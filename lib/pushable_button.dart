library pushable_button;

import 'package:flutter/material.dart';

import 'animation_controller_state.dart';

/// A widget to show a "3D" pushable button
class PushableButton extends StatefulWidget {
  const PushableButton({
    Key? key,
    this.child,
    required this.hslColor,
    required this.height,
    this.width,
    // this.elevation = 8.0,
    this.offset = const Offset(0, 8),
    this.shadow,
    this.onPressed,
    this.buttonDecoration,
    this.baseDecoration,
    this.padding = const EdgeInsets.all(16),
  })  : assert(height > 0),
        super(key: key);

  /// Child widget (normally a Text or Icon)
  final Widget? child;

  /// Color of the top layer
  /// The color of the bottom layer is derived by decreasing the luminosity by 0.15
  final HSLColor hslColor;

  /// Optional: Width of the top layer
  final double? width;

  /// Height of the top layer
  final double height;

  /// Elevation or "gap" between the top and bottom layer
  // final double elevation;

  /// Offset or "gap" between the top and bottom layer
  final Offset offset;

  /// Decoration of button
  final BoxDecoration? buttonDecoration;

  /// Decoration of button base (background)
  final BoxDecoration? baseDecoration;

  /// An optional shadow to make the button look better
  /// This is added to the bottom layer only
  final BoxShadow? shadow;
  
  final EdgeInsets padding;

  /// button pressed callback
  final VoidCallback? onPressed;

  @override
  _PushableButtonState createState() => _PushableButtonState(Duration(microseconds: 233));
}

class _PushableButtonState extends AnimationControllerState<PushableButton> {
  _PushableButtonState(Duration duration) : super(duration);

  bool _isDragInProgress = false;
  Offset _gestureLocation = Offset.zero;

  void _handleTapDown(TapDownDetails details) {
    _gestureLocation = details.localPosition;
    animationController.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    animationController.reverse();
    widget.onPressed?.call();
  }

  void _handleTapCancel() {
    Future.delayed(Duration(milliseconds: 100), () {
      if (!_isDragInProgress && mounted) {
        animationController.reverse();
      }
    });
  }

  void _handleDragStart(DragStartDetails details) {
    _gestureLocation = details.localPosition;
    _isDragInProgress = true;
    animationController.forward();
  }

  void _handleDragEnd(Size buttonSize) {
    //print('drag end (in progress: $_isDragInProgress)');
    if (_isDragInProgress) {
      _isDragInProgress = false;
      animationController.reverse();
    }
    if (_gestureLocation.dx >= 0 &&
        _gestureLocation.dy < buttonSize.width &&
        _gestureLocation.dy >= 0 &&
        _gestureLocation.dy < buttonSize.height) {
      widget.onPressed?.call();
    }
  }

  void _handleDragCancel() {
    if (_isDragInProgress) {
      _isDragInProgress = false;
      animationController.reverse();
    }
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    _gestureLocation = details.localPosition;
  }

  @override
  Widget build(BuildContext context) {
    // final totalHeight = widget.height + widget.elevation;
    final totalHeight = widget.height + widget.offset.dy;

    return SizedBox(
      width: widget.width,
      height: totalHeight,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final buttonSize = Size(constraints.maxWidth, constraints.maxHeight);
          return GestureDetector(
            // onTap: _handleTap,
            onTapDown: _handleTapDown,
            onTapUp: _handleTapUp,
            onTapCancel: _handleTapCancel,
            onHorizontalDragStart: _handleDragStart,
            onHorizontalDragEnd: (_) => _handleDragEnd(buttonSize),
            onHorizontalDragCancel: _handleDragCancel,
            onHorizontalDragUpdate: _handleDragUpdate,
            onVerticalDragStart: _handleDragStart,
            onVerticalDragEnd: (_) => _handleDragEnd(buttonSize),
            onVerticalDragCancel: _handleDragCancel,
            onVerticalDragUpdate: _handleDragUpdate,
            child: AnimatedBuilder(
              animation: animationController,
              builder: (context, child) {
                final top = animationController.value * widget.offset.dy;
                final left = animationController.value * widget.offset.dx * -1;
                final right = animationController.value * widget.offset.dx;

                final hslColor = widget.hslColor;
                final bottomHslColor = hslColor.withLightness(hslColor.lightness - 0.15);

                return Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // Draw bottom layer first
                    Positioned(
                      left: 0 - widget.offset.dx,
                      right: widget.offset.dx,
                      bottom: 0,
                      child: Container(
                        height: widget.height,
                        decoration: widget.baseDecoration != null
                            ? widget.baseDecoration!.copyWith(
                                color: widget.baseDecoration!.color ?? bottomHslColor.toColor(),
                                boxShadow: widget.baseDecoration!.boxShadow ??
                                    (widget.shadow != null ? [widget.shadow!] : []),
                                borderRadius: widget.baseDecoration!.borderRadius ??
                                    BorderRadius.circular(widget.height / 2),
                              )
                            : BoxDecoration(
                                color: bottomHslColor.toColor(),
                                boxShadow: widget.shadow != null ? [widget.shadow!] : [],
                                borderRadius: BorderRadius.circular(widget.height / 2),
                              ),
                      ),
                    ),
                    // Then top (pushable) layer
                    Positioned(
                      left: left,
                      right: right,
                      top: top,
                      child: Container(
                        height: widget.height,
                        decoration: widget.buttonDecoration != null
                            ? widget.buttonDecoration!.copyWith(
                                color: widget.buttonDecoration!.color ?? hslColor.toColor(),
                              )
                            : ShapeDecoration(
                                color: hslColor.toColor(),
                                shape: StadiumBorder(),
                              ),
                        child: Padding(
                          padding: widget.padding,
                          child: Center(child: widget.child),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          );
        },
      ),
    );
  }
}
