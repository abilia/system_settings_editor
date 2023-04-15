import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/ui/all.dart';

class DayCalendarAppBar extends StatelessWidget implements PreferredSizeWidget {
  const DayCalendarAppBar({Key? key}) : super(key: key);
  @override
  Size get preferredSize => CalendarAppBar.size;

  @override
  Widget build(BuildContext context) {
    final showBrowseButtons = context.select((MemoplannerSettingsBloc bloc) =>
        bloc.state.dayCalendar.appBar.showBrowseButtons);
    final day = context.select((DayPickerBloc bloc) => bloc.state.day);
    return BlocBuilder<ScrollPositionCubit, ScrollPositionState>(
      buildWhen: (previous, current) =>
          previous.runtimeType != current.runtimeType,
      builder: (context, scrollState) {
        final clockReplacement = scrollState is WrongDay
            ? GoToTodayButton(
                onPressed: () async {
                  final maybeGoToNightCalendar =
                      context.read<TimepillarCubit>().maybeGoToNightCalendar();
                  if (!maybeGoToNightCalendar) {
                    await context.read<ScrollPositionCubit>().goToNow();
                  }
                },
              )
            : null;
        final leftAction = showBrowseButtons
            ? LeftNavButton(
                onPressed: BlocProvider.of<TimepillarCubit>(context).previous,
              )
            : null;
        final rightAction = showBrowseButtons
            ? RightNavButton(
                onPressed: BlocProvider.of<TimepillarCubit>(context).next,
              )
            : null;

        return DayAppBar(
          day: day,
          clockReplacement: clockReplacement,
          leftAction: leftAction,
          rightAction: rightAction,
        );
      },
    );
  }
}
