// @dart=2.9

import 'package:flutter/cupertino.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/ui/all.dart';

class BasicActivityPickerPage extends StatelessWidget {
  const BasicActivityPickerPage({
    Key key,
    @required this.day,
  }) : super(key: key);
  final DateTime day;

  @override
  Widget build(BuildContext context) {
    final translate = Translator.of(context).translate;
    return BlocBuilder<SortableArchiveBloc<BasicActivityData>,
        SortableArchiveState<BasicActivityData>>(
      builder: (innerContext, state) => Scaffold(
        appBar: AbiliaAppBar(
          iconData: AbiliaIcons.basic_activity,
          title: state.allById[state.currentFolderId]?.data?.title() ??
              translate.basicActivities,
        ),
        body: SortableLibrary<BasicActivityData>(
          (Sortable<BasicActivityData> s) =>
              BasicActivityLibraryItem(sortable: s),
          translate.noBasicActivities,
        ),
        bottomNavigationBar: BottomNavigation(
          backNavigationWidget: PreviousButton(
            onPressed: state.isAtRoot
                ? Navigator.of(context).maybePop
                : () => BlocProvider.of<SortableArchiveBloc<BasicActivityData>>(
                        context)
                    .add(NavigateUp()),
          ),
          forwardNavigationWidget: NextButton(
            onPressed: state.isSelected
                ? () => Navigator.of(context)
                    .pop<BasicActivityData>(state.selected.data)
                : null,
          ),
        ),
      ),
    );
  }
}

class BasicActivityLibraryItem extends StatelessWidget {
  final Sortable<BasicActivityDataItem> sortable;

  BasicActivityLibraryItem({
    Key key,
    @required this.sortable,
  }) : super(key: key);

  final imageHeight = 86.s;
  final imageWidth = 84.s;
  @override
  Widget build(BuildContext context) {
    final basicActivityData = sortable.data;
    final imageId = basicActivityData.fileId;
    final name = basicActivityData.title();
    final iconPath = basicActivityData.icon;

    return BlocBuilder<SortableArchiveBloc<BasicActivityData>,
        SortableArchiveState<BasicActivityData>>(
      builder: (innerContext, state) {
        final selected = state.selected == sortable;
        return Tts.fromSemantics(
          SemanticsProperties(label: name),
          child: Material(
            type: MaterialType.transparency,
            child: InkWell(
              onTap: () => context
                  .read<SortableArchiveBloc<BasicActivityData>>()
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
                        selected ? selectedBoxDecoration : boxDecoration,
                    padding: EdgeInsets.all(4.s).subtract(
                      selected ? EdgeInsets.all(1.s) : EdgeInsets.zero,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        if (name != null)
                          Text(
                            name,
                            overflow: TextOverflow.ellipsis,
                            style: abiliaTextTheme.caption,
                          ),
                        SizedBox(height: 2.s),
                        SizedBox(
                          height: imageHeight,
                          child: basicActivityData.hasImage
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
                  PositionedRadio<Sortable<BasicActivityDataItem>>(
                    value: sortable,
                    groupValue: state.selected,
                    onChanged: (v) => context
                        .read<SortableArchiveBloc<BasicActivityData>>()
                        .add(SortableSelected(v)),
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
