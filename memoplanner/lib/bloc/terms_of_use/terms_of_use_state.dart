part of 'terms_of_use_cubit.dart';

abstract class TermsOfUseState {
  final TermsOfUse termsOfUse;
  const TermsOfUseState(this.termsOfUse);
}

class TermsOfUseLoaded extends TermsOfUseState {
  const TermsOfUseLoaded(TermsOfUse termsOfUse) : super(termsOfUse);
}

class TermsOfUseNotLoaded extends TermsOfUseState {
  TermsOfUseNotLoaded() : super(TermsOfUse.notAccepted());
}
