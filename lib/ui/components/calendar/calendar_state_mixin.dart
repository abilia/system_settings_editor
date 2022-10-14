import 'package:flutter/widgets.dart';
import 'package:seagull/bloc/all.dart';

mixin CalendarStateMixin<T extends StatelessWidget> {
  Future<void> refresh(BuildContext context) {
    context.read<SyncBloc>().add(const SyncAll());
    return Future.delayed(const Duration(milliseconds: 500));
  }
}
