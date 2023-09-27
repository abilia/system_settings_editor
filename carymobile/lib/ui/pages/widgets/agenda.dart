import 'package:auth/auth.dart';
import 'package:calendar_events/calendar_events.dart';
import 'package:carymessenger/cubit/agenda_cubit.dart';
import 'package:collection/collection.dart';
import 'package:file_storage/file_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:repository_base/db/baseurl_db.dart';
import 'package:repository_base/end_point.dart';
import 'package:seagull_clock/clock_cubit.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:user_files/user_files.dart';

class Agenda extends StatelessWidget {
  const Agenda({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AgendaCubit(
        onActivityUpdate: context.read<ActivitiesCubit>().stream,
        clock: context.read<ClockCubit>(),
        activityRepository: context.read<ActivityRepository>(),
      ),
      child: BlocBuilder<AgendaCubit, AgendaState>(
        builder: (context, state) {
          if (state is AgendaLoading) {
            return const CircularProgressIndicator();
          }
          final dayActivities = state.occasions.values.flattened.toList();
          return ListView.builder(
            itemCount: dayActivities.length,
            itemBuilder: (context, index) =>
                AgendaTile(activity: dayActivities[index]),
          );
        },
      ),
    );
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
