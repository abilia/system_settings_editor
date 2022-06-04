import 'package:seagull/bloc/all.dart';
import 'package:seagull/ui/all.dart';

class StarterSetListener extends BlocListener<SortableBloc, SortableState> {
  StarterSetListener({Key? key})
      : super(
          key: key,
          listenWhen: (previous, current) =>
              previous is! SortablesLoaded &&
              current is SortablesLoaded &&
              current.sortables.isEmpty,
          listener: (context, state) => showViewDialog(
            context: context,
            builder: (context) => const StartedSetDialog(),
          ),
        );
}
