part of 'main_page.dart';

class Agenda extends StatelessWidget {
  const Agenda({super.key});

  @override
  Widget build(BuildContext context) => BlocProvider(
        create: (context) => AgendaCubit(
          onActivityUpdate: context.read<ActivitiesCubit>().stream,
          clock: context.read<ClockCubit>(),
          activityRepository: context.read<ActivityRepository>(),
        ),
        child: const AgendaList(),
      );
}

class AgendaList extends StatelessWidget {
  const AgendaList({super.key});

  @override
  Widget build(BuildContext context) {
    final agendaCubit = context.watch<AgendaCubit>();
    return switch (agendaCubit.state) {
      AgendaLoading() => const CircularProgressIndicator(),
      AgendaLoaded(occasions: final occasions) => Builder(
          builder: (context) {
            final dayActivities = occasions.values.flattened.toList();
            return ListView.builder(
              itemCount: dayActivities.length,
              itemBuilder: (context, index) =>
                  AgendaTile(activity: dayActivities[index]),
            );
          },
        ),
    };
  }
}

class AgendaTile extends StatelessWidget {
  final ActivityDay activity;

  const AgendaTile({required this.activity, super.key});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onLongPress: () => context.read<AlarmCubit>().fakeAlarm(activity),
      leading: activity.hasImage
          ? AbiliaImage(
              activity.image,
              size: ImageSize.thumb,
            )
          : null,
      title: Text(activity.title),
      subtitle: Text(DateFormat.Hm().format(activity.start)),
    );
  }
}
