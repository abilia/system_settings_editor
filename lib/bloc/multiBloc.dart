import 'package:flutter/widgets.dart';
import 'package:seagull/bloc/all.dart';

MultiBlocProvider editActivityMultiBlocProvider(
  BuildContext context, {
  @required Widget child,
}) =>
    MultiBlocProvider(
      providers: [
        BlocProvider<ActivitiesBloc>.value(
            value: BlocProvider.of<ActivitiesBloc>(context)),
        BlocProvider<SortableBloc>.value(
            value: BlocProvider.of<SortableBloc>(context)),
        BlocProvider<ClockBloc>.value(
            value: BlocProvider.of<ClockBloc>(context)),
        BlocProvider<UserFileBloc>.value(
            value: BlocProvider.of<UserFileBloc>(context)),
      ],
      child: child,
    );
