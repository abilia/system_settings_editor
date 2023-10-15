part of 'main_page.dart';

class Agenda extends StatelessWidget {
  static const animationDuration = Duration(milliseconds: 500);
  final void Function(bool) onTap;
  final bool expanded;

  const Agenda({
    required this.expanded,
    required this.onTap,
    super.key,
  });

  @override
  @override
  Widget build(BuildContext context) => BlocProvider(
        create: (context) => AgendaCubit(
          onActivityUpdate: context.read<ActivitiesCubit>().stream,
          clock: context.read<ClockCubit>(),
          activityRepository: context.read<ActivityRepository>(),
        ),
        child: Expanded(
          flex: expanded ? 1 : 0,
          child: Column(
            children: [
              AgendaHeader(expanded: expanded, onTap: onTap),
              if (expanded) const AgendaContent(),
            ],
          ),
        ),
      );
}

class AgendaContent extends StatelessWidget {
  const AgendaContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ColoredBox(
        color: abiliaBrown0,
        child: RefreshIndicator(
          onRefresh: () async => context.read<SyncBloc>().add(const SyncAll()),
          child: switch (context.watch<AgendaCubit>().state) {
            AgendaLoading() => const Center(child: CircularProgressIndicator()),
            AgendaLoaded(activities: final dayActivities) => AgendaList(
                dayActivities: dayActivities,
              ),
          },
        ),
      ),
    );
  }
}
