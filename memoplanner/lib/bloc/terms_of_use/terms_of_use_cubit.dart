import 'package:http/http.dart';
import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/logging.dart';
import 'package:memoplanner/models/all.dart';
import 'package:memoplanner/repository/terms_of_use_repository.dart';

part 'terms_of_use_state.dart';

class TermsOfUseCubit extends Cubit<TermsOfUseState> {
  final TermsOfUseRepository termsOfUseRepository;
  final _log = Logger((TermsOfUseCubit).toString());

  TermsOfUseCubit({required this.termsOfUseRepository})
      : super(TermsOfUseNotLoaded()) {
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      final termsOfUse = await termsOfUseRepository.fetchTermsOfUse();
      emit(TermsOfUseLoaded(termsOfUse));
    } on FetchTermsOfUseException catch (e) {
      _log.warning(
          'Could not fetch terms of use from backend with status code ${e.statusCode}');
    } catch (e) {
      _log.warning('Could not fetch terms of use from backend $e');
    }
  }

  Future<Response> postTermsOfUse(bool termsOfCondition, bool privacyPolicy) =>
      termsOfUseRepository.postTermsOfUse(termsOfCondition, privacyPolicy);
}
