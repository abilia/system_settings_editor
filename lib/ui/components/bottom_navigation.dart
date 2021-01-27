import 'package:flutter/material.dart';
import 'package:seagull/ui/all.dart';

class BottomNavigation extends StatelessWidget {
  const BottomNavigation({
    Key key,
    @required this.backNavigationWidget,
    this.forwardNavigationWidget,
  }) : super(key: key);

  final Widget backNavigationWidget;
  final Widget forwardNavigationWidget;

  @override
  Widget build(BuildContext context) {
    return _BottomNavigation(
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
  const _BottomNavigation({
    Key key,
    @required this.child,
  }) : super(key: key);

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AbiliaColors.black80,
      child: SafeArea(
        child: Container(
          height: 84.0,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
            child: child,
          ),
        ),
      ),
    );
  }
}
