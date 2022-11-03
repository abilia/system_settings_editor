import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/db/all.dart';

class BaseUrlCubit extends Cubit<String> {
  BaseUrlCubit({required this.baseUrlDb}) : super(baseUrlDb.baseUrl);

  final BaseUrlDb baseUrlDb;

  void updateBaseUrl(String baseUrl) async {
    await baseUrlDb.setBaseUrl(baseUrl);
    emit(baseUrl);
  }
}
