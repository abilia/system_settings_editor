import 'package:flutter/material.dart';

class SupportPersonLayout {
  final EdgeInsets iconPadding;
  final EdgeInsets switchFieldPadding;

  const SupportPersonLayout(
      {this.iconPadding = const EdgeInsets.symmetric(vertical: 10),
      this.switchFieldPadding = const EdgeInsets.only(left: 4, right: 4),});
}

class SupportPersonLayoutMedium extends SupportPersonLayout {
  const SupportPersonLayoutMedium()
      : super(
          iconPadding: const EdgeInsets.symmetric(vertical: 13),
          switchFieldPadding: const EdgeInsets.only(left: 6, right: 6),
        );
}
