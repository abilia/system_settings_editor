part of 'main_page.dart';

class Agenda extends StatelessWidget {
  static const animationDuration = Duration(milliseconds: 500);
  final void Function(bool) onTap;
  final bool show;

  const Agenda({
    required this.show,
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
          flex: show ? 1 : 0,
          child: Column(
            children: [
              AgendaHeader(show: show, onTap: onTap),
              if (show) const AgendaContent(),
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
          child: const AgendaList(),
        ),
      ),
    );
  }
}

class AgendaList extends StatelessWidget {
  const AgendaList({super.key});

  @override
  Widget build(BuildContext context) {
    final agendaCubit = context.watch<AgendaCubit>();
    return switch (agendaCubit.state) {
      AgendaLoading() => const Center(child: CircularProgressIndicator()),
      AgendaLoaded(occasions: final occasions) => Builder(
          builder: (context) {
            final dayActivities = occasions.values.flattened.toList();
            return ListView.separated(
              padding: const EdgeInsets.all(8),
              itemCount: dayActivities.length,
              itemBuilder: (context, index) => AgendaTile(
                activity: dayActivities[index],
              ),
              separatorBuilder: (context, index) => const SizedBox(height: 8),
            );
          },
        ),
    };
  }
}
