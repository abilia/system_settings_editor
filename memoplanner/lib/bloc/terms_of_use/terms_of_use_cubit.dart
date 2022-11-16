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
    _loadTermsOfUse();
  }

  // If fetching terms of use fails and throws an exception,
  // TermsOfUse.accepted will be emitted thus not triggering the TermsOfUseDialog on login.
  Future<void> _loadTermsOfUse() async {
    TermsOfUse termsOfUse = TermsOfUse.accepted();
    try {
      termsOfUse = await termsOfUseRepository.fetchTermsOfUse();
    } on FetchTermsOfUseException catch (e) {
      _log.warning(
          'Could not fetch terms of use from backend with status code ${e.statusCode}');
    } catch (e) {
      _log.warning('Could not fetch terms of use from backend $e');
    }
    emit(TermsOfUseLoaded(termsOfUse));
  }

  Future<Response> postTermsOfUse(TermsOfUse termsOfUse) =>
      termsOfUseRepository.postTermsOfUse(termsOfUse);
}
