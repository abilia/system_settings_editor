import 'package:flutter/material.dart';
import 'package:seagull/ui/all.dart';

class BottomNavigation extends StatelessWidget {
  final Widget backNavigationWidget;
  final Widget forwardNavigationWidget;
  final bool useSafeArea;

  const BottomNavigation({
    Key key,
    @required this.backNavigationWidget,
    this.forwardNavigationWidget,
    this.useSafeArea = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return _BottomNavigation(
      useSafeArea: useSafeArea,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (forwardNavigationWidget != null) ...[
            Expanded(child: backNavigationWidget),
            const SizedBox(width: 8),
            Expanded(child: forwardNavigationWidget),
          ] else
            Center(child: backNavigationWidget),
        ],
      ),
    );
  }
}

class AnimatedBottomNavigation extends StatelessWidget {
  const AnimatedBottomNavigation({
    Key key,
    @required this.backNavigationWidget,
    @required this.forwardNavigationWidget,
    this.showForward = true,
  }) : super(key: key);

  final Widget backNavigationWidget;
  final Widget forwardNavigationWidget;
  final bool showForward;
  static const _duration = Duration(milliseconds: 200);

  @override
  Widget build(BuildContext context) {
    return _BottomNavigation(
      child: Stack(
        children: [
          AnimatedAlign(
            alignment:
                showForward ? Alignment.centerRight : Alignment(4.0, 0.0),
            duration: _duration,
            child: forwardNavigationWidget,
          ),
          AnimatedAlign(
            alignment: showForward ? Alignment.centerLeft : Alignment.center,
            duration: _duration,
            child: backNavigationWidget,
          ),
        ],
      ),
    );
  }
}

class _BottomNavigation extends StatelessWidget {
  final bool useSafeArea;
  const _BottomNavigation({
    Key key,
    @required this.child,
    this.useSafeArea = true,
  }) : super(key: key);

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final bottom = Container(
      color: AbiliaColors.black80,
      height: 84.0,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
        child: child,
      ),
    );

    if (useSafeArea) {
      return Container(
        color: AbiliaColors.black80,
        child: SafeArea(
          child: bottom,
        ),
      );
    }
    return bottom;
  }
}
