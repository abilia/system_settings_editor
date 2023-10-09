import 'package:abilia_sync/abilia_sync.dart';
import 'package:calendar_events/bloc/all.dart';
import 'package:collection/collection.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:generics/bloc/all.dart';
import 'package:logging/logging.dart';
import 'package:sortables/bloc/all.dart';
import 'package:user_files/user_files.dart';

/// Always use [copiedAuthProviders] outside the builder callback
/// Otherwise hot reload might throw exception
List<BlocProvider> copiedAuthProviders(BuildContext blocContext) => [
      _tryGetBloc<SyncBloc>(blocContext),
      _tryGetBloc<ActivitiesCubit>(blocContext),
      _tryGetBloc<UserFileBloc>(blocContext),
      _tryGetBloc<SortableBloc>(blocContext),
      _tryGetBloc<GenericCubit>(blocContext),
    ].whereNotNull().toList();

final _copyBlocLog = Logger('CopiedProvider');

BlocProvider? _tryGetBloc<B extends BlocBase>(BuildContext context) {
  try {
    return BlocProvider<B>.value(value: context.read<B>());
  } catch (e) {
    _copyBlocLog.warning('Could not fetch provider of $B', e);
    return null;
  }
}
