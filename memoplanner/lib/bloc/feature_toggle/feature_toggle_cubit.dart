import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/repository/all.dart';

class FeatureToggleCubit extends Cubit<FeatureToggleState> {
  FeatureToggleCubit({required this.featureToggleRepository})
      : super(FeatureToggleState({}));
  final FeatureToggleRepository featureToggleRepository;
  void toggleFeature(FeatureToggle feature) {
    emit(state.toggle(feature));
  }

  Future<void> updateTogglesFromBackend() async {
    final toggles = await featureToggleRepository.getToggles();
    emit(FeatureToggleState(toggles.toSet()));
  }
}

class FeatureToggleState {
  final Set<FeatureToggle> featureToggles;
  FeatureToggleState(this.featureToggles);

  FeatureToggleState toggle(FeatureToggle feature) {
    featureToggles.contains(feature)
        ? featureToggles.remove(feature)
        : featureToggles.add(feature);
    return FeatureToggleState(featureToggles);
  }

  bool isToggleEnabled(FeatureToggle toggle) {
    return featureToggles.contains(toggle);
  }
}

// A representation of all available feature toggles
enum FeatureToggle {
  fakeTime,
  videoInActivity,
}

extension FeatureToggleExtension on FeatureToggle {
  String get name {
    switch (this) {
      case FeatureToggle.fakeTime:
        return 'Fake time';
      case FeatureToggle.videoInActivity:
        return 'Video in activity';
    }
  }
}
