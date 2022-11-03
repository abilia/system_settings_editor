import 'package:flutter/widgets.dart';
import 'package:memoplanner/bloc/all.dart';

mixin CalendarWidgetMixin<T extends StatelessWidget> {
  Future<void> refresh(BuildContext context) {
    context.read<SyncBloc>().add(const SyncAll());
    return Future.delayed(const Duration(milliseconds: 500));
  }
}
