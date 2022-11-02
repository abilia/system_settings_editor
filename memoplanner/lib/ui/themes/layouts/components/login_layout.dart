import 'package:flutter/material.dart';

class LoginLayout {
  final double topFormDistance, logoSize, termsPadding, logoHeight;
  final EdgeInsets createAccountPadding, loginButtonPadding;

  const LoginLayout({
    this.topFormDistance = 32,
    this.logoSize = 64,
    this.termsPadding = 48,
    this.logoHeight = 64,
    this.createAccountPadding = const EdgeInsets.fromLTRB(16, 8, 16, 32),
    this.loginButtonPadding = const EdgeInsets.fromLTRB(16, 32, 16, 0),
  });
}
