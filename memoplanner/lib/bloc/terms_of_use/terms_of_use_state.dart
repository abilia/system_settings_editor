part of 'terms_of_use_cubit.dart';

abstract class TermsOfUseState {
  final TermsOfUse termsOfUse;
  const TermsOfUseState(this.termsOfUse);
}

class TermsOfUseReady extends TermsOfUseState {
  const TermsOfUseReady(TermsOfUse termsOfUse) : super(termsOfUse);
}

class TermsOfUseNotReady extends TermsOfUseState {
  TermsOfUseNotReady() : super(TermsOfUse.notReady());
}
