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
                ? BasicTimerLibraryItem(sortable: s)
                : CrossOver(
                    fallbackHeight: BasicTimerLibraryItem.imageHeight,
                    fallbackWidth: BasicTimerLibraryItem.imageWidth,
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

class BasicTimerLibraryItem extends StatelessWidget {
  final Sortable<BasicTimerDataItem> sortable;

  const BasicTimerLibraryItem({
    Key? key,
    required this.sortable,
  }) : super(key: key);

  static final imageHeight = 86.s, imageWidth = 84.s;
  @override
  Widget build(BuildContext context) {
    final basicTimerData = sortable.data;
    final imageId = basicTimerData.fileId;
    final name = basicTimerData.title(Translator.of(context).translate);
    final iconPath = basicTimerData.icon;

    return BlocBuilder<SortableArchiveBloc<BasicTimerData>,
        SortableArchiveState<BasicTimerData>>(
      builder: (innerContext, state) {
        final selected = state.selected;
        final isSelected = selected == sortable;
        return Tts.fromSemantics(
          SemanticsProperties(label: name),
          child: Material(
            type: MaterialType.transparency,
            child: InkWell(
              onTap: () => context
                  .read<SortableArchiveBloc<BasicTimerData>>()
                  .add(SortableSelected(sortable)),
              borderRadius: borderRadius,
              child: Stack(
                alignment: Alignment.center,
                fit: StackFit.expand,
                clipBehavior: Clip.none,
                children: [
                  AnimatedContainer(
                    duration: const Duration(microseconds: 400),
                    decoration:
                        isSelected ? selectedBoxDecoration : boxDecoration,
                    padding: EdgeInsets.all(4.s).subtract(
                      isSelected ? EdgeInsets.all(1.s) : EdgeInsets.zero,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        if (name.isNotEmpty)
                          Text(
                            name,
                            overflow: TextOverflow.ellipsis,
                            style: abiliaTextTheme.caption,
                          ),
                        SizedBox(height: 2.s),
                        SizedBox(
                          height: imageHeight,
                          child: basicTimerData.hasImage
                              ? FadeInAbiliaImage(
                                  height: imageHeight,
                                  width: imageWidth,
                                  imageFileId: imageId,
                                  imageFilePath: iconPath,
                                )
                              : Icon(
                                  AbiliaIcons.day,
                                  size: 48.s,
                                  color: AbiliaColors.white140,
                                ),
                        ),
                      ],
                    ),
                  ),
                  PositionedRadio<Sortable>(
                    value: sortable,
                    groupValue: state.selected,
                    onChanged: (v) {
                      if (v != null) {
                        context
                            .read<SortableArchiveBloc<BasicTimerData>>()
                            .add(SortableSelected(v));
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
