class TermsOfUse {
  final bool termsOfCondition;
  final bool privacyPolicy;

  bool get allAccepted => termsOfCondition && privacyPolicy;

  const TermsOfUse(
      {required this.termsOfCondition, required this.privacyPolicy});

  factory TermsOfUse.notReady() =>
      const TermsOfUse(termsOfCondition: false, privacyPolicy: false);

  factory TermsOfUse.ready() =>
      const TermsOfUse(termsOfCondition: true, privacyPolicy: true);

  factory TermsOfUse.fromMap(Map<String, dynamic> json) => TermsOfUse(
        termsOfCondition: json['termsOfCondition'],
        privacyPolicy: json['privacyPolicy'],
      );

  Map<String, dynamic> toMap() => <String, dynamic>{
        'termsOfCondition': termsOfCondition,
        'privacyPolicy': privacyPolicy,
      };
}
