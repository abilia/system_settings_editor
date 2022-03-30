import 'package:flutter/cupertino.dart';

class AbiliaScrollBar extends StatelessWidget {
  final Widget child;
  final ScrollController? controller;
  final bool isAlwaysShown;

  const AbiliaScrollBar({
    Key? key,
    this.controller,
    required this.child,
    this.isAlwaysShown = false,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) => CupertinoScrollbar(
        controller: controller,
        isAlwaysShown: isAlwaysShown,
        child: child,
      );
}
