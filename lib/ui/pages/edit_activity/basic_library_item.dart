import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/ui/all.dart';

class BasicLibraryItem<T extends SortableData> extends StatelessWidget {
  final Sortable<T> sortable;

  const BasicLibraryItem({
    Key? key,
    required this.sortable,
    this.isList = false,
  }) : super(key: key);

  static final imageHeight = 86.s, imageWidth = 84.s;
  final bool isList;

  @override
  Widget build(BuildContext context) {
    final basicLibraryData = sortable.data;
    final imageId = basicLibraryData.dataFileId();
    final name = basicLibraryData.title(Translator.of(context).translate);
    final iconPath = basicLibraryData.dataFilePath();

    return BlocBuilder<SortableArchiveCubit<T>, SortableArchiveState<T>>(
      builder: (innerContext, state) {
        final selected = state.selected;
        final isSelected = selected == sortable;
        return Tts.fromSemantics(
          SemanticsProperties(label: name),
          child: Material(
            type: MaterialType.transparency,
            child: InkWell(
              onTap: () => context
                  .read<SortableArchiveCubit<T>>()
                  .sortableSelected(sortable),
              borderRadius: borderRadius,
              child: Stack(
                alignment: Alignment.center,
                fit: isList ? StackFit.loose : StackFit.expand,
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
                          child: basicLibraryData.hasImage()
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
                  if (!isList)
                    PositionedRadio<Sortable<T>>(
                      value: sortable,
                      groupValue: state.selected,
                      onChanged: (v) {
                        if (v != null) {
                          context
                              .read<SortableArchiveCubit<T>>()
                              .sortableSelected(v);
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
