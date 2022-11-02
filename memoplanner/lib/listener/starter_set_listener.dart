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
            final t = Translator.of(context).translate;
            final sortableBloc = context.read<SortableBloc>();
            final language = Translator.of(context).locale.languageCode;
            final shouldAdd = await showViewDialog<bool>(
              context: context,
              barrierDismissible: false,
              builder: (context) => const StarterSetDialog(),
            );
            if (shouldAdd == true) {
              final addedStarterSetSuccessfully =
                  await sortableBloc.addStarter(language);
              if (!addedStarterSetSuccessfully) {
                showViewDialog(
                  context: context,
                  wrapWithAuthProviders: false,
                  builder: (_) => ErrorDialog(
                    text: t.unknownError,
                    backNavigationWidget: OkButton(
                      onPressed: Navigator.of(context).maybePop,
                    ),
                  ),
                );
              }
            }
          },
        );
}
