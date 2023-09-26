import 'package:auth/auth.dart';
import 'package:calendar_events/calendar_events.dart';
import 'package:file_storage/file_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:repository_base/db/baseurl_db.dart';
import 'package:repository_base/end_point.dart';
import 'package:seagull_clock/clock_cubit.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:user_files/user_files.dart';
import 'package:utils/utils.dart';

export 'package:transparent_image/transparent_image.dart';

class MainPage extends StatelessWidget {
  final Authenticated authenticated;

  const MainPage({
    required this.authenticated,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final day = context.select((ClockCubit cubit) => cubit.state.onlyDays());
    return Scaffold(
      body: SafeArea(
        child: BlocListener<PushCubit, RemoteMessage>(
          listener: (context, message) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('${'Push received'} ${message.data}'),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const ClockAndDate(),
                Expanded(
                  child: FutureBuilder(
                    future: context
                        .watch<ActivitiesCubit>()
                        // ignore: discarded_futures
                        .getActivitiesAfter(day),
                    builder: (context, snapshot) {
                      final activities = snapshot.data?.toList() ?? [];
                      final dayActivities = context.select(
                        (ClockCubit time) => activities
                            .expand(
                                (activity) => activity.dayActivitiesForDay(day))
                            .toList(),
                      );
                      return ListView.builder(
                        itemCount: dayActivities.length,
                        itemBuilder: (context, index) {
                          final activity = dayActivities[index];
                          return AgendaTile(activity: activity);
                        },
                      );
                    },
                  ),
                ),
                TextButton(
                  onPressed: () =>
                      context.read<AuthenticationBloc>().add(const LoggedOut()),
                  child: const Text('Log out'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ClockAndDate extends StatelessWidget {
  const ClockAndDate({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ClockCubit, DateTime>(
      builder: (context, time) => Column(
        children: [
          Text(DateFormat.Hm().format(time)),
          Text(DateFormat.EEEE().format(time)),
          Text(DateFormat.yMMMMd().format(time)),
        ],
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
    AbiliaFile imageFile, [
    ImageSize imageSize = ImageSize.thumb,
  ]) {
    final userFileState = context.watch<UserFileBloc>().state;
    final file = userFileState.getLoadedByIdOrPath(
      imageFile.id,
      imageFile.path,
      GetIt.I<FileStorage>(),
      imageSize: imageSize,
    );
    if (file != null) {
      return Image.file(file);
    }
    final authenicatedState = context.watch<AuthenticationBloc>().state;
    if (authenicatedState is Authenticated) {
      return Image.network(
        imageThumbUrl(
          baseUrl: GetIt.I<BaseUrlDb>().baseUrl,
          userId: authenicatedState.userId,
          imageFileId: imageFile.id,
          imagePath: imageFile.path,
          size: ImageThumb.thumbSize,
        ),
        headers: authHeader(GetIt.I<LoginDb>().getToken()),
      );
    }
    return Image.memory(kTransparentImage);
  }
}
