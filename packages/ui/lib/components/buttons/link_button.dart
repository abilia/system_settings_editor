import 'package:flutter/material.dart';

class LinkButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String title;
  const LinkButton({
    required this.title,
    super.key,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      child: Text(title),
    );
  }
}
