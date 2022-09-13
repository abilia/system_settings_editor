part of 'license_cubit.dart';

abstract class LicenseState extends Equatable {
  const LicenseState();
  @override
  List<Object> get props => [];
}

class LicensesNotLoaded extends LicenseState {}

class ValidLicense extends LicenseState {}

class NoValidLicense extends LicenseState {}

class NoLicense extends NoValidLicense {}
