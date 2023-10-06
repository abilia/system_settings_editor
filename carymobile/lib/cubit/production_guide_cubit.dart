import 'package:bloc/bloc.dart';
import 'package:carymessenger/db/settings_db.dart';
import 'package:meta/meta.dart';

part 'production_guide_state.dart';

class ProductionGuideCubit extends Cubit<ProductionGuideState> {
  ProductionGuideCubit({
    required this.settingsDb,
  }) : super(
          settingsDb.productionGuideDone
              ? ProductionGuideDone()
              : ProductionGuideNotDone(),
        );
  final SettingsDb settingsDb;

  Future<void> setDone() async {
    await settingsDb.setProductionGuideDone();
    emit(ProductionGuideDone());
  }
}
