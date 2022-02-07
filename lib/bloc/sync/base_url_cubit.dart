import 'package:seagull/bloc/all.dart';
import 'package:seagull/db/all.dart';

class BaseUrlCubit extends Cubit<String> {
  BaseUrlCubit({required this.baseUrlDb}) : super(baseUrlDb.getBaseUrl());

  final BaseUrlDb baseUrlDb;

  void updateBaseUrl(String baseUrl) async {
    await baseUrlDb.setBaseUrl(baseUrl);
    emit(baseUrl);
  }
}
