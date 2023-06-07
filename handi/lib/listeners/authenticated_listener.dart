import 'package:calendar_events/calendar_events.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:handi/bloc/notification_bloc.dart';

class AuthenticatedListener extends StatelessWidget {
  final Widget child;

  const AuthenticatedListener({
    required this.child,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BlocListener<ActivitiesBloc, ActivitiesChanged>(
      listener: (context, state) =>
          context.read<NotificationBloc>().add(NotificationEvent()),
      child: child,
    );
  }
}
