part of 'home_page.dart';

class Agenda extends StatelessWidget {
  const Agenda({super.key});

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
  const AgendaTile({required this.activity, super.key});

  final ActivityDay activity;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: activity.hasImage ? getImage(context, activity.image) : null,
      title: Text(activity.title),
    );
  }

  static Image getImage(
    BuildContext context,
    AbiliaFile imageFile,
  ) {
    final file = context.select(
      (UserFileBloc bloc) => bloc.state.getLoadedByIdOrPath(
        imageFile.id,
        imageFile.path,
        GetIt.I<FileStorage>(),
      ),
    );
    if (file != null) return Image.file(file);
    final authenticatedState = context.watch<AuthenticationBloc>().state;
    if (authenticatedState is Authenticated) {
      return Image.network(
        imageThumbUrl(
          baseUrl: GetIt.I<BaseUrlDb>().baseUrl,
          userId: authenticatedState.userId,
          imageFileId: imageFile.id,
          imagePath: imageFile.path,
        ),
        headers: authHeader(GetIt.I<LoginDb>().getToken()),
      );
    }
    return Image.memory(kTransparentImage);
  }
}
