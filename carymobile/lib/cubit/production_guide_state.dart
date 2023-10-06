part of 'production_guide_cubit.dart';

@immutable
sealed class ProductionGuideState {}

final class ProductionGuideDone extends ProductionGuideState {}

final class ProductionGuideNotDone extends ProductionGuideState {}
