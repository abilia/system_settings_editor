import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:repository_base/repository_base.dart';

class BaseUrlCubit extends Cubit<String> {
  BaseUrlCubit({required this.baseUrlDb}) : super(baseUrlDb.baseUrl);

  final BaseUrlDb baseUrlDb;

  Future<void> updateBaseUrl(String baseUrl) async {
    await baseUrlDb.setBaseUrl(baseUrl);
    if (isClosed) return;
    emit(baseUrl);
  }
}
