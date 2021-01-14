import 'package:flutter/material.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/ui/all.dart';

class BasicActivityLibraryItem extends StatelessWidget {
  final Sortable<BasicActivityDataItem> sortable;

  const BasicActivityLibraryItem({
    Key key,
    @required this.sortable,
  }) : super(key: key);

  final imageHeight = 86.0;
  final imageWidth = 84.0;
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
                overflow: Overflow.visible,
                children: [
                  AnimatedContainer(
                    duration: const Duration(microseconds: 400),
                    decoration: selected
                        ? greenBoarderWhiteBoxDecoration
                        : boxDecoration,
                    padding: const EdgeInsets.all(4.0).subtract(
                      selected ? const EdgeInsets.all(1.0) : EdgeInsets.zero,
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
                        const SizedBox(height: 2),
                        SizedBox(
                          height: imageHeight,
                          child: basicActivityData.hasImage
                              ? FadeInAbiliaImage(
                                  height: imageHeight,
                                  width: imageWidth,
                                  imageFileId: imageId,
                                  imageFilePath: iconPath,
                                )
                              : const Icon(
                                  AbiliaIcons.day,
                                  size: 48,
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
