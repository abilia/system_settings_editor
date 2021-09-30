import 'package:equatable/equatable.dart';

import 'type_wiz_cubit.dart';

class TypeWizState extends Equatable {
  final CategoryType type;

  TypeWizState(this.type);

  @override
  List<Object?> get props => [type];
}
