import 'package:flutter/painting.dart';

class TemplatesLayout {
  final EdgeInsets m1,
      m2,
      m3,
      m4,
      m5,
      m6,
      m7,
      s1,
      s2,
      s3,
      s4,
      s5,
      l1,
      l2,
      l3,
      l5,
      bottomNavigation;

  const TemplatesLayout({
    this.s1 = const EdgeInsets.all(12),
    this.s2 = const EdgeInsets.fromLTRB(12, 12, 12, 40),
    this.s3 = const EdgeInsets.all(4),
    this.s4 = const EdgeInsets.symmetric(horizontal: 12),
    this.s5 = const EdgeInsets.symmetric(horizontal: 12, vertical: 48),
    this.bottomNavigation = const EdgeInsets.fromLTRB(12, 8, 12, 12),
    this.m1 = const EdgeInsets.fromLTRB(12, 24, 12, 40),
    this.m2 = const EdgeInsets.fromLTRB(12, 20, 12, 20),
    this.m3 = const EdgeInsets.fromLTRB(12, 24, 12, 12),
    this.m4 = const EdgeInsets.symmetric(horizontal: 24),
    this.m5 = const EdgeInsets.fromLTRB(12, 48, 12, 12),
    this.m6 = const EdgeInsets.fromLTRB(12, 12, 12, 12),
    this.m7 = const EdgeInsets.fromLTRB(12, 160, 12, 12),
    this.l1 = const EdgeInsets.fromLTRB(12, 96, 12, 64),
    this.l2 = const EdgeInsets.symmetric(horizontal: 24, vertical: 64),
    this.l3 = const EdgeInsets.symmetric(horizontal: 12, vertical: 64),
    this.l5 = const EdgeInsets.symmetric(horizontal: 32, vertical: 64),
  });
}

class TemplatesLayoutMedium extends TemplatesLayout {
  const TemplatesLayoutMedium({
    EdgeInsets? s4,
    EdgeInsets? s5,
  }) : super(
          s1: const EdgeInsets.all(16),
          s2: const EdgeInsets.fromLTRB(24, 24, 24, 64),
          s3: const EdgeInsets.all(6),
          s4: s4 ?? const EdgeInsets.symmetric(horizontal: 20),
          s5: s5 ?? const EdgeInsets.symmetric(horizontal: 20, vertical: 72),
          bottomNavigation: const EdgeInsets.fromLTRB(18, 12, 18, 18),
          m1: const EdgeInsets.fromLTRB(24, 36, 24, 64),
          m2: const EdgeInsets.fromLTRB(0, 32, 0, 32),
          m3: const EdgeInsets.fromLTRB(24, 36, 24, 24),
          m4: const EdgeInsets.symmetric(horizontal: 32),
          m5: const EdgeInsets.fromLTRB(24, 96, 24, 24),
          m6: const EdgeInsets.fromLTRB(24, 24, 24, 24),
          m7: const EdgeInsets.fromLTRB(12, 320, 12, 12),
          l1: const EdgeInsets.fromLTRB(24, 146, 24, 64),
          l2: const EdgeInsets.symmetric(horizontal: 32, vertical: 96),
          l3: const EdgeInsets.symmetric(horizontal: 24, vertical: 96),
          l5: const EdgeInsets.symmetric(horizontal: 48, vertical: 96),
        );
}

class TemplatesLayoutLarge extends TemplatesLayoutMedium {
  const TemplatesLayoutLarge()
      : super(
          s4: const EdgeInsets.symmetric(horizontal: 160),
          s5: const EdgeInsets.symmetric(horizontal: 16, vertical: 72),
        );
}
