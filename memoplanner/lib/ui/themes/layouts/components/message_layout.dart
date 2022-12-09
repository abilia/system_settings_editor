import 'package:flutter/material.dart';

class MessageLayout {
  final EdgeInsets textPadding;
  final EdgeInsets trailingPadding;

  const MessageLayout({
    this.textPadding = const EdgeInsets.symmetric(
      horizontal: 16,
      vertical: 20,
    ),
    this.trailingPadding = const EdgeInsets.all(6),
  });
}

class MessageLayoutMedium extends MessageLayout {
  const MessageLayoutMedium({
    super.textPadding = const EdgeInsets.all(24),
    super.trailingPadding = const EdgeInsets.all(8),
  });
}
