class TermsOfUse {
  final bool termsOfCondition;
  final bool privacyPolicy;

  bool get allAccepted => termsOfCondition && privacyPolicy;

  TermsOfUse({required this.termsOfCondition, required this.privacyPolicy});

  factory TermsOfUse.notReady() =>
      TermsOfUse(termsOfCondition: false, privacyPolicy: false);

  factory TermsOfUse.fromJson(Map<String, dynamic> json) => TermsOfUse(
        termsOfCondition: json['termsOfCondition'],
        privacyPolicy: json['privacyPolicy'],
      );
}
