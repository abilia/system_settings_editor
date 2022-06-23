import 'package:flutter/material.dart';

class SupportPersonLayout {
  final EdgeInsets switchFieldPadding;

  const SupportPersonLayout({
    this.switchFieldPadding = const EdgeInsets.only(left: 4, right: 4),
  });
}

class SupportPersonLayoutMedium extends SupportPersonLayout {
  const SupportPersonLayoutMedium()
      : super(
          switchFieldPadding: const EdgeInsets.only(left: 6, right: 6),
        );
}
