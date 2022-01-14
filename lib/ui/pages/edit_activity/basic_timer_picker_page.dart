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
    return BlocBuilder<SortableArchiveBloc<BasicTimerData>,
        SortableArchiveState<BasicTimerData>>(
      builder: (innerContext, state) {
        final selected = state.selected;
        return Scaffold(
          appBar: AbiliaAppBar(
            iconData: AbiliaIcons.basicActivity,
            title:
                state.allById[state.currentFolderId]?.data.title(translate) ??
                    'should be translated',
          ),
          body: SortableLibrary<BasicTimerData>(
            (Sortable<BasicTimerData> s) => s is Sortable<BasicTimerDataItem>
                ? BasicLibraryItem<BasicTimerData>(sortable: s)
                : CrossOver(
                    fallbackHeight: BasicLibraryItem.imageHeight,
                    fallbackWidth: BasicLibraryItem.imageWidth,
                  ),
            'should be translated',
          ),
          bottomNavigationBar: BottomNavigation(
            backNavigationWidget: PreviousButton(
              onPressed: state.isAtRoot
                  ? Navigator.of(context).maybePop
                  : () => context
                      .read<SortableArchiveBloc<BasicTimerData>>()
                      .add(NavigateUp()),
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
