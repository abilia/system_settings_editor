part of 'calendar_view_cubit.dart';

class ToggleCategory extends Equatable {
  final int category;
  const ToggleCategory(this.category);
  @override
  List<Object> get props => [category];
}
