part of 'license_bloc.dart';

abstract class LicenseState {
  const LicenseState();
}

class LicensesNotLoaded extends LicenseState {}

class ValidLicense extends LicenseState {}

class NoValidLicense extends LicenseState {}
