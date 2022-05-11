import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/ui/all.dart';

class BasicTimerPickerPage extends StatelessWidget {
  const BasicTimerPickerPage({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final translate = Translator.of(context).translate;
    return BlocBuilder<SortableArchiveCubit<BasicTimerData>,
        SortableArchiveState<BasicTimerData>>(
      builder: (innerContext, state) {
        final selected = state.selected;
        return Scaffold(
          appBar: AbiliaAppBar(
            iconData: AbiliaIcons.stopWatch,
            title:
                state.allById[state.currentFolderId]?.data.title(translate) ??
                    translate.fromBasicTimer,
          ),
          body: SortableLibrary<BasicTimerData>(
            (Sortable<BasicTimerData> s) => s is Sortable<BasicTimerDataItem>
                ? BasicLibraryItem<BasicTimerData>(sortable: s)
                : const CrossOver(type: CrossOverType.darkSecondary),
            translate.noBasicTimers,
          ),
          bottomNavigationBar: BottomNavigation(
            backNavigationWidget: PreviousButton(
              onPressed: state.isAtRoot
                  ? Navigator.of(context).maybePop
                  : () => context
                      .read<SortableArchiveCubit<BasicTimerData>>()
                      .navigateUp(),
            ),
            forwardNavigationWidget: NextButton(
              onPressed: selected != null
                  ? () =>
                      Navigator.of(context).pop<BasicTimerData>(selected.data)
                  : null,
            ),
          ),
        );
      },
    );
  }
}
