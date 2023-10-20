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
    final refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();
    return BlocListener<SyncBloc, SyncState>(
      listenWhen: (oldState, newState) => newState is Syncing,
      listener: (oldState, newState) async =>
          refreshIndicatorKey.currentState?.show(),
      child: Expanded(
        child: ColoredBox(
          color: abiliaBrown0,
          child: RefreshIndicator(
            key: refreshIndicatorKey,
            onRefresh: () async {
              final syncBloc = context.read<SyncBloc>();
              if (syncBloc.state is! Syncing) {
                syncBloc.add(const SyncAll());
                return;
              }
              await syncBloc.stream.firstWhere((state) => state is! Syncing);
            },
            child: switch (context.watch<AgendaCubit>().state) {
              AgendaLoading() => const SizedBox.shrink(),
              AgendaLoaded(activities: final dayActivities) =>
                AgendaList(dayActivities: dayActivities),
            },
          ),
        ),
      ),
    );
  }
}
