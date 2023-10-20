part of 'main_page.dart';

class AgendaList extends StatelessWidget {
  final List<ActivityDay> dayActivities;
  const AgendaList({required this.dayActivities, super.key});

  @override
  Widget build(BuildContext context) {
    final itemScrollController = ItemScrollController();
    return BlocListener<ClockCubit, DateTime>(
      listener: (context, time) async => itemScrollController.scrollTo(
        index: indexFor(time),
        duration: const Duration(seconds: 1),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) => ScrollablePositionedList.builder(
          padding: const EdgeInsets.symmetric(horizontal: 8) +
              EdgeInsets.only(
                bottom: constraints.maxHeight - AgendaTile.minHeight - 16,
              ),
          itemCount: dayActivities.length,
          itemBuilder: (context, index) => Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: AgendaTile(activity: dayActivities[index]),
          ),
          initialScrollIndex: indexFor(context.read<ClockCubit>().state),
          itemScrollController: itemScrollController,
        ),
      ),
    );
  }

  int indexFor(DateTime time) => max(
        0,
        dayActivities.lastIndexWhere((element) => element.start.isBefore(time)),
      );
}
