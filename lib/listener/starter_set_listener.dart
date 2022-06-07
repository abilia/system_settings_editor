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
          listener: (context, state) async {
            final sortableBloc = context.read<SortableBloc>();
            final language = Translator.of(context).locale.languageCode;
            final shouldAdd = await showViewDialog<bool>(
              context: context,
              builder: (context) => const StartedSetDialog(),
            );
            if (shouldAdd == true) {
              final result = await sortableBloc.addStarter(language);
              if (!result) {
                // TODO what?
              }
            }
          },
        );
}
