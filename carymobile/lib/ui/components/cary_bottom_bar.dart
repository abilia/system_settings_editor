import 'package:flutter/material.dart';

class CaryBottomBar extends StatelessWidget {
  final Widget child;
  const CaryBottomBar({required this.child, super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Color(0x19000000),
              blurRadius: 12,
              offset: Offset(0, -4),
              spreadRadius: 0,
            )
          ],
        ),
        padding: const EdgeInsets.all(16.0),
        child: child,
      ),
    );
  }
}
